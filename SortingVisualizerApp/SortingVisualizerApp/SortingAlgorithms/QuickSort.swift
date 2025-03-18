import Foundation
import SwiftUI

/// Pure quicksort algorithm that reports steps through a callback
/// - Parameters:
///   - array: Array to sort
///   - onStep: Callback that's called for each step in the algorithm
/// - Returns: Sorted array
enum QuickSort {
    static func sort<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        var arr = array
        
        // Check for empty or single-element array
        if arr.count <= 1 {
            _ = await onStep(SortingStep.completed, arr)
            return arr
        }
        
        // Start recursive quicksort
        await quickSortHelper(
            array: &arr,
            low: 0,
            high: arr.count - 1,
            onStep: onStep
        )
        
        // Report completion
        _ = await onStep(SortingStep.completed, arr)
        
        return arr
    }
    
    /// Helper function for quicksort
    private static func quickSortHelper<T: Comparable>(
        array: inout [T],
        low: Int,
        high: Int,
        onStep: SortingStepType.StepCallback<T>
    ) async {
        if low >= high {
            // Base case: segment is already sorted
            _ = await onStep(SortingStep.markSorted(low), array)
            return
        }
        
        // Partition and get pivot index
        let pivotIndex = await partition(
            array: &array,
            low: low,
            high: high,
            onStep: onStep
        )
        
        // Mark pivot as sorted
        _ = await onStep(SortingStep.markSorted(pivotIndex), array)
        
        // Sort subarrays
        if pivotIndex > low {
            await quickSortHelper(
                array: &array,
                low: low,
                high: pivotIndex - 1,
                onStep: onStep
            )
        }
        
        if pivotIndex < high {
            await quickSortHelper(
                array: &array,
                low: pivotIndex + 1,
                high: high,
                onStep: onStep
            )
        }
    }
    
    /// Partition function for quicksort
    private static func partition<T: Comparable>(
        array: inout [T],
        low: Int,
        high: Int,
        onStep: SortingStepType.StepCallback<T>
    ) async -> Int {
        // Use rightmost element as pivot
        let pivot = array[high]
        
        // Report pivot selection
        _ = await onStep(.compare(high, high), array)
        
        // Index of smaller element
        var i = low - 1
        
        // Compare each element with pivot
        for j in low..<high {
            // Report comparison
            let shouldContinue = await onStep(SortingStep.compare(j, high), array)
            if !shouldContinue { return i + 1 } // Allow cancellation
            
            // If current element <= pivot
            if array[j] < pivot {
                // Increment index of smaller element
                i += 1
                
                // Swap elements
                array.swapAt(i, j)
                
                // Report swap
                _ = await onStep(SortingStep.swap(i, j), array)
            }
        }
        
        // Swap pivot to its correct position
        i += 1
        array.swapAt(i, high)
        
        // Report final swap
        _ = await onStep(SortingStep.swap(i, high), array)
        
        return i
    }
}
