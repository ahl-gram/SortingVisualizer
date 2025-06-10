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
    case shell = "Shell Sort"
    case cube = "Cube Sort"
    
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
        case .shell:
            return "An in-place comparison sort that generalizes insertion sort by allowing the exchange of items that are far apart. It uses a gap sequence to compare elements that are a certain distance apart, reducing the number of comparisons needed. Average time complexity: O(n (log n)²)"
        case .cube:
            return "A sort that works by dividing an array into small cubes, sorting each cube, and then merging the cubes back together. Average time complexity: O(n log n)"
        }
    }

        /// Maps algorithm type to the corresponding sorting function
     static func getSortingFunction(for type: SortingAlgorithmType) -> ([Int], @escaping SortingStepType.StepCallback<Int>) async -> [Int] {
        switch type {
        case .bubble:
            return BubbleSort.sort
        case .quick:
            return QuickSort.sort
        case .merge:
            return MergeSort.sort
        case .insertion:
            return InsertionSort.sort
        case .heap:
            return HeapSort.sort
        case .radix:
            return RadixSort.sort
        case .time:
            return TimeSort.sort
        case .bucket:
            return BucketSort.sort
        case .selection:
            return SelectionSort.sort
        case .shell:
            return ShellSort.sort
        case .cube:
            return CubeSort.sort
        }
    }
}


