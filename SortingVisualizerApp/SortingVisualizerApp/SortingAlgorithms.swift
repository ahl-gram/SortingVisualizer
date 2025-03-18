//
//  SortingAlgorithms.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import Foundation
import SwiftUI

// Define the available sorting algorithms
enum SortingAlgorithmType: String, CaseIterable, Identifiable {
    case bubble = "Bubble Sort"
    case quick = "Quick Sort"
    case merge = "Merge Sort"
    case insertion = "Insertion Sort"
    case heap = "Heap Sort"
    case radix = "Radix Sort"
    case time = "Time Sort"
    case bucket = "Bucket Sort"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .bubble:
            return "A simple comparison-based sort that repeatedly steps through the list, compares adjacent elements, and swaps them if they are in the wrong order. Average time complexity: O(n²)"
        case .quick:
            return "A divide-and-conquer sort that works by selecting a 'pivot' element and partitioning the array around the pivot. Average time complexity: O(n log n)"
        case .merge:
            return "An efficient, stable, divide-and-conquer sort that divides the array into halves, sorts them separately, and then merges the sorted halves. Average time complexity: O(n log n)"
        case .insertion:
            return "A simple sort that builds the final sorted array one item at a time, similar to how people sort playing cards in their hands. Average time complexity: O(n²)"
        case .heap:
            return "A comparison-based sort that uses a binary heap data structure. It transforms the array into a heap, then repeatedly extracts the maximum element and rebuilds the heap. Average time complexity: O(n log n)"
        case .radix:
            return "A non-comparative sort that sorts data by processing individual digits. It groups numbers by digit values and sorts from least to most significant digit. Average time complexity: O(nk) where k is the number of digits"
        case .time:
            return "A hybrid sort that combines insertion sort for small subarrays with merge sort for larger arrays. It adapts based on the input size for optimal performance. Average time complexity: O(n log n)"
        case .bucket:
            return "A distribution sort that distributes elements into a number of buckets, sorts each bucket individually, and then concatenates the buckets. Performs best with uniform distributions. Average time complexity: O(n+k), where k is the number of buckets"
        }
    }
}

/// Pure sorting algorithms without visualization or audio logic
enum SortingAlgorithms {
    
    // MARK: - Sorting Step Types
    
    /// Represents a step in the sorting process
    enum SortingStep<T> {
        /// Comparing two elements
        case compare(Int, Int)
        /// Swapping two elements
        case swap(Int, Int)
        /// Merging operation (specific to merge sort)
        case merge(Int, T)
        /// Marking an element as sorted
        case markSorted(Int)
        /// Bucket operation for non-comparison sorts (like radix)
        case bucket(Int, Int)
        /// Algorithm completed
        case completed
    }
    
    /// Callback signature for reporting sorting steps
    typealias StepCallback<T> = (SortingStep<T>, [T]) async -> Bool
    
    // MARK: - Bubble Sort
    
    /// Pure bubble sort algorithm that reports steps through a callback
    /// - Parameters:
    ///   - array: Array to sort
    ///   - onStep: Callback that's called for each step in the algorithm
    /// - Returns: Sorted array
    static func bubbleSort<T: Comparable>(
        array: [T],
        onStep: StepCallback<T>
    ) async -> [T] {
        var arr = array
        let n = arr.count
        
        // Check for empty or single-element array
        if n <= 1 {
            _ = await onStep(.completed, arr)
            return arr
        }
        
        var swapped = false
        
        for i in 0..<n {
            swapped = false
            
            for j in 0..<n - i - 1 {
                // Report comparison step
                let shouldContinue = await onStep(.compare(j, j + 1), arr)
                if !shouldContinue { return arr } // Allow cancellation
                
                if arr[j] > arr[j + 1] {
                    // Swap elements
                    arr.swapAt(j, j + 1)
                    swapped = true
                    
                    // Report swap step
                    let shouldContinue = await onStep(.swap(j, j + 1), arr)
                    if !shouldContinue { return arr } // Allow cancellation
                }
            }
            
            // Mark element as sorted
            let shouldContinue = await onStep(.markSorted(n - i - 1), arr)
            if !shouldContinue { return arr } // Allow cancellation
            
            if !swapped {
                break // Array is sorted
            }
        }
        
        // Report completion
        _ = await onStep(.completed, arr)
        
        return arr
    }
    
    // MARK: - Quick Sort
    
    /// Pure quicksort algorithm that reports steps through a callback
    /// - Parameters:
    ///   - array: Array to sort
    ///   - onStep: Callback that's called for each step in the algorithm
    /// - Returns: Sorted array
    static func quickSort<T: Comparable>(
        array: [T],
        onStep: StepCallback<T>
    ) async -> [T] {
        var arr = array
        
        // Check for empty or single-element array
        if arr.count <= 1 {
            _ = await onStep(.completed, arr)
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
        _ = await onStep(.completed, arr)
        
        return arr
    }
    
    /// Helper function for quicksort
    private static func quickSortHelper<T: Comparable>(
        array: inout [T],
        low: Int,
        high: Int,
        onStep: StepCallback<T>
    ) async {
        if low >= high {
            // Base case: segment is already sorted
            _ = await onStep(.markSorted(low), array)
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
        _ = await onStep(.markSorted(pivotIndex), array)
        
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
        onStep: StepCallback<T>
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
            let shouldContinue = await onStep(.compare(j, high), array)
            if !shouldContinue { return i + 1 } // Allow cancellation
            
            // If current element <= pivot
            if array[j] < pivot {
                // Increment index of smaller element
                i += 1
                
                // Swap elements
                array.swapAt(i, j)
                
                // Report swap
                _ = await onStep(.swap(i, j), array)
            }
        }
        
        // Swap pivot to its correct position
        i += 1
        array.swapAt(i, high)
        
        // Report final swap
        _ = await onStep(.swap(i, high), array)
        
        return i
    }
    
    // MARK: - Merge Sort
    
    /// Pure merge sort algorithm that reports steps through a callback
    /// - Parameters:
    ///   - array: Array to sort
    ///   - onStep: Callback that's called for each step in the algorithm
    /// - Returns: Sorted array
    static func mergeSort<T: Comparable>(
        array: [T],
        onStep: StepCallback<T>
    ) async -> [T] {
        var arr = array
        
        // Check for empty or single-element array
        if arr.count <= 1 {
            _ = await onStep(.completed, arr)
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
        _ = await onStep(.completed, arr)
        
        return arr
    }
    
    /// Helper function for merge sort
    private static func mergeSortHelper<T: Comparable>(
        array: inout [T],
        start: Int,
        end: Int,
        onStep: StepCallback<T>
    ) async {
        // Base case: if the array segment has 1 or fewer elements, it's already sorted
        if start >= end {
            if start == end {
                // Mark the single element as sorted
                _ = await onStep(.markSorted(start), array)
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
        onStep: StepCallback<T>
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
                    _ = await onStep(.merge(k, leftArray[i]), array)
                }
                i += 1
            } else {
                // If the current element in the right array is smaller
                if array[k] != rightArray[j] {
                    // Update the element in the main array
                    array[k] = rightArray[j]
                    
                    // Report as a merge operation with the new value
                    _ = await onStep(.merge(k, rightArray[j]), array)
                }
                j += 1
            }
            k += 1
        }
        
        // Copy any remaining elements from the left array
        while i < leftSize {
            if array[k] != leftArray[i] {
                array[k] = leftArray[i]
                _ = await onStep(.merge(k, leftArray[i]), array)
            }
            i += 1
            k += 1
        }
        
        // Copy any remaining elements from the right array
        while j < rightSize {
            if array[k] != rightArray[j] {
                array[k] = rightArray[j]
                _ = await onStep(.merge(k, rightArray[j]), array)
            }
            j += 1
            k += 1
        }
        
        // Mark all elements in this merged segment as sorted
        for index in start...end {
            _ = await onStep(.markSorted(index), array)
        }
    }
    
    // MARK: - Insertion Sort
    
    /// Pure insertion sort algorithm that reports steps through a callback
    /// - Parameters:
    ///   - array: Array to sort
    ///   - onStep: Callback that's called for each step in the algorithm
    /// - Returns: Sorted array
    static func insertionSort<T: Comparable>(
        array: [T],
        onStep: StepCallback<T>
    ) async -> [T] {
        var arr = array
        let n = arr.count
        
        // Check for empty or single-element array
        if n <= 1 {
            _ = await onStep(.completed, arr)
            return arr
        }
        
        // First element is already "sorted"
        _ = await onStep(.markSorted(0), arr)
        
        // Start from the second element
        for i in 1..<n {
            // Store the current element to insert it in the correct position
            let key = arr[i]
            var j = i - 1
            
            // Compare key with each element on the left until a smaller element is found
            while j >= 0 {
                // Report comparison
                let shouldContinue = await onStep(.compare(j, i), arr)
                if !shouldContinue { return arr } // Allow cancellation
                
                if arr[j] > key {
                    // Move elements greater than key to one position ahead
                    arr[j + 1] = arr[j]
                    
                    // Report swap
                    _ = await onStep(.swap(j, j + 1), arr)
                    
                    j -= 1
                } else {
                    // Found the correct position
                    break
                }
            }
            
            // Place key at its correct position
            arr[j + 1] = key
            
            // Mark the element as sorted
            _ = await onStep(.markSorted(i), arr)
        }
        
        // Report completion
        _ = await onStep(.completed, arr)
        
        return arr
    }
    
    // MARK: - Heap Sort
    
    /// Pure heap sort algorithm that reports steps through a callback
    /// - Parameters:
    ///   - array: Array to sort
    ///   - onStep: Callback that's called for each step in the algorithm
    /// - Returns: Sorted array
    static func heapSort<T: Comparable>(
        array: [T],
        onStep: StepCallback<T>
    ) async -> [T] {
        var arr = array
        let n = arr.count
        
        // Check for empty or single-element array
        if n <= 1 {
            _ = await onStep(.completed, arr)
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
        _ = await onStep(.completed, arr)
        
        return arr
    }
    
    /// Heapify function for heap sort
    private static func heapify<T: Comparable>(
        array: inout [T],
        n: Int,
        i: Int,
        onStep: StepCallback<T>
    ) async {
        var largest = i     // Initialize largest as root
        let left = 2 * i + 1    // Left child
        let right = 2 * i + 2   // Right child
        
        // If left child is larger than root
        if left < n {
            // Report comparison
            _ = await onStep(.compare(left, largest), array)
            
            if array[left] > array[largest] {
                largest = left
            }
        }
        
        // If right child is larger than the current largest
        if right < n {
            // Report comparison
            _ = await onStep(.compare(right, largest), array)
            
            if array[right] > array[largest] {
                largest = right
            }
        }
        
        // If largest is not root
        if largest != i {
            // Swap
            array.swapAt(i, largest)
            
            // Report swap
            _ = await onStep(.swap(i, largest), array)
            
            // Recursively heapify the affected sub-tree
            await heapify(array: &array, n: n, i: largest, onStep: onStep)
        }
    }
    
    // MARK: - Radix Sort
    
    /// Pure radix sort algorithm that reports steps through a callback
    /// - Parameters:
    ///   - array: Array to sort (needs to be of Integer type)
    ///   - onStep: Callback that's called for each step in the algorithm
    /// - Returns: Sorted array
    static func radixSort<T: BinaryInteger>(
        array: [T],
        onStep: StepCallback<T>
    ) async -> [T] {
        var arr = array
        let n = arr.count
        
        // Check for empty or single-element array
        if n <= 1 {
            _ = await onStep(.completed, arr)
            return arr
        }
        
        // Find the maximum number to determine the number of digits
        guard let maxNum = arr.max() else {
            _ = await onStep(.completed, arr)
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
            _ = await onStep(.markSorted(i), arr)
        }
        
        // Report completion
        _ = await onStep(.completed, arr)
        
        return arr
    }
    
    /// Counting sort for a specific digit (used by Radix sort)
    private static func countingSortByDigit<T: BinaryInteger>(
        array: inout [T],
        exp: T,
        onStep: StepCallback<T>
    ) async {
        let n = array.count
        var output = Array(repeating: T.zero, count: n)
        var count = Array(repeating: 0, count: 10)
        
        // Store count of occurrences in count[]
        for i in 0..<n {
            let index = Int((array[i] / exp) % 10)
            count[index] += 1
            
            // Report bucket assignment
            _ = await onStep(.bucket(i, index), array)
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
            _ = await onStep(.merge(outputIndex, array[i]), array)
        }
        
        // Copy the output array back to the input array
        for i in 0..<n {
            if array[i] != output[i] {
                array[i] = output[i]
                _ = await onStep(.merge(i, output[i]), array)
            }
        }
    }
    
    // MARK: - Time Sort
    
    /// Time Sort implementation - a hybrid algorithm combining insertion sort for small arrays and merge sort for larger ones
    /// - Parameters:
    ///   - array: Array to sort
    ///   - onStep: Callback that's called for each step in the algorithm
    /// - Returns: Sorted array
    static func timeSort<T: Comparable>(
        array: [T],
        onStep: StepCallback<T>
    ) async -> [T] {
        var arr = array
        let n = arr.count
        
        // Check for empty or single-element array
        if n <= 1 {
            _ = await onStep(.completed, arr)
            return arr
        }
        
        // Use insertion sort for small arrays (less than 16 elements)
        if n < 16 {
            return await insertionSort(array: arr, onStep: onStep)
        }
        
        // For larger arrays, use merge sort with insertion sort for small subarrays
        return await timeSortHelper(array: arr, start: 0, end: n - 1, onStep: onStep)
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
        onStep: StepCallback<T>
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
        await merge(array: &arr, start: start, mid: mid, end: end, onStep: onStep)
        return arr
    }
    
    /// Helper function for Time Sort to perform insertion sort on a subarray
    /// - Parameters:
    ///   - array: Subarray to sort
    ///   - onStep: Callback that's called for each step in the algorithm
    /// - Returns: Sorted subarray
    private static func insertionSortSubarray<T: Comparable>(
        array: [T],
        onStep: StepCallback<T>
    ) async -> [T] {
        var arr = array
        let n = arr.count
        
        for i in 1..<n {
            let key = arr[i]
            var j = i - 1
            
            // Compare elements and shift as needed
            while j >= 0 {
                let shouldContinue = await onStep(.compare(j, i), arr)
                if !shouldContinue { return arr }
                
                if arr[j] > key {
                    arr[j + 1] = arr[j]
                    let shouldContinue = await onStep(.swap(j, j + 1), arr)
                    if !shouldContinue { return arr }
                    j -= 1
                } else {
                    break
                }
            }
            
            arr[j + 1] = key
            let shouldContinue = await onStep(.markSorted(i), arr)
            if !shouldContinue { return arr }
        }
        
        return arr
    }
    
    // MARK: - Bucket Sort
    
    /// Pure bucket sort algorithm that reports steps through a callback
    /// - Parameters:
    ///   - array: Array to sort (values should be in range 0...100)
    ///   - onStep: Callback that's called for each step in the algorithm
    /// - Returns: Sorted array
    static func bucketSort<T: BinaryInteger>(
        array: [T],
        onStep: StepCallback<T>
    ) async -> [T] {
        var arr = array
        let n = arr.count
        
        // Check for empty or single-element array
        if n <= 1 {
            _ = await onStep(.completed, arr)
            return arr
        }
        
        // Find min and max to determine bucket ranges
        guard let minValue = arr.min(), let maxValue = arr.max() else {
            _ = await onStep(.completed, arr)
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
            _ = await onStep(.bucket(i, bucketIndex), arr)
            
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
                _ = await onStep(.merge(index, value), arr)
                
                // Mark as sorted
                _ = await onStep(.markSorted(index), arr)
                
                index += 1
            }
        }
        
        // Report completion
        _ = await onStep(.completed, arr)
        
        return arr
    }
    
    /// Helper function to sort buckets using insertion sort
    private static func insertionSortForBucket<T: Comparable>(
        array: [T],
        bucketIndex: Int,
        onStep: StepCallback<T>
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
