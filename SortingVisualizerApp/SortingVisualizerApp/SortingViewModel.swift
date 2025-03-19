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
    private var currentAnimationSpeed: Double = 1.0
    
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
    func randomizeArray(size: Int, isUniformDistribution: Bool = false) {
        // Stop any ongoing sorting
        stopSorting()
        
        // Generate a new array of bars with unique heights
        var newBars: [SortingBar] = []
        
        // Define height parameters
        let minHeight = AppConstants.BarGeneration.minHeight
        let maxHeight = AppConstants.BarGeneration.maxHeight
        
        // Calculate the range of heights
        let heightRange = maxHeight - minHeight
        
        // Generate heights based on the distribution type
        var heights: [Int] = []
        
        // Uniform distribution - evenly spaced heights
        if isUniformDistribution {
            // Calculate step size to evenly distribute heights
            let step = heightRange / (size - 1)
            
            // Generate heights with uniform distribution
            for i in 0..<size {
                heights.append(minHeight + (i * step))
            }
            
            // Shuffle the heights for final randomization
            heights.shuffle()
        } else {
            // Random distribution - completely random heights within the range
            for _ in 0..<size {
                let randomHeight = Int.random(in: minHeight...maxHeight)
                heights.append(randomHeight)
            }
        }
        
        // Create bars with the generated heights
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
        
        // Store the current animation speed
        currentAnimationSpeed = animationSpeed
        
        // Start a new sorting task based on selected algorithm
        sortingTask = Task {
            // Use the generic sorting algorithm method
            await SortingVisualizers.runSortingAlgorithm(
                type: selectedAlgorithm,
                bars: bars,
                animationSpeed: animationSpeed,
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
    
    func stopSorting() {
        sortingTask?.cancel()
        sortingTask = nil
        isSorting = false
        
        // Reset all bars to unsorted state
        for i in 0..<bars.count {
            bars[i].state = .unsorted
        }
    }
    
    func updateAnimationSpeed(_ speed: Double) {
        currentAnimationSpeed = speed
        
        // If currently sorting, restart the sorting with the new speed
        if isSorting {
            // Store current bars state
            let currentBars = bars
            
            // Cancel current sorting task
            sortingTask?.cancel()
            sortingTask = nil
            
            // Start a new sorting task with the updated speed
            sortingTask = Task {
                // Use the generic sorting algorithm method
                await SortingVisualizers.runSortingAlgorithm(
                    type: selectedAlgorithm,
                    bars: currentBars,
                    animationSpeed: speed,
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
                            await self.playCompletionAnimation(animationSpeed: speed)
                            await MainActor.run {
                                self.isSorting = false
                            }
                        }
                    }
                )
            }
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
        let baseDelay = UInt64(Double(AppConstants.Animation.baseDelay) / animationSpeed) // nanoseconds
        
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
                    bars[index].state = .completed
                }
                
                // Play tone based on bar height
                if audioManager.isAudioEnabled {
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
                    if audioManager.isAudioEnabled {
                        audioManager.playTone(forValue: AppConstants.Audio.sortedToneValue)
                    }
                }
            }
        }
    }
    
    deinit {
        audioManager.cleanup()
    }
} 