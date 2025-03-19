import Foundation
import SwiftUI

/// Pure cube sort algorithm that reports steps through a callback
/// - Parameters:
///   - array: Array to sort
///   - onStep: Callback that's called for each step in the algorithm
/// - Returns: Sorted array
enum CubeSort {
    static func sort<T: Comparable>(
        array: [T],
        onStep: SortingStepType.StepCallback<T>
    ) async -> [T] {
        var arr = array
        let n = arr.count
        
        // Quick return for empty or single-element arrays
        if n <= 1 {
            _ = await onStep(SortingStep.completed, arr)
            return arr
        }
        
        // For demonstration purposes, let's do a modified multi-dimensional sort
        // that more clearly shows the 3D aspect
        
        // First, sort small segments (like 3 elements) throughout the array
        let segmentSize = min(3, n)
        for startIdx in stride(from: 0, to: n, by: segmentSize) {
            let endIdx = min(startIdx + segmentSize, n)
            await sortSegment(&arr, from: startIdx, to: endIdx, onStep: onStep)
        }
        
        // Next, merge adjacent segments (representing "faces" of the cube)
        var mergeSize = segmentSize
        while mergeSize < n {
            let doubleSize = mergeSize * 2
            
            for startIdx in stride(from: 0, to: n, by: doubleSize) {
                let midIdx = min(startIdx + mergeSize, n)
                let endIdx = min(startIdx + doubleSize, n)
                
                if midIdx < endIdx {
                    await merge(&arr, start: startIdx, mid: midIdx, end: endIdx, onStep: onStep)
                }
            }
            
            mergeSize = doubleSize
        }
        
        // Always run a final complete sort to ensure correctness
        // This represents the final consolidation of all dimensions
        await finalSort(&arr, onStep: onStep)
        
        // Report completion
        _ = await onStep(SortingStep.completed, arr)
        
        return arr
    }
    
    // Sort a small segment of the array using insertion sort
    private static func sortSegment<T: Comparable>(
        _ array: inout [T],
        from start: Int,
        to end: Int,
        onStep: SortingStepType.StepCallback<T>
    ) async {
        // Highlight that we're working on a segment as a "cube face"
        for i in start..<end {
            _ = await onStep(SortingStep.highlight(i), array)
        }
        
        // Simple insertion sort for the segment
        for i in (start+1)..<end {
            let key = array[i]
            var j = i - 1
            
            while j >= start {
                // Report comparison
                let shouldContinue = await onStep(SortingStep.compare(j, i), array)
                if !shouldContinue { return }
                
                if array[j] > key {
                    // Move elements ahead
                    array[j + 1] = array[j]
                    
                    // Report swap
                    _ = await onStep(SortingStep.swap(j, j + 1), array)
                    
                    j -= 1
                } else {
                    break
                }
            }
            
            // Place key in correct position
            array[j + 1] = key
        }
        
        // Unhighlight the segment
        for i in start..<end {
            _ = await onStep(SortingStep.unhighlight(i), array)
        }
    }
    
    // Merge two adjacent sorted segments
    private static func merge<T: Comparable>(
        _ array: inout [T],
        start: Int,
        mid: Int,
        end: Int,
        onStep: SortingStepType.StepCallback<T>
    ) async {
        // Create temporary arrays
        let leftSize = mid - start
        let rightSize = end - mid
        
        var left = [T]()
        var right = [T]()
        
        // Copy data to temp arrays and highlight
        for i in 0..<leftSize {
            left.append(array[start + i])
            _ = await onStep(SortingStep.highlight(start + i), array)
        }
        
        for i in 0..<rightSize {
            right.append(array[mid + i])
            _ = await onStep(SortingStep.highlight(mid + i), array)
        }
        
        // Merge the temp arrays back into array[start...end-1]
        var i = 0, j = 0, k = start
        
        while i < leftSize && j < rightSize {
            // Report comparison between elements from left and right
            let leftIndex = start + i
            let rightIndex = mid + j
            let shouldContinue = await onStep(SortingStep.compare(leftIndex, rightIndex), array)
            if !shouldContinue { return }
            
            if left[i] <= right[j] {
                array[k] = left[i]
                // Only report as swap if value actually changed
                if k != start + i {
                    _ = await onStep(SortingStep.swap(start + i, k), array)
                }
                i += 1
            } else {
                array[k] = right[j]
                // Only report as swap if value actually changed
                if k != mid + j {
                    _ = await onStep(SortingStep.swap(mid + j, k), array)
                }
                j += 1
            }
            k += 1
        }
        
        // Copy remaining elements of left
        while i < leftSize {
            array[k] = left[i]
            if k != start + i {
                _ = await onStep(SortingStep.swap(start + i, k), array)
            }
            i += 1
            k += 1
        }
        
        // Copy remaining elements of right
        while j < rightSize {
            array[k] = right[j]
            if k != mid + j {
                _ = await onStep(SortingStep.swap(mid + j, k), array)
            }
            j += 1
            k += 1
        }
        
        // Unhighlight all elements
        for i in start..<end {
            _ = await onStep(SortingStep.unhighlight(i), array)
        }
    }
    
    // Complete final sort using a standard sorting algorithm
    // This represents combining all dimensions of the cube
    private static func finalSort<T: Comparable>(
        _ array: inout [T],
        onStep: SortingStepType.StepCallback<T>
    ) async {
        let n = array.count
        
        // Highlight the entire array to show we're doing the final consolidation
        for i in 0..<n {
            _ = await onStep(SortingStep.highlight(i), array)
        }
        
        // Use insertion sort for the final pass
        for i in 1..<n {
            let key = array[i]
            var j = i - 1
            
            // Compare with all previous elements
            while j >= 0 {
                // Report comparison
                let shouldContinue = await onStep(SortingStep.compare(j, i), array)
                if !shouldContinue { return }
                
                if array[j] > key {
                    // Move elements ahead
                    array[j + 1] = array[j]
                    
                    // Report swap
                    _ = await onStep(SortingStep.swap(j, j + 1), array)
                    
                    j -= 1
                } else {
                    break
                }
            }
            
            // Place key in correct position
            array[j + 1] = key
        }
        
        // Unhighlight all elements
        for i in 0..<n {
            _ = await onStep(SortingStep.unhighlight(i), array)
        }
    }
}