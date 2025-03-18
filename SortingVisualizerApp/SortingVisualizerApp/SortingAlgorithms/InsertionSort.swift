    //
//  SortingAlgorithms.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import Foundation
import SwiftUI

/// Pure insertion sort algorithm that reports steps through a callback
/// - Parameters:
///   - array: Array to sort
///   - onStep: Callback that's called for each step in the algorithm
/// - Returns: Sorted array
enum InsertionSort {
        static func insertionSort<T: Comparable>(
            array: [T],
            onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        var arr = array
        let n = arr.count
        
        // Check for empty or single-element array
        if n <= 1 {
            _ = await onStep(SortingStep.completed, arr)
            return arr
        }
        
        // First element is already "sorted"
        _ = await onStep(SortingStep.markSorted(0), arr)
        
        // Start from the second element
        for i in 1..<n {
            // Store the current element to insert it in the correct position
            let key = arr[i]
            var j = i - 1
            
            // Compare key with each element on the left until a smaller element is found
            while j >= 0 {
                // Report comparison
                let shouldContinue = await onStep(SortingStep.compare(j, i), arr)
                if !shouldContinue { return arr } // Allow cancellation
                
                if arr[j] > key {
                    // Move elements greater than key to one position ahead
                    arr[j + 1] = arr[j]
                    
                    // Report swap
                    _ = await onStep(SortingStep.swap(j, j + 1), arr)
                    
                    j -= 1
                } else {
                    // Found the correct position
                    break
                }
            }
            
            // Place key at its correct position
            arr[j + 1] = key
            
            // Mark the element as sorted
            _ = await onStep(SortingStep.markSorted(i), arr)
        }
        
        // Report completion
        _ = await onStep(SortingStep.completed, arr)
        
        return arr
    }
}
