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
        let baseDelay: UInt64 = AppConstants.Animation.baseDelay // 0.5 seconds in nanoseconds
        return UInt64(Double(baseDelay) / animationSpeed)
    }
    
    /// Set bars to comparing state and play tone
    private static func highlightBarsForComparison(
        indexes: [Int],
        bars: [SortingViewModel.SortingBar],
        params: SortingParams
    ) async -> [SortingViewModel.SortingBar] {
        // Create a copy on the MainActor and perform all mutations there
        let updatedBars = await MainActor.run {
            var barsCopy = bars
            
            withAnimation(.easeInOut(duration: 0.3)) {
                for index in indexes {
                    barsCopy[index].state = .comparing
                }
                params.updateBars(barsCopy)
            }
            
            // Play tone for the first bar being compared
            if params.isAudioEnabled && !indexes.isEmpty {
                params.audioManager.playTone(forValue: barsCopy[indexes[0]].value)
            }
            
            return barsCopy
        }
        
        // If there's a second bar, play its tone after a small delay
        if indexes.count > 1 && params.isAudioEnabled {
            try? await Task.sleep(nanoseconds: calculateDelay(animationSpeed: params.animationSpeed))
            
            await MainActor.run {
                params.audioManager.playTone(forValue: updatedBars[indexes[1]].value)
            }
        }
        
        return updatedBars
    }
    
    /// Reset bars to unsorted state
    private static func resetBarsToUnsorted(
        indexes: [Int],
        bars: [SortingViewModel.SortingBar],
        params: SortingParams,
        exceptFor exceptIndexes: [Int] = []
    ) async -> [SortingViewModel.SortingBar] {
        // Perform all mutations on the MainActor
        return await MainActor.run {
            var barsCopy = bars
            
            withAnimation(.easeInOut(duration: 0.3)) {
                for index in indexes where !exceptIndexes.contains(index) {
                    barsCopy[index].state = .unsorted
                }
                params.updateBars(barsCopy)
            }
            
            return barsCopy
        }
    }
    
    /// Mark bars as sorted
    private static func markBarsAsSorted(
        indexes: [Int],
        bars: [SortingViewModel.SortingBar],
        params: SortingParams
    ) async -> [SortingViewModel.SortingBar] {
        // Perform all mutations on the MainActor
        return await MainActor.run {
            var barsCopy = bars
            
            withAnimation(.easeInOut(duration: 0.5)) {
                for index in indexes {
                    barsCopy[index].state = .sorted
                }
                params.updateBars(barsCopy)
            }
            
            // Play a higher tone for sorted element
            if params.isAudioEnabled {
                params.audioManager.playTone(forValue: AppConstants.Audio.sortedToneValue) // High tone for sorted elements
            }
            
            return barsCopy
        }
    }
    
    /// Swap two bars with animation
    private static func swapBars(
        index1: Int,
        index2: Int,
        bars: [SortingViewModel.SortingBar],
        params: SortingParams
    ) async -> [SortingViewModel.SortingBar] {
        // Perform all mutations on the MainActor
        return await MainActor.run {
            var barsCopy = bars
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                let temp = barsCopy[index1]
                barsCopy[index1] = barsCopy[index2]
                barsCopy[index2] = temp
                params.updateBars(barsCopy)
            }
            
            if params.isAudioEnabled {
                params.audioManager.playTone(forValue: barsCopy[index1].value)
            }
            
            return barsCopy
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
            let updatedBars = await highlightBarsForComparison(
                indexes: [index1, index2],
                bars: bars,
                params: params
            )
            
            // Delay for visualization
            try? await Task.sleep(nanoseconds: scaledDelay)
            
            // Reset to unsorted state after comparison
            if index1 != index2 { // Skip resetting for pivot self-comparison
                let resetBars = await resetBarsToUnsorted(
                    indexes: [index1, index2],
                    bars: updatedBars,
                    params: params
                )
                bars = resetBars
            } else {
                bars = updatedBars
            }
            
            return true
            
        case .swap(let index1, let index2):
            // Check if this is a direct update (self-swap) used by merge sort
            if index1 == index2 {
                // This is a direct update, not a swap
                // Simply update the UI without swap animation
                let updatedBars = await MainActor.run { () -> [SortingViewModel.SortingBar] in
                    var barsCopy = bars
                    // Use a simpler animation for direct updates
                    withAnimation(.easeInOut(duration: 0.2)) {
                        params.updateBars(barsCopy)
                    }
                    
                    if params.isAudioEnabled {
                        params.audioManager.playTone(forValue: barsCopy[index1].value)
                    }
                    
                    return barsCopy
                }
                
                bars = updatedBars
            } else {
                // This is a regular swap
                let updatedBars = await swapBars(
                    index1: index1,
                    index2: index2,
                    bars: bars,
                    params: params
                )
                bars = updatedBars
            }
            
            // Delay for visualization after swap
            try? await Task.sleep(nanoseconds: scaledDelay)
            
            return true
            
        case .merge(let index, let newValue):
            // This is a special case for merge sort
            // Step 1: Mark the bar as being merged
            let mergingBars = await MainActor.run { () -> [SortingViewModel.SortingBar] in
                var barsCopy = bars
                withAnimation(.easeInOut(duration: 0.2)) {
                    barsCopy[index].state = .merging
                    params.updateBars(barsCopy)
                }
                return barsCopy
            }
            
            // Short delay for visual effect
            try? await Task.sleep(nanoseconds: scaledDelay / 3)
            
            // Step 2: Update the bar value with a smooth animation
            let updatedValueBars = await MainActor.run { () -> [SortingViewModel.SortingBar] in
                var barsCopy = mergingBars
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    barsCopy[index].value = newValue
                    params.updateBars(barsCopy)
                }
                
                if params.isAudioEnabled {
                    params.audioManager.playTone(forValue: barsCopy[index].value)
                }
                
                return barsCopy
            }
            
            // Another short delay
            try? await Task.sleep(nanoseconds: scaledDelay / 2)
            
            // Step 3: Reset the bar state to unsorted after merging
            let finalBars = await resetBarsToUnsorted(
                indexes: [index],
                bars: updatedValueBars,
                params: params
            )
            bars = finalBars
            
            return true
            
        case .bucket(let index, let bucketIndex):
            // For radix sort: highlight the bar and indicate which bucket it's going to
            let updatedBars = await MainActor.run { () -> [SortingViewModel.SortingBar] in
                var barsCopy = bars
                withAnimation(.easeInOut(duration: 0.3)) {
                    barsCopy[index].state = .comparing
                    params.updateBars(barsCopy)
                }
                
                if params.isAudioEnabled {
                    // Play a tone related to the bucket index (0-9)
                    let bucketTone = 100 + (bucketIndex * 10)
                    params.audioManager.playTone(forValue: bucketTone)
                }
                
                return barsCopy
            }
            
            // Delay for visualization
            try? await Task.sleep(nanoseconds: scaledDelay)
            
            // Reset the bar state to unsorted
            let resetBars = await resetBarsToUnsorted(
                indexes: [index],
                bars: updatedBars,
                params: params
            )
            bars = resetBars
            
            return true
            
        case .markSorted(let index):
            // Mark the element as sorted
            let updatedBars = await markBarsAsSorted(
                indexes: [index],
                bars: bars,
                params: params
            )
            bars = updatedBars
            
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
            
        case .heap:
            _ = await SortingAlgorithms.heapSort(array: values) { step, _ in
                await processSortingStep(
                    step: step,
                    bars: &localBars,
                    params: params,
                    markAllAsSorted: markAllAsSorted,
                    onComplete: onComplete,
                    scaledDelay: scaledDelay
                )
            }
            
        case .radix:
            _ = await SortingAlgorithms.radixSort(array: values) { step, _ in
                await processSortingStep(
                    step: step,
                    bars: &localBars,
                    params: params,
                    markAllAsSorted: markAllAsSorted,
                    onComplete: onComplete,
                    scaledDelay: scaledDelay
                )
            }
            
        case .time:
            _ = await SortingAlgorithms.timeSort(array: values) { step, _ in
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
