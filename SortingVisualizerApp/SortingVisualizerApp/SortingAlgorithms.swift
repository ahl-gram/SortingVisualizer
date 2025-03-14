//
//  SortingAlgorithms.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import Foundation
import SwiftUI

// Define the available sorting algorithms
enum SortingAlgorithmType: String, CaseIterable, Identifiable {
    case bubble = "Bubble Sort"
    case quick = "Quick Sort"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .bubble:
            return "A simple comparison-based algorithm that repeatedly steps through the list, compares adjacent elements, and swaps them if they are in the wrong order."
        case .quick:
            return "A divide-and-conquer algorithm that works by selecting a 'pivot' element and partitioning the array around the pivot."
        }
    }
}

// Collection of sorting algorithms
enum SortingAlgorithms {
    
    // MARK: - Common Parameters Struct
    struct SortingParams {
        let animationSpeed: Double
        let isAudioEnabled: Bool
        let audioManager: AudioManager
        let updateBars: ([SortingViewModel.SortingBar]) -> Void
    }
    
    // MARK: - Helper Methods for Visualization
    
    /// Calculate delay based on animation speed
    private static func calculateDelay(animationSpeed: Double) -> UInt64 {
        let baseDelay: UInt64 = 500_000_000 // 0.5 seconds in nanoseconds
        return UInt64(Double(baseDelay) / animationSpeed)
    }
    
    /// Set bars to comparing state and play tone
    private static func highlightBarsForComparison(
        indexes: [Int],
        bars: inout [SortingViewModel.SortingBar],
        params: SortingParams
    ) async {
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                for index in indexes {
                    bars[index].state = .comparing
                }
                params.updateBars(bars)
            }
            
            // Play tone for the first bar being compared
            if params.isAudioEnabled && !indexes.isEmpty {
                params.audioManager.playTone(forValue: bars[indexes[0]].value)
            }
        }
        
        // If there's a second bar, play its tone after a small delay
        if indexes.count > 1 && params.isAudioEnabled {
            try? await Task.sleep(nanoseconds: calculateDelay(animationSpeed: params.animationSpeed))
            
            await MainActor.run {
                params.audioManager.playTone(forValue: bars[indexes[1]].value)
            }
        }
    }
    
    /// Reset bars to unsorted state
    private static func resetBarsToUnsorted(
        indexes: [Int],
        bars: inout [SortingViewModel.SortingBar],
        params: SortingParams,
        exceptFor exceptIndexes: [Int] = []
    ) async {
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                for index in indexes where !exceptIndexes.contains(index) {
                    bars[index].state = .unsorted
                }
                params.updateBars(bars)
            }
        }
    }
    
    /// Mark bars as sorted
    private static func markBarsAsSorted(
        indexes: [Int],
        bars: inout [SortingViewModel.SortingBar],
        params: SortingParams
    ) async {
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.5)) {
                for index in indexes {
                    bars[index].state = .sorted
                }
                params.updateBars(bars)
            }
            
            // Play a higher tone for sorted element
            if params.isAudioEnabled {
                params.audioManager.playTone(forValue: 200) // High tone for sorted elements
            }
        }
    }
    
    /// Swap two bars with animation
    private static func swapBars(
        index1: Int,
        index2: Int,
        bars: inout [SortingViewModel.SortingBar],
        params: SortingParams
    ) async {
        await MainActor.run {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                let temp = bars[index1]
                bars[index1] = bars[index2]
                bars[index2] = temp
                params.updateBars(bars)
            }
            
            if params.isAudioEnabled {
                params.audioManager.playTone(forValue: bars[index1].value)
            }
        }
    }
    
    // MARK: - Sorting Algorithms
    
    // Bubble sort implementation
    static func bubbleSort(
        bars: [SortingViewModel.SortingBar],
        animationSpeed: Double,
        isAudioEnabled: Bool,
        audioManager: AudioManager,
        updateBars: @escaping ([SortingViewModel.SortingBar]) -> Void,
        markAllAsSorted: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) async {
        var localBars = bars
        let n = localBars.count
        var swapped = false
        
        // Create params tuple for helper methods
        let params = SortingParams(
            animationSpeed: animationSpeed,
            isAudioEnabled: isAudioEnabled,
            audioManager: audioManager,
            updateBars: updateBars
        )
        
        // Calculate delay once
        let scaledDelay = calculateDelay(animationSpeed: animationSpeed)
        
        for i in 0..<n {
            swapped = false
            
            for j in 0..<n - i - 1 {
                // Check if the task was cancelled
                if Task.isCancelled {
                    return
                }
                
                // Highlight bars being compared
                await highlightBarsForComparison(
                    indexes: [j, j + 1],
                    bars: &localBars,
                    params: params
                )
                
                // Delay for visualization
                try? await Task.sleep(nanoseconds: scaledDelay)
                
                if localBars[j].value > localBars[j + 1].value {
                    // Swap the elements
                    await swapBars(
                        index1: j,
                        index2: j + 1,
                        bars: &localBars,
                        params: params
                    )
                    
                    swapped = true
                    
                    // Delay for visualization after swap
                    try? await Task.sleep(nanoseconds: scaledDelay)
                }
                
                // Reset the state of the compared elements
                await resetBarsToUnsorted(
                    indexes: [j, j + 1],
                    bars: &localBars,
                    params: params
                )
            }
            
            // Mark the last element as sorted
            await markBarsAsSorted(
                indexes: [n - i - 1],
                bars: &localBars,
                params: params
            )
            
            // If no swapping occurred in this pass, the array is already sorted
            if !swapped {
                break
            }
        }
        
        // Mark all remaining elements as sorted and show completion animation
        await MainActor.run {
            markAllAsSorted()
            onComplete()
        }
    }
    
    // Quick sort implementation
    static func quickSort(
        bars: [SortingViewModel.SortingBar],
        animationSpeed: Double,
        isAudioEnabled: Bool,
        audioManager: AudioManager,
        updateBars: @escaping ([SortingViewModel.SortingBar]) -> Void,
        markAllAsSorted: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) async {
        var localBars = bars
        
        // Create params tuple for helper methods
        let params = SortingParams(
            animationSpeed: animationSpeed,
            isAudioEnabled: isAudioEnabled,
            audioManager: audioManager,
            updateBars: updateBars
        )
        
        // Start the recursive quick sort
        await quickSortHelper(
            bars: &localBars,
            low: 0,
            high: localBars.count - 1,
            params: params
        )
        
        // Mark all elements as sorted and show completion animation
        await MainActor.run {
            markAllAsSorted()
            onComplete()
        }
    }
    
    // Helper method for the quicksort algorithm
    private static func quickSortHelper(
        bars: inout [SortingViewModel.SortingBar],
        low: Int,
        high: Int,
        params: SortingParams
    ) async {
        // Check for task cancellation
        if Task.isCancelled {
            return
        }
        
        // Base case: If there's one element or fewer, the segment is already sorted
        if low >= high {
            // Mark this element as sorted
            await markBarsAsSorted(
                indexes: [low],
                bars: &bars,
                params: params
            )
            return
        }
        
        // Partition the array and get the pivot index
        let pivotIndex = await partition(
            bars: &bars,
            low: low,
            high: high,
            params: params
        )
        
        // Mark the pivot as sorted
        await markBarsAsSorted(
            indexes: [pivotIndex],
            bars: &bars,
            params: params
        )
        
        // Recursively sort the sub-arrays
        if pivotIndex > low {
            await quickSortHelper(
                bars: &bars,
                low: low,
                high: pivotIndex - 1,
                params: params
            )
        }
        
        if pivotIndex < high {
            await quickSortHelper(
                bars: &bars,
                low: pivotIndex + 1,
                high: high,
                params: params
            )
        }
    }
    
    // Partition function for quicksort
    private static func partition(
        bars: inout [SortingViewModel.SortingBar],
        low: Int,
        high: Int,
        params: SortingParams
    ) async -> Int {
        // Choose the rightmost element as pivot
        let pivot = bars[high].value
        
        // Highlight the pivot
        await highlightBarsForComparison(
            indexes: [high],
            bars: &bars,
            params: params
        )
        
        // Delay for visualization
        let scaledDelay = calculateDelay(animationSpeed: params.animationSpeed)
        try? await Task.sleep(nanoseconds: scaledDelay)
        
        // Index of smaller element
        var i = low - 1
        
        // Traverse through all elements
        // compare each element with pivot
        for j in low..<high {
            // Check for task cancellation
            if Task.isCancelled {
                break
            }
            
            // Highlight the current element being compared
            await highlightBarsForComparison(
                indexes: [j],
                bars: &bars,
                params: params
            )
            
            // Delay for visualization
            try? await Task.sleep(nanoseconds: scaledDelay)
            
            // If current element is smaller than the pivot
            if bars[j].value < pivot {
                // Increment index of smaller element
                i += 1
                
                // Swap elements
                await swapBars(
                    index1: i,
                    index2: j,
                    bars: &bars,
                    params: params
                )
                
                // Delay for visualization after swap
                try? await Task.sleep(nanoseconds: scaledDelay)
            }
            
            // Reset the state of the compared element
            await resetBarsToUnsorted(
                indexes: [j],  // Only include j, which is guaranteed to be valid
                bars: &bars,
                params: params
            )
            
            // Only reset i if it's a valid index
            if i >= low {
                await resetBarsToUnsorted(
                    indexes: [i],
                    bars: &bars,
                    params: params
                )
            }
        }
        
        // Reset the pivot state before final swap
        await resetBarsToUnsorted(
            indexes: [high],
            bars: &bars,
            params: params
        )
        
        // Swap the pivot element with the element at (i+1)
        // This puts the pivot in its correct sorted position
        i += 1
        await swapBars(
            index1: i,
            index2: high,
            bars: &bars,
            params: params
        )
        
        // Delay for visualization after final swap
        try? await Task.sleep(nanoseconds: scaledDelay)
        
        return i // Return the pivot's position
    }
} 