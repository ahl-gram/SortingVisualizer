//
//  SortingBarView.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import SwiftUI

enum BarState {
    case unsorted, comparing, sorted
}

struct SortingBarView: View {
    var height: CGFloat
    var state: BarState
    
    var body: some View {
        Rectangle()
            .fill(colorForState(state))
            .frame(width: 5, height: height)
            .accessibilityLabel("Bar with height \(Int(height)) and state \(state)")
    }
    
    func colorForState(_ state: BarState) -> Color {
        switch state {
        case .unsorted: return Color.white
        case .comparing: return Color.green
        case .sorted: return Color.cyan
        }
    }
}

#Preview {
    HStack {
        SortingBarView(height: 50, state: .unsorted)
        SortingBarView(height: 100, state: .comparing)
        SortingBarView(height: 150, state: .sorted)
    }
    .background(Color.black)
} 