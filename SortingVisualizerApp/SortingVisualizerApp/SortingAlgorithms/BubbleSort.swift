import Foundation
import SwiftUI

/// Pure bubble sort algorithm that reports steps through a callback
/// - Parameters:
///   - array: Array to sort
///   - onStep: Callback that's called for each step in the algorithm
/// - Returns: Sorted array
enum BubbleSort {
    static func sort<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        var arr = array
        let n = arr.count
        
        // Check for empty or single-element array
        if n <= 1 {
            // user sortingstep.swift
            _ = await onStep(SortingStep.completed, arr)
            return arr
        }
        
        var swapped = false
        
        for i in 0..<n {
            swapped = false
            
            for j in 0..<n - i - 1 {
                // Report comparison step
                let shouldContinue = await onStep(SortingStep.compare(j, j + 1), arr)
                if !shouldContinue { return arr } // Allow cancellation
                
                if arr[j] > arr[j + 1] {
                    // Swap elements
                    arr.swapAt(j, j + 1)
                    swapped = true
                    
                    // Report swap step
                    let shouldContinue = await onStep(SortingStep.swap(j, j + 1), arr)
                    if !shouldContinue { return arr } // Allow cancellation
                }
            }
            
            // Mark element as sorted
            let shouldContinue = await onStep(SortingStep.markSorted(n - i - 1), arr)
            if !shouldContinue { return arr } // Allow cancellation
            
            if !swapped {
                break // Array is sorted
            }
        }
        
        // Report completion
        _ = await onStep(SortingStep.completed, arr)
        
        return arr
    }
}