import Foundation
import SwiftUI

/// An simplified implementation of CubeSort, using a variation of a bottom-up merge sort.
/// It works by sorting small "cubes" of data first, then merging them.
enum CubeSort {
    /// The size of the initial chunks to be sorted.
    private static let CUBE_SIZE = 16

    /// Sorts an array using the CubeSort algorithm.
    /// - Parameters:
    ///   - array: The array to be sorted.
    ///   - onStep: A callback to report each step of the sorting process for visualization.
    /// - Returns: The sorted array.
    static func sort<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        var arr = array
        let n = arr.count

        if n <= 1 {
            if !arr.isEmpty {
                _ = await onStep(SortingStep.markSorted(0), arr)
            }
            _ = await onStep(SortingStep.completed, arr)
            return arr
        }

        // Phase 1: Sort each "cube" of size CUBE_SIZE using insertion sort.
        for i in stride(from: 0, to: n, by: CUBE_SIZE) {
            let end = min(i + CUBE_SIZE - 1, n - 1)
            await insertionSort(array: &arr, start: i, end: end, onStep: onStep)
        }

        // Phase 2: Iteratively merge the sorted cubes.
        var size = CUBE_SIZE
        while size < n {
            for start in stride(from: 0, to: n - size, by: 2 * size) {
                let mid = start + size - 1
                let end = min(start + 2 * size - 1, n - 1)
                await merge(array: &arr, start: start, mid: mid, end: end, onStep: onStep)
            }
            size *= 2
        }

        _ = await onStep(SortingStep.completed, arr)
        return arr
    }

    /// Sorts a slice of the array using insertion sort.
    private static func insertionSort<T: Comparable>(
        array: inout [T],
        start: Int,
        end: Int,
        onStep: SortingStepType.StepCallback<T>
    ) async {
        for i in (start + 1)...end {
            let key = array[i]
            var j = i - 1
            
            _ = await onStep(.compare(i, i), array)

            while j >= start && array[j] > key {
                if await !onStep(.compare(j, i), array) { return }
                
                array[j + 1] = array[j]
                _ = await onStep(.swap(j + 1, j), array)
                j -= 1
            }
            
            if j + 1 != i {
                array[j + 1] = key
                _ = await onStep(.swap(j + 1, j + 1), array)
            }
        }
    }

    /// Merges two sorted subarrays into a single sorted subarray.
    private static func merge<T: Comparable>(
        array: inout [T],
        start: Int,
        mid: Int,
        end: Int,
        onStep: SortingStepType.StepCallback<T>
    ) async {
        let leftArray = Array(array[start...mid])
        let rightArray = Array(array[(mid + 1)...end])

        var i = 0, j = 0
        var k = start

        while i < leftArray.count && j < rightArray.count {
            if await !onStep(.compare(start + i, mid + 1 + j), array) { return }

            if leftArray[i] <= rightArray[j] {
                if array[k] != leftArray[i] {
                    array[k] = leftArray[i]
                    _ = await onStep(.merge(k, leftArray[i]), array)
                }
                i += 1
            } else {
                if array[k] != rightArray[j] {
                    array[k] = rightArray[j]
                    _ = await onStep(.merge(k, rightArray[j]), array)
                }
                j += 1
            }
            k += 1
        }

        while i < leftArray.count {
            if array[k] != leftArray[i] {
                array[k] = leftArray[i]
                _ = await onStep(.merge(k, leftArray[i]), array)
            }
            i += 1
            k += 1
        }

        while j < rightArray.count {
            if array[k] != rightArray[j] {
                array[k] = rightArray[j]
                _ = await onStep(.merge(k, rightArray[j]), array)
            }
            j += 1
            k += 1
        }
        
        for index in start...end {
            _ = await onStep(.markSorted(index), array)
        }
    }
}
