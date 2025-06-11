import Foundation
import SwiftUI

/// An implementation of Bogo Sort (also known as Permutation Sort or Stupid Sort).
/// This is a highly inefficient sorting algorithm used for educational or humorous purposes.
/// It works by repeatedly shuffling the array until it happens to be sorted.
enum BogoSort {
    /// Sorts an array using the Bogo Sort algorithm.
    ///
    /// - Warning: This algorithm is not practical for any real-world use. Its performance is
    ///   unbounded, and for any array with more than a handful of elements, it will likely
    ///   run for an exceptionally long time (potentially years or longer).
    ///
    /// - Parameters:
    ///   - array: The array to be sorted.
    ///   - onStep: A callback to report each step (i.e., each shuffle) of the sorting process.
    /// - Returns: The sorted array.
    static func sort<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        var arr = array

        while await !isSorted(array: arr, onStep: onStep) {
            // If sorting was cancelled during the check, exit.
            if Task.isCancelled { return arr }

            // Shuffle the array using the Fisher-Yates algorithm to visualize swaps.
            for i in (1..<arr.count).reversed() {
                let j = Int.random(in: 0...i)
                
                // Report the swap for visualization
                arr.swapAt(i, j)
                if await !onStep(.swap(i, j), arr) {
                    return arr // Allow cancellation
                }
            }
        }

        // Once sorted, mark all elements as sorted and complete.
        for i in 0..<arr.count {
            _ = await onStep(.markSorted(i), arr)
        }
        _ = await onStep(.completed, arr)

        return arr
    }

    /// Checks if the array is sorted.
    /// This function also reports comparison steps to the visualizer.
    private static func isSorted<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> Bool {
        guard array.count > 1 else { return true }

        for i in 0..<(array.count - 1) {
            // Report the comparison to the visualizer.
            if await !onStep(.compare(i, i + 1), array) {
                // If the visualization is cancelled, we should stop.
                return false // Returning false will stop the main loop.
            }

            if array[i] > array[i + 1] {
                // Found an unsorted pair.
                return false
            }
        }

        // If we get through the whole loop, the array is sorted.
        return true
    }
}
