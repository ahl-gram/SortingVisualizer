//
//  SortingAlgorithms.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import Foundation
import SwiftUI

/// Pure selection sort algorithm that reports steps through a callback
/// - Parameters:
///   - array: Array to sort
///   - onStep: Callback that's called for each step in the algorithm
/// - Returns: Sorted array
enum SelectionSort {
    static func selectionSort<T: Comparable>(
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
        
        // One by one move boundary of unsorted subarray
        for i in 0..<n-1 {
            // Find the minimum element in unsorted array
            var minIndex = i
            
            for j in i+1..<n {
                // Report comparison
                let shouldContinue = await onStep(SortingStep.compare(j, minIndex), arr)
                if !shouldContinue { return arr } // Allow cancellation
                
                // If current element is smaller than the minimum found so far
                if arr[j] < arr[minIndex] {
                    minIndex = j
                }
            }
            
            // Swap the found minimum element with the first element
            if minIndex != i {
                arr.swapAt(minIndex, i)
                
                // Report swap
                let shouldContinue = await onStep(SortingStep.swap(minIndex, i), arr)
                if !shouldContinue { return arr } // Allow cancellation
            }
            
            // Mark the element as sorted (now in its final position)
            let shouldContinue = await onStep(SortingStep.markSorted(i), arr)
            if !shouldContinue { return arr } // Allow cancellation
        }
        
        // Mark the last element as sorted
        _ = await onStep(SortingStep.markSorted(n-1), arr)
        
        // Report completion
        _ = await onStep(SortingStep.completed, arr)
        
        return arr
    }
}