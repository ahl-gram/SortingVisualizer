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
            .shadow(color: shadowForState(state), radius: state == .comparing ? 3 : 0)
            .overlay(
                Rectangle()
                    .stroke(Color.black.opacity(0.3), lineWidth: 0.5)
            )
            .animation(.easeInOut(duration: 0.3), value: state)
            .accessibilityLabel("Bar with height \(Int(height)) and state \(state)")
    }
    
    func colorForState(_ state: BarState) -> Color {
        switch state {
        case .unsorted: return Color.white
        case .comparing: return Color.green
        case .sorted: return Color.cyan
        }
    }
    
    func shadowForState(_ state: BarState) -> Color {
        switch state {
        case .unsorted: return Color.clear
        case .comparing: return Color.green.opacity(0.7)
        case .sorted: return Color.cyan.opacity(0.3)
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