import Foundation
import SwiftUI

/// Pure heap sort algorithm that reports steps through a callback
/// - Parameters:
///   - array: Array to sort
///   - onStep: Callback that's called for each step in the algorithm
/// - Returns: Sorted array
enum HeapSort {
    static func sort<T: Comparable>(
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
        
        // Build heap (rearrange array)
        for i in stride(from: n / 2 - 1, through: 0, by: -1) {
            await heapify(array: &arr, n: n, i: i, onStep: onStep)
        }
        
        // Extract elements from heap one by one
        for i in stride(from: n - 1, through: 0, by: -1) {
            // Move current root to end
            arr.swapAt(0, i)
            
            // Report swap
            _ = await onStep(.swap(0, i), arr)
            
            // Mark element as sorted
            _ = await onStep(.markSorted(i), arr)
            
            // Call max heapify on the reduced heap
            await heapify(array: &arr, n: i, i: 0, onStep: onStep)
        }
        
        // Report completion
        _ = await onStep(SortingStep.completed, arr)
        
        return arr
    }
    
    /// Heapify function for heap sort
    private static func heapify<T: Comparable>(
        array: inout [T],
        n: Int,
        i: Int,
        onStep: SortingStepType.StepCallback<T>
    ) async {
        var largest = i     // Initialize largest as root
        let left = 2 * i + 1    // Left child
        let right = 2 * i + 2   // Right child
        
        // If left child is larger than root
        if left < n {
            // Report comparison
            _ = await onStep(SortingStep.compare(left, largest), array)
            
            if array[left] > array[largest] {
                largest = left
            }
        }
        
        // If right child is larger than the current largest
        if right < n {
            // Report comparison
            _ = await onStep(SortingStep.compare(right, largest), array)
            
            if array[right] > array[largest] {
                largest = right
            }
        }
        
        // If largest is not root
        if largest != i {
            // Swap
            array.swapAt(i, largest)
            
            // Report swap
            _ = await onStep(SortingStep.swap(i, largest), array)
            
            // Recursively heapify the affected sub-tree
            await heapify(array: &array, n: n, i: largest, onStep: onStep)
        }
    }
}