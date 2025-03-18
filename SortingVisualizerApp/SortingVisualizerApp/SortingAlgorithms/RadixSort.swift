import Foundation
import SwiftUI

/// Pure radix sort algorithm that reports steps through a callback
/// - Parameters:
///   - array: Array to sort (needs to be of Integer type)
///   - onStep: Callback that's called for each step in the algorithm
/// - Returns: Sorted array
enum RadixSort {
    static func sort<T: BinaryInteger>(
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
        
        // Find the maximum number to determine the number of digits
        guard let maxNum = arr.max() else {
            _ = await onStep(SortingStep.completed, arr)
            return arr
        }
        
        // Do counting sort for every digit
        // Instead of passing digit number, pass the actual power of 10
        var exp: T = 1
        while maxNum / exp > 0 {
                await countingSortByDigit(array: &arr, exp: exp, onStep: onStep)
            exp *= 10
        }
        
        // Mark all elements as sorted at the end
        for i in 0..<n {
            _ = await onStep(SortingStep.markSorted(i), arr)
        }
        
        // Report completion
        _ = await onStep(SortingStep.completed, arr)
        
        return arr
    }
    
    /// Counting sort for a specific digit (used by Radix sort)
    private static func countingSortByDigit<T: BinaryInteger>(
        array: inout [T],
        exp: T,
        onStep: SortingStepType.StepCallback<T>
    ) async {
        let n = array.count
        var output = Array(repeating: T.zero, count: n)
        var count = Array(repeating: 0, count: 10)
        
        // Store count of occurrences in count[]
        for i in 0..<n {
            let index = Int((array[i] / exp) % 10)
            count[index] += 1
            
            // Report bucket assignment
            _ = await onStep(SortingStep.bucket(i, index), array)
        }
        
        // Change count[i] so that count[i] now contains the position of this digit in output[]
        for i in 1..<10 {
            count[i] += count[i - 1]
        }
        
        // Build the output array
        for i in stride(from: n - 1, through: 0, by: -1) {
            let index = Int((array[i] / exp) % 10)
            let outputIndex = count[index] - 1
            output[outputIndex] = array[i]
            count[index] -= 1
            
            // Report element movement
            _ = await onStep(SortingStep.merge(outputIndex, array[i]), array)
        }
        
        // Copy the output array back to the input array
        for i in 0..<n {
            if array[i] != output[i] {
                array[i] = output[i]
                _ = await onStep(SortingStep.merge(i, output[i]), array)
            }
        }
    }
}