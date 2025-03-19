import Foundation
import SwiftUI

/// Pure shell sort algorithm that reports steps through a callback
/// - Parameters:
///   - array: Array to sort
///   - onStep: Callback that's called for each step in the algorithm
/// - Returns: Sorted array
enum ShellSort {
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
        
        // Start with a large gap, then reduce it
        var gap = n/2
        
        while gap > 0 {
            // Do a gapped insertion sort
            for i in gap..<n {
                let temp = arr[i]
                var j = i
                
                // Compare elements that are gap distance apart
                while j >= gap {
                    // Report comparison
                    let shouldContinue = await onStep(SortingStep.compare(j-gap, j), arr)
                    if !shouldContinue { return arr } // Allow cancellation
                    
                    if arr[j-gap] > temp {
                        // Move elements gap distance ahead
                        arr[j] = arr[j-gap]
                        
                        // Report swap
                        _ = await onStep(SortingStep.swap(j-gap, j), arr)
                        
                        j -= gap
                    } else {
                        break
                    }
                }
                
                // Put temp in its correct location
                arr[j] = temp
                
                // Mark the element as sorted
                _ = await onStep(SortingStep.markSorted(j), arr)
            }
            
            gap /= 2
        }
        
        // Mark remaining elements as sorted
        for i in 0..<n {
            _ = await onStep(SortingStep.markSorted(i), arr)
        }
        
        // Report completion
        _ = await onStep(SortingStep.completed, arr)
        
        return arr
        
    }
}