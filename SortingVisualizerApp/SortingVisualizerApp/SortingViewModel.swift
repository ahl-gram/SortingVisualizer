//
//  SortingViewModel.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import Foundation
import SwiftUI

class SortingViewModel: ObservableObject {
    @Published var bars: [SortingBar] = []
    @Published var isSorting: Bool = false
    private var sortingTask: Task<Void, Never>?
    
    struct SortingBar: Identifiable {
        let id = UUID()
        var value: Int
        var state: BarState = .unsorted
    }
    
    func randomizeArray(size: Int) {
        // Stop any ongoing sorting
        stopSorting()
        
        // Generate a new array of random values
        var newBars: [SortingBar] = []
        for _ in 0..<size {
            let randomValue = Int.random(in: 10...200)
            newBars.append(SortingBar(value: randomValue))
        }
        
        // Update the bars array
        withAnimation {
            bars = newBars
        }
    }
    
    func startBubbleSort(animationSpeed: Double) {
        // Cancel any existing sorting task
        stopSorting()
        
        // Set sorting flag
        isSorting = true
        
        // Start a new sorting task
        sortingTask = Task {
            await bubbleSort(animationSpeed: animationSpeed)
        }
    }
    
    func stopSorting() {
        sortingTask?.cancel()
        sortingTask = nil
        isSorting = false
        
        // Reset all bars to unsorted state
        for i in 0..<bars.count {
            bars[i].state = .unsorted
        }
    }
    
    private func bubbleSort(animationSpeed: Double) async {
        let n = bars.count
        var swapped = false
        
        for i in 0..<n {
            swapped = false
            
            for j in 0..<n - i - 1 {
                // Check if the task was cancelled
                if Task.isCancelled {
                    return
                }
                
                // Animate comparison
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        bars[j].state = .comparing
                        bars[j + 1].state = .comparing
                    }
                }
                
                // Delay for visualization
                try? await Task.sleep(nanoseconds: UInt64(500_000_000 / animationSpeed))
                
                if bars[j].value > bars[j + 1].value {
                    // Swap the elements
                    await MainActor.run {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            let temp = bars[j]
                            bars[j] = bars[j + 1]
                            bars[j + 1] = temp
                        }
                    }
                    
                    swapped = true
                    
                    // Delay for visualization
                    try? await Task.sleep(nanoseconds: UInt64(500_000_000 / animationSpeed))
                }
                
                // Reset the state of the compared elements
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        bars[j].state = .unsorted
                        if j < n - i - 1 {
                            bars[j + 1].state = .unsorted
                        }
                    }
                }
            }
            
            // Mark the last element as sorted
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.5)) {
                    bars[n - i - 1].state = .sorted
                }
            }
            
            // If no swapping occurred in this pass, the array is already sorted
            if !swapped {
                break
            }
        }
        
        // Mark all remaining elements as sorted
        await MainActor.run {
            markAllAsSorted()
            isSorting = false
        }
    }
    
    private func markAllAsSorted() {
        withAnimation(.easeInOut(duration: 1.0)) {
            for i in 0..<bars.count {
                if bars[i].state != .sorted {
                    bars[i].state = .sorted
                }
            }
        }
    }
} 