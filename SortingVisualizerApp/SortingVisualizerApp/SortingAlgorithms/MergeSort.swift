//
//  SortingAlgorithms.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import Foundation
import SwiftUI

/// Pure merge sort algorithm that reports steps through a callback
/// - Parameters:
///   - array: Array to sort
///   - onStep: Callback that's called for each step in the algorithm
/// - Returns: Sorted array
enum MergeSort {
    static func mergeSort<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        var arr = array
        
        // Check for empty or single-element array
        if arr.count <= 1 {
            _ = await onStep(SortingStep.completed, arr)
            return arr
        }
        
        // Start recursive merge sort
        await mergeSortHelper(
            array: &arr,
            start: 0,
            end: arr.count - 1,
            onStep: onStep
        )
        
        // Report completion
        _ = await onStep(SortingStep.completed, arr)
        
        return arr
    }
    
    /// Helper function for merge sort
    private static func mergeSortHelper<T: Comparable>(
        array: inout [T],
        start: Int,
        end: Int,
        onStep: SortingStepType.StepCallback<T>
    ) async {
        // Base case: if the array segment has 1 or fewer elements, it's already sorted
        if start >= end {
            if start == end {
                // Mark the single element as sorted
                _ = await onStep(SortingStep.markSorted(start), array)
            }
            return
        }
        
        // Find the middle point
        let mid = start + (end - start) / 2
        
        // Sort first and second halves
        await mergeSortHelper(array: &array, start: start, end: mid, onStep: onStep)
        await mergeSortHelper(array: &array, start: mid + 1, end: end, onStep: onStep)
        
        // Merge the sorted halves
        await merge(array: &array, start: start, mid: mid, end: end, onStep: onStep)
    }
    
    /// Merge function for merge sort
    private static func merge<T: Comparable>(
        array: inout [T],
        start: Int,
        mid: Int,
        end: Int,
        onStep: SortingStepType.StepCallback<T>
    ) async {
        // Create temporary arrays for the two halves
        let leftSize = mid - start + 1
        let rightSize = end - mid
        
        var leftArray = Array(array[start...(start + leftSize - 1)])
        var rightArray = Array(array[(mid + 1)...end])
        
        // Indexes for traversing the temporary arrays
        var i = 0, j = 0
        // Index for the main array
        var k = start
        
        // Merge the temporary arrays back into the main array
        while i < leftSize && j < rightSize {
            // Compare elements from both arrays
            let shouldContinue = await onStep(.compare(start + i, mid + 1 + j), array)
            if !shouldContinue { return }
            
            if leftArray[i] <= rightArray[j] {
                // If the current element in the left array is smaller
                // than the current element in the right array
                if array[k] != leftArray[i] {
                    // Update the element in the main array
                    array[k] = leftArray[i]
                    
                    // Report as a merge operation with the new value
                    _ = await onStep(SortingStep.merge(k, leftArray[i]), array)
                }
                i += 1
            } else {
                // If the current element in the right array is smaller
                if array[k] != rightArray[j] {
                    // Update the element in the main array
                    array[k] = rightArray[j]
                    
                    // Report as a merge operation with the new value
                    _ = await onStep(SortingStep.merge(k, rightArray[j]), array)
                }
                j += 1
            }
            k += 1
        }
        
        // Copy any remaining elements from the left array
        while i < leftSize {
            if array[k] != leftArray[i] {
                array[k] = leftArray[i]
                _ = await onStep(SortingStep.merge(k, leftArray[i]), array)
            }
            i += 1
            k += 1
        }
        
        // Copy any remaining elements from the right array
        while j < rightSize {
            if array[k] != rightArray[j] {
                array[k] = rightArray[j]
                _ = await onStep(SortingStep.merge(k, rightArray[j]), array)
            }
            j += 1
            k += 1
        }
        
        // Mark all elements in this merged segment as sorted
        for index in start...end {
            _ = await onStep(SortingStep.markSorted(index), array)
        }
    }   
}
