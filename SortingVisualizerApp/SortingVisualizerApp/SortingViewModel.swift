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
    
    struct SortingBar: Identifiable {
        let id = UUID()
        var value: Int
        var state: BarState = .unsorted
    }
    
    func randomizeArray(size: Int) {
        // Stop any ongoing sorting
        isSorting = false
        
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
} 