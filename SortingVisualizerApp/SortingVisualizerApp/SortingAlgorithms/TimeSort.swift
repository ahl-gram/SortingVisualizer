import Foundation
import SwiftUI

/// Time Sort implementation - a hybrid algorithm combining insertion sort for small arrays and merge sort for larger ones
/// - Parameters:
///   - array: Array to sort
///   - onStep: Callback that's called for each step in the algorithm
/// - Returns: Sorted array
enum TimeSort {
    static func sort<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        let arr = array
        let n = arr.count
        
        // Check for empty or single-element array
        if n <= 1 {
            _ = await onStep(SortingStep.completed, arr)
            return arr
        }
        
        // Use insertion sort for small arrays (less than 16 elements)
        if n < 16 {
            return await InsertionSort.sort(array: arr, onStep: onStep)
        }
        
        // For larger arrays, use merge sort with insertion sort for small subarrays
        var result = await timeSortHelper(array: arr, start: 0, end: n - 1, onStep: onStep)
        
        // Report completion
        _ = await onStep(SortingStep.completed, result)
        
        return result
    }
    
    /// Helper function for Time Sort
    /// - Parameters:
    ///   - array: Array to sort
    ///   - start: Start index
    ///   - end: End index
    ///   - onStep: Callback that's called for each step in the algorithm
    /// - Returns: Sorted array
    private static func timeSortHelper<T: Comparable>(
        array: [T],
        start: Int,
        end: Int,
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        var arr = array
        
        // Base case: if the subarray is small enough, use insertion sort
        if end - start + 1 < 16 {
            var subArray = Array(arr[start...end])
            subArray = await insertionSortSubarray(array: subArray, onStep: { step, updated in
                // Map the steps to the correct indices in the original array
                let mappedStep: SortingStep<T>
                switch step {
                case .compare(let i, let j):
                    mappedStep = .compare(i + start, j + start)
                case .swap(let i, let j):
                    mappedStep = .swap(i + start, j + start)
                case .markSorted(let i):
                    mappedStep = .markSorted(i + start)
                case .completed:
                    mappedStep = step
                case .merge(let i, let value):
                    mappedStep = .merge(i + start, value)
                case .bucket(let i, let j):
                    mappedStep = .bucket(i + start, j)
                }
                
                // Update the original array with the subarray changes
                var tempArr = arr
                for (i, val) in subArray.enumerated() {
                    tempArr[start + i] = val
                }
                
                return await onStep(mappedStep, tempArr)
            })
            
            // Update the original array with the sorted subarray
            for (i, val) in subArray.enumerated() {
                arr[start + i] = val
            }
            
            return arr
        }
        
        // Recursive case: divide and conquer with merge sort
        let mid = start + (end - start) / 2
        
        // Sort left half
        arr = await timeSortHelper(array: arr, start: start, end: mid, onStep: onStep)
        
        // Sort right half
        arr = await timeSortHelper(array: arr, start: mid + 1, end: end, onStep: onStep)
        
        // Merge the sorted halves
        await MergeSort.merge(array: &arr, start: start, mid: mid, end: end, onStep: onStep)
        return arr
    }
    
    /// Helper function for Time Sort to perform insertion sort on a subarray
    /// - Parameters:
    ///   - array: Subarray to sort
    ///   - onStep: Callback that's called for each step in the algorithm
    /// - Returns: Sorted subarray
    private static func insertionSortSubarray<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        var arr = array
        let n = arr.count
        
        for i in 1..<n {
            let key = arr[i]
            var j = i - 1
            
            // Compare elements and shift as needed
            while j >= 0 {
                let shouldContinue = await onStep(SortingStep.compare(j, i), arr)
                if !shouldContinue { return arr }
                
                if arr[j] > key {
                    arr[j + 1] = arr[j]
                    let shouldContinue = await onStep(SortingStep.swap(j, j + 1), arr)
                    if !shouldContinue { return arr }
                    j -= 1
                } else {
                    break
                }
            }
            
            arr[j + 1] = key
            let shouldContinue = await onStep(SortingStep.markSorted(i), arr)
            if !shouldContinue { return arr }
        }
        
        return arr
    }
}
