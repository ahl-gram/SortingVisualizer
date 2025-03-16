//
//  SortingVisualizers.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import Foundation
import SwiftUI

// Collection of sorting visualizers
enum SortingVisualizers {
    
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
    
    // MARK: - Process Sorting Step
    
    /// Process a sorting step and apply visualization
    private static func processSortingStep(
        step: SortingAlgorithms.SortingStep<Int>,
        bars: inout [SortingViewModel.SortingBar],
        params: SortingParams,
        markAllAsSorted: @escaping () -> Void,
        onComplete: @escaping () -> Void,
        scaledDelay: UInt64
    ) async -> Bool {
        // Check for task cancellation
        if Task.isCancelled {
            return false
        }
        
        switch step {
        case .compare(let index1, let index2):
            // Highlight bars being compared
            await highlightBarsForComparison(
                indexes: [index1, index2],
                bars: &bars,
                params: params
            )
            
            // Delay for visualization
            try? await Task.sleep(nanoseconds: scaledDelay)
            
            // Reset to unsorted state after comparison
            if index1 != index2 { // Skip resetting for pivot self-comparison
                await resetBarsToUnsorted(
                    indexes: [index1, index2],
                    bars: &bars,
                    params: params
                )
            }
            
            return true
            
        case .swap(let index1, let index2):
            // Check if this is a direct update (self-swap) used by merge sort
            if index1 == index2 {
                // This is a direct update, not a swap
                // Simply update the UI without swap animation
                await MainActor.run {
                    // Use a simpler animation for direct updates
                    withAnimation(.easeInOut(duration: 0.2)) {
                        params.updateBars(bars)
                    }
                    
                    if params.isAudioEnabled {
                        params.audioManager.playTone(forValue: bars[index1].value)
                    }
                }
            } else {
                // This is a regular swap
                await swapBars(
                    index1: index1,
                    index2: index2,
                    bars: &bars,
                    params: params
                )
            }
            
            // Delay for visualization after swap
            try? await Task.sleep(nanoseconds: scaledDelay)
            
            return true
            
        case .merge(let index, let newValue):
            // This is a special case for merge sort
            // First mark the bar as being merged
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.2)) {
                    bars[index].state = .merging
                    params.updateBars(bars)
                }
            }
            
            // Short delay for visual effect
            try? await Task.sleep(nanoseconds: scaledDelay / 3)
            
            // Update the bar value with a smooth animation
            await MainActor.run {
                // Use a distinct animation for merging that's visually different from swapping
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    bars[index].value = newValue
                    params.updateBars(bars)
                }
                
                if params.isAudioEnabled {
                    params.audioManager.playTone(forValue: bars[index].value)
                }
            }
            
            // Another short delay
            try? await Task.sleep(nanoseconds: scaledDelay / 2)
            
            // Reset the bar state to unsorted after merging
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.2)) {
                    bars[index].state = .unsorted
                    params.updateBars(bars)
                }
            }
            
            return true
            
        case .markSorted(let index):
            // Mark the element as sorted
            await markBarsAsSorted(
                indexes: [index],
                bars: &bars,
                params: params
            )
            
            return true
            
        case .completed:
            // Mark all remaining elements as sorted and show completion animation
            await MainActor.run {
                markAllAsSorted()
                onComplete()
            }
            
            return false
        }
    }
    
    // MARK: - Generic Sorting Method
    
    /// Generic method to run any sorting algorithm
    static func runSortingAlgorithm(
        type: SortingAlgorithmType,
        bars: [SortingViewModel.SortingBar],
        animationSpeed: Double,
        isAudioEnabled: Bool,
        audioManager: AudioManager,
        updateBars: @escaping ([SortingViewModel.SortingBar]) -> Void,
        markAllAsSorted: @escaping () -> Void,
        onComplete: @escaping () -> Void
    ) async {
        var localBars = bars
        
        // Create params struct for helper methods
        let params = SortingParams(
            animationSpeed: animationSpeed,
            isAudioEnabled: isAudioEnabled,
            audioManager: audioManager,
            updateBars: updateBars
        )
        
        // Calculate delay once
        let scaledDelay = calculateDelay(animationSpeed: animationSpeed)
        
        // Extract bar values for sorting
        let values = localBars.map { $0.value }
        
        // Run the appropriate sorting algorithm based on the type
        switch type {
        case .bubble:
            _ = await SortingAlgorithms.bubbleSort(array: values) { step, _ in
                await processSortingStep(
                    step: step,
                    bars: &localBars,
                    params: params,
                    markAllAsSorted: markAllAsSorted,
                    onComplete: onComplete,
                    scaledDelay: scaledDelay
                )
            }
            
        case .quick:
            _ = await SortingAlgorithms.quickSort(array: values) { step, _ in
                await processSortingStep(
                    step: step,
                    bars: &localBars,
                    params: params,
                    markAllAsSorted: markAllAsSorted,
                    onComplete: onComplete,
                    scaledDelay: scaledDelay
                )
            }
            
        case .merge:
            _ = await SortingAlgorithms.mergeSort(array: values) { step, _ in
                await processSortingStep(
                    step: step,
                    bars: &localBars,
                    params: params,
                    markAllAsSorted: markAllAsSorted,
                    onComplete: onComplete,
                    scaledDelay: scaledDelay
                )
            }
            
        case .insertion:
            _ = await SortingAlgorithms.insertionSort(array: values) { step, _ in
                await processSortingStep(
                    step: step,
                    bars: &localBars,
                    params: params,
                    markAllAsSorted: markAllAsSorted,
                    onComplete: onComplete,
                    scaledDelay: scaledDelay
                )
            }
        }
    }
} 