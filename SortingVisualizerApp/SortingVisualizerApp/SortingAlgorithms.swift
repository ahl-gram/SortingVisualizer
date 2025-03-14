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
        
        for i in 0..<n {
            swapped = false
            
            for j in 0..<n - i - 1 {
                // Check if the task was cancelled
                if Task.isCancelled {
                    return
                }
                
                // Animate comparison
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        localBars[j].state = .comparing
                        localBars[j + 1].state = .comparing
                        
                        // Update the UI inside the animation block for smooth transitions
                        updateBars(localBars)
                    }
                    
                    // Play tone for the first bar being compared (outside animation block)
                    if isAudioEnabled {
                        audioManager.playTone(forValue: localBars[j].value)
                    }
                }
                
                // Delay for visualization
                // Use linear scaling across the entire range (0.1x-20.0x)
                let baseDelay: UInt64 = 500_000_000 // 0.5 seconds in nanoseconds
                let scaledDelay = UInt64(Double(baseDelay) / animationSpeed)
                
                try? await Task.sleep(nanoseconds: scaledDelay)
                
                // Play tone for the second bar being compared
                await MainActor.run {
                    if isAudioEnabled {
                        audioManager.playTone(forValue: localBars[j + 1].value)
                    }
                }
                
                if localBars[j].value > localBars[j + 1].value {
                    // Swap the elements
                    await MainActor.run {
                        // Update the UI with the swapped state using proper animation
                        // Use withAnimation to ensure the UI updates smoothly with the swap
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            let temp = localBars[j]
                            localBars[j] = localBars[j + 1]
                            localBars[j + 1] = temp
                            
                            // Update the bars inside the animation block to maintain smoothness
                            updateBars(localBars)
                        }
                    }
                    
                    swapped = true
                    
                    // Delay for visualization after swap
                    let swapDelay = scaledDelay // use the same scaled delay calculated above
                    try? await Task.sleep(nanoseconds: swapDelay)
                }
                
                // Reset the state of the compared elements
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        localBars[j].state = .unsorted
                        if j < n - i - 1 {
                            localBars[j + 1].state = .unsorted
                        }
                        
                        // Update the UI inside the animation block for smooth transitions
                        updateBars(localBars)
                    }
                }
            }
            
            // Mark the last element as sorted
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.5)) {
                    localBars[n - i - 1].state = .sorted
                    
                    // Update the UI inside the animation block for smooth transitions
                    updateBars(localBars)
                }
                
                // Play a higher tone for sorted element (outside animation block)
                if isAudioEnabled {
                    audioManager.playTone(forValue: 200) // Play the highest tone for sorted elements
                }
            }
            
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
        
        // Start the recursive quick sort
        await quickSortHelper(
            bars: &localBars,
            low: 0,
            high: localBars.count - 1,
            animationSpeed: animationSpeed,
            isAudioEnabled: isAudioEnabled,
            audioManager: audioManager,
            updateBars: updateBars
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
        animationSpeed: Double,
        isAudioEnabled: Bool,
        audioManager: AudioManager,
        updateBars: @escaping ([SortingViewModel.SortingBar]) -> Void
    ) async {
        // Check for task cancellation
        if Task.isCancelled {
            return
        }
        
        // Base case: If there's one element or fewer, the segment is already sorted
        if low >= high {
            // Mark this element as sorted
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.5)) {
                    bars[low].state = .sorted
                    updateBars(bars)
                }
                
                if isAudioEnabled {
                    audioManager.playTone(forValue: 200)
                }
            }
            return
        }
        
        // Partition the array and get the pivot index
        let pivotIndex = await partition(
            bars: &bars,
            low: low,
            high: high,
            animationSpeed: animationSpeed,
            isAudioEnabled: isAudioEnabled,
            audioManager: audioManager,
            updateBars: updateBars
        )
        
        // Mark the pivot as sorted
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.5)) {
                bars[pivotIndex].state = .sorted
                updateBars(bars)
            }
            
            if isAudioEnabled {
                audioManager.playTone(forValue: 200)
            }
        }
        
        // Recursively sort the sub-arrays
        if pivotIndex > low {
            await quickSortHelper(
                bars: &bars,
                low: low,
                high: pivotIndex - 1,
                animationSpeed: animationSpeed,
                isAudioEnabled: isAudioEnabled,
                audioManager: audioManager,
                updateBars: updateBars
            )
        }
        
        if pivotIndex < high {
            await quickSortHelper(
                bars: &bars,
                low: pivotIndex + 1,
                high: high,
                animationSpeed: animationSpeed,
                isAudioEnabled: isAudioEnabled,
                audioManager: audioManager,
                updateBars: updateBars
            )
        }
    }
    
    // Partition function for quicksort
    private static func partition(
        bars: inout [SortingViewModel.SortingBar],
        low: Int,
        high: Int,
        animationSpeed: Double,
        isAudioEnabled: Bool,
        audioManager: AudioManager,
        updateBars: @escaping ([SortingViewModel.SortingBar]) -> Void
    ) async -> Int {
        // Choose the rightmost element as pivot
        let pivot = bars[high].value
        
        // Highlight the pivot
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                bars[high].state = .comparing
                updateBars(bars)
            }
            
            if isAudioEnabled {
                audioManager.playTone(forValue: bars[high].value)
            }
        }
        
        // Delay for visualization
        let baseDelay: UInt64 = 500_000_000 // 0.5 seconds in nanoseconds
        let scaledDelay = UInt64(Double(baseDelay) / animationSpeed)
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
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    bars[j].state = .comparing
                    updateBars(bars)
                }
                
                if isAudioEnabled {
                    audioManager.playTone(forValue: bars[j].value)
                }
            }
            
            // Delay for visualization
            try? await Task.sleep(nanoseconds: scaledDelay)
            
            // If current element is smaller than the pivot
            if bars[j].value < pivot {
                // Increment index of smaller element
                i += 1
                
                // Swap elements
                await MainActor.run {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        let temp = bars[i]
                        bars[i] = bars[j]
                        bars[j] = temp
                        updateBars(bars)
                    }
                    
                    if isAudioEnabled {
                        audioManager.playTone(forValue: bars[i].value)
                    }
                }
                
                // Delay for visualization after swap
                try? await Task.sleep(nanoseconds: scaledDelay)
            }
            
            // Reset the state of the compared element
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) {
                    bars[j].state = .unsorted
                    if i >= low {
                        bars[i].state = .unsorted
                    }
                    updateBars(bars)
                }
            }
        }
        
        // Reset the pivot state before final swap
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                bars[high].state = .unsorted
                updateBars(bars)
            }
        }
        
        // Swap the pivot element with the element at (i+1)
        // This puts the pivot in its correct sorted position
        i += 1
        await MainActor.run {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                let temp = bars[i]
                bars[i] = bars[high]
                bars[high] = temp
                updateBars(bars)
            }
            
            if isAudioEnabled {
                audioManager.playTone(forValue: bars[i].value)
            }
        }
        
        // Delay for visualization after final swap
        try? await Task.sleep(nanoseconds: scaledDelay)
        
        return i // Return the pivot's position
    }
} 