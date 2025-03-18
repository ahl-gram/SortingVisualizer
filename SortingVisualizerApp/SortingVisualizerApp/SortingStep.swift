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

enum SortingStepType {
    /// Callback signature for reporting sorting steps
    typealias StepCallback<T> = (SortingStep<T>, [T]) async -> Bool
}