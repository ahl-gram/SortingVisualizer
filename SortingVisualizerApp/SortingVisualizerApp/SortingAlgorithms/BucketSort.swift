//
//  SortingAlgorithms.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import Foundation
import SwiftUI

/// Pure bucket sort algorithm that reports steps through a callback
/// - Parameters:
///   - array: Array to sort (values should be in range 0...100)
///   - onStep: Callback that's called for each step in the algorithm
/// - Returns: Sorted array
enum BucketSort {
    static func bucketSort<T: BinaryInteger>(
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
        
        // Find min and max to determine bucket ranges
        guard let minValue = arr.min(), let maxValue = arr.max() else {
            _ = await onStep(SortingStep.completed, arr)
            return arr
        }
        
        // Determine the number of buckets (use approximate square root of array size)
        let bucketCount = max(10, Int(sqrt(Double(n))))
        
        // Calculate the range of each bucket
        let range = max(1, Int((maxValue - minValue) / T(bucketCount) + 1))
        
        // Create buckets
        var buckets = Array(repeating: [T](), count: bucketCount)
        
        // Distribute elements into buckets
        for i in 0..<n {
            let value = arr[i]
            let bucketIndex = min(bucketCount - 1, Int((value - minValue) / T(range)))
            
            // Report bucket assignment
            _ = await onStep(SortingStep.bucket(i, bucketIndex), arr)
            
            buckets[bucketIndex].append(value)
        }
        
        // Sort each bucket (using insertion sort for efficiency with small arrays)
        for b in 0..<bucketCount {
            buckets[b] = await insertionSortForBucket(array: buckets[b], bucketIndex: b, onStep: onStep)
        }
        
        // Combine the buckets back into the original array
        var index = 0
        for b in 0..<bucketCount {
            for value in buckets[b] {
                arr[index] = value
                
                // Report merge operation
                _ = await onStep(SortingStep.merge(index, value), arr)
                
                // Mark as sorted
                _ = await onStep(SortingStep.markSorted(index), arr)
                
                index += 1
            }
        }
        
        // Report completion
        _ = await onStep(SortingStep.completed, arr)
        
        return arr
    }
    
    /// Helper function to sort buckets using insertion sort
    private static func insertionSortForBucket<T: Comparable>(
        array: [T],
        bucketIndex: Int,
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        var arr = array
        let n = arr.count
        
        if n <= 1 {
            return arr
        }
        
        for i in 1..<n {
            let key = arr[i]
            var j = i - 1
            
            while j >= 0 && arr[j] > key {
                // We don't report the individual steps for bucket sorting
                // as it would be too granular and confusing in the visualization
                arr[j + 1] = arr[j]
                j -= 1
            }
            
            arr[j + 1] = key
        }
        
        return arr
    }
}