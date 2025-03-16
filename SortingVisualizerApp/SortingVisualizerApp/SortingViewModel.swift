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
    @Published var isAudioEnabled: Bool = true {
        didSet {
            audioManager.setAudioEnabled(isAudioEnabled)
        }
    }
    @Published var selectedAlgorithm: SortingAlgorithmType = .bubble
    
    // MARK: - Private properties
    private var sortingTask: Task<Void, Never>?
    private let audioManager = AudioManager()
    
    // Computed property to detect when bars are being compared
    var hasComparingBars: Bool {
        bars.contains { $0.state == .comparing }
    }
    
    struct SortingBar: Identifiable {
        let id = UUID()
        var value: Int
        var state: BarState = .unsorted
    }
    
    // MARK: - Public methods
    func randomizeArray(size: Int) {
        // Stop any ongoing sorting
        stopSorting()
        
        // Generate a new array of bars with unique, uniformly distributed heights
        var newBars: [SortingBar] = []
        
        // Define height parameters
        let minHeight = 10
        
        // Set maximum height based on array size
        let maxHeight: Int
        switch size {
        case 10...30:
            maxHeight = 500
        case 31...60:
            maxHeight = 450
        default:
            maxHeight = 400
        }
        
        // Calculate the range of heights
        let heightRange = maxHeight - minHeight
        
        // Generate a sequence of uniformly distributed heights
        // by dividing the height range into equal steps
        var heights: [Int] = []
        
        // If the array size is small, we can use the exact step size to get perfect distribution
        if size <= heightRange {
            // Calculate step size to evenly distribute heights
            let step = heightRange / (size - 1)
            
            // Generate heights with uniform distribution
            for i in 0..<size {
                heights.append(minHeight + (i * step))
            }
        } else {
            // When we have more bars than the height range, we need to ensure uniqueness
            // by generating all possible heights and then sampling from them
            
            // Generate all possible heights in the range
            var allPossibleHeights = Array(minHeight...maxHeight)
            
            // Shuffle the heights to randomize selection
            allPossibleHeights.shuffle()
            
            // Select 'size' number of unique heights
            heights = Array(allPossibleHeights.prefix(size))
        }
        
        // Shuffle the heights for final randomization
        heights.shuffle()
        
        // Create bars with the unique heights
        for height in heights {
            newBars.append(SortingBar(value: height))
        }
        
        // Update the bars array
        withAnimation {
            bars = newBars
        }
    }
    
    func startSorting(animationSpeed: Double) {
        // Cancel any existing sorting task
        stopSorting()
        
        // Set sorting flag
        isSorting = true
        
        // Start a new sorting task based on selected algorithm
        sortingTask = Task {
            switch selectedAlgorithm {
            case .bubble:
                await SortingAlgorithms.bubbleSort(
                    bars: bars,
                    animationSpeed: animationSpeed,
                    isAudioEnabled: isAudioEnabled,
                    audioManager: audioManager,
                    updateBars: { [weak self] updatedBars in
                        self?.bars = updatedBars
                    },
                    markAllAsSorted: { [weak self] in
                        self?.markAllAsSorted()
                    },
                    onComplete: { [weak self] in
                        guard let self = self else { return }
                        // Run the completion animation before marking sort as done
                        Task {
                            await self.playCompletionAnimation(animationSpeed: animationSpeed)
                            await MainActor.run {
                                self.isSorting = false
                            }
                        }
                    }
                )
            case .quick:
                await SortingAlgorithms.quickSort(
                    bars: bars,
                    animationSpeed: animationSpeed,
                    isAudioEnabled: isAudioEnabled,
                    audioManager: audioManager,
                    updateBars: { [weak self] updatedBars in
                        self?.bars = updatedBars
                    },
                    markAllAsSorted: { [weak self] in
                        self?.markAllAsSorted()
                    },
                    onComplete: { [weak self] in
                        guard let self = self else { return }
                        // Run the completion animation before marking sort as done
                        Task {
                            await self.playCompletionAnimation(animationSpeed: animationSpeed)
                            await MainActor.run {
                                self.isSorting = false
                            }
                        }
                    }
                )
            case .merge:
                await SortingAlgorithms.mergeSort(
                    bars: bars,
                    animationSpeed: animationSpeed,
                    isAudioEnabled: isAudioEnabled,
                    audioManager: audioManager,
                    updateBars: { [weak self] updatedBars in
                        self?.bars = updatedBars
                    },
                    markAllAsSorted: { [weak self] in
                        self?.markAllAsSorted()
                    },
                    onComplete: { [weak self] in
                        guard let self = self else { return }
                        // Run the completion animation before marking sort as done
                        Task {
                            await self.playCompletionAnimation(animationSpeed: animationSpeed)
                            await MainActor.run {
                                self.isSorting = false
                            }
                        }
                    }
                )
            }
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
    
    /// Highlights bars in order from shortest to tallest with a sequential animation
    private func playCompletionAnimation(animationSpeed: Double) async {
        // First, reset all bars to "sorted" state
        await MainActor.run {
            withAnimation(.easeInOut(duration: 0.3)) {
                for i in 0..<bars.count {
                    bars[i].state = .sorted
                }
            }
        }
        
        // Calculate the base delay - faster animation for higher speeds
        let baseDelay = UInt64(500_000_000 / animationSpeed) // nanoseconds
        
        // Create a copy of bars sorted by height (shortest to tallest)
        let sortedBars = bars.sorted { $0.value < $1.value }
        
        // Find indices of sorted bars in the original array
        let sortedIndices = sortedBars.compactMap { sortedBar in
            bars.firstIndex { $0.id == sortedBar.id }
        }
        
        // Highlight each bar in sequence from shortest to tallest
        for index in sortedIndices {
            // Set bar to comparing state (which will show as green highlight)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.2)) {
                    bars[index].state = .comparing
                }
                
                // Play tone based on bar height
                if isAudioEnabled {
                    audioManager.playTone(forValue: bars[index].value)
                }
            }
            
            // Wait before highlighting the next bar
            try? await Task.sleep(nanoseconds: baseDelay)
            
            // Set back to sorted state
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.2)) {
                    bars[index].state = .sorted
                }
            }
        }
        
        // Final pause to appreciate the completed sort
        try? await Task.sleep(nanoseconds: baseDelay * 2)
    }
    
    private func markAllAsSorted() {
        withAnimation(.easeInOut(duration: 1.0)) {
            for i in 0..<bars.count {
                if bars[i].state != .sorted {
                    bars[i].state = .sorted
                    
                    // Play a tone for each newly sorted element
                    if isAudioEnabled {
                        audioManager.playTone(forValue: 200)
                    }
                }
            }
        }
    }
    
    deinit {
        audioManager.cleanup()
    }
} 