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
    case selection = "Selection Sort"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .bubble:
            return "A simple comparison-based sort that repeatedly steps through the list, compares adjacent elements, and swaps them if they are in the wrong order. Average time complexity: O(n²)"
        case .quick:
            return "A divide-and-conquer sort that works by selecting a 'pivot' element and partitioning the array around the pivot. Average time complexity: O(n log n)"
        case .merge:
            return "A divide-and-conquer sort that divides the array into halves, sorts them separately, and then merges the sorted halves. Average time complexity: O(n log n)"
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
        case .selection:
            return "A simple in-place comparison sort that divides the input into a sorted and an unsorted region. It repeatedly finds the minimum element from the unsorted region and puts it at the end of the sorted region. Average time complexity: O(n²)"
        }
    }
}

/// Pure sorting algorithms without visualization or audio logic
enum SortingAlgorithms {
    
    // MARK: - Bubble Sort
    static func bubbleSort<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        return await BubbleSort.bubbleSort(array: array, onStep: onStep)
    }
    
    // MARK: - Quick Sort
    static func quickSort<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        return await QuickSort.quickSort(array: array, onStep: onStep)
    }
    
    // MARK: - Merge Sort
    static func mergeSort<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        return await MergeSort.mergeSort(array: array, onStep: onStep)
    }
    
    // MARK: - Insertion Sort
    static func insertionSort<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        return await InsertionSort.insertionSort(array: array, onStep: onStep)
    }
    
    // MARK: - Heap Sort
    static func heapSort<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        return await HeapSort.heapSort(array: array, onStep: onStep)
    }
    
    // MARK: - Radix Sort
    static func radixSort<T: BinaryInteger>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        return await RadixSort.radixSort(array: array, onStep: onStep)
    }
    
    // MARK: - Time Sort
    static func timeSort<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        return await TimeSort.timeSort(array: array, onStep: onStep)
    }
    
    // MARK: - Bucket Sort
    static func bucketSort<T: BinaryInteger>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        return await BucketSort.bucketSort(array: array, onStep: onStep)
    }
    
    // MARK: - Selection Sort
    static func selectionSort<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        return await SelectionSort.selectionSort(array: array, onStep: onStep)
    }
}
