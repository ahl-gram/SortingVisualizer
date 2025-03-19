//
//  SortingBarView.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import SwiftUI

enum BarState {
    case unsorted, comparing, sorted, merging, completed, cubeHighlight
}

struct SortingBarView: View {
    var height: CGFloat
    var width: CGFloat
    var state: BarState
    
    // For backward compatibility, provide a default width
    init(height: CGFloat, state: BarState, width: CGFloat = 5) {
        self.height = height
        self.state = state
        self.width = width
    }
    
    var body: some View {
        Rectangle()
            .fill(gradientForState(state))
            .frame(width: width, height: height)
            .shadow(color: shadowForState(state), radius: state == .comparing ? 3 : 0)
            .overlay(
                Rectangle()
                    .stroke(Color.black.opacity(0.3), lineWidth: 0.5)
            )
            .animation(state == .completed ? .easeInOut(duration: 0.1) : .easeInOut(duration: 0.3), value: state)
            .accessibilityLabel("Bar with height \(Int(height)) and state \(state)")
    }
    
    func gradientForState(_ state: BarState) -> LinearGradient {
        switch state {
        case .unsorted: 
            return LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.9), Color.white]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .comparing: 
            return LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .sorted: 
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 0, green: 0.7, blue: 0.9), Color(red: 0.3, green: 0.8, blue: 1.0)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .merging:
            return LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.purple]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .completed:
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 1.0, green: 0.2, blue: 0.2), Color(red: 1.0, green: 0.2, blue: 0.2)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .cubeHighlight:
            return LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.7), Color.orange]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    func colorForState(_ state: BarState) -> Color {
        switch state {
        case .unsorted: return Color.white
        case .comparing: return Color.green
        case .sorted: return Color.cyan
        case .merging: return Color.purple
        case .completed: return Color.red
        case .cubeHighlight: return Color.orange
        }
    }
    
    func shadowForState(_ state: BarState) -> Color {
        switch state {
        case .unsorted: return Color.clear
        case .comparing: return Color.green.opacity(0.7)
        case .sorted: return Color.cyan.opacity(0.3)
        case .merging: return Color.purple.opacity(0.7)
        case .completed: return Color.red.opacity(0.7)
        case .cubeHighlight: return Color.orange.opacity(0.7)
        }
    }
}

#Preview {
    HStack {
        SortingBarView(height: 50, state: .unsorted, width: 10)
        SortingBarView(height: 100, state: .comparing, width: 15)
        SortingBarView(height: 150, state: .sorted, width: 20)
        SortingBarView(height: 120, state: .merging, width: 15)
        SortingBarView(height: 90, state: .cubeHighlight, width: 15)
        SortingBarView(height: 180, state: .completed, width: 10)
    }
    .padding()
    .background(Color.black.opacity(0.1))
} 