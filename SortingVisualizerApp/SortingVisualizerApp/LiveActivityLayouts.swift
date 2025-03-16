//
//  LiveActivityLayouts.swift
//  SortingVisualizerApp
//
//  Created by Alexander Lee on 3/16/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

// Compact leading view for Dynamic Island
struct BarsCompactLeadingView: View {
    let context: ActivityViewContext<VerticalBarsAttributes>
    
    var body: some View {
        HStack(spacing: 2) {
            // Mini visualization of your bars
            ForEach(0..<min(4, context.state.barHeights.count), id: \.self) { index in
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 3, height: context.state.barHeights[index] * 15)
                    .animation(.spring(response: 0.3), value: context.state.barHeights[index])
            }
        }
    }
}

// Compact trailing view for Dynamic Island
struct BarsCompactTrailingView: View {
    let context: ActivityViewContext<VerticalBarsAttributes>
    
    var body: some View {
        Text(context.state.isPlaying ? "Playing" : "Paused")
            .font(.caption2)
            .foregroundColor(.white)
    }
}

// Expanded Dynamic Island view
struct BarsExpandedView: View {
    let context: ActivityViewContext<VerticalBarsAttributes>
    
    var body: some View {
        VStack {
            Text(context.attributes.sessionName)
                .font(.headline)
            
            // Visual representation of your bars
            HStack(spacing: 4) {
                ForEach(0..<min(8, context.state.barHeights.count), id: \.self) { index in
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 8, height: context.state.barHeights[index] * 50)
                        .animation(.spring(response: 0.3), value: context.state.barHeights[index])
                }
            }
            .frame(height: 60)
            .padding()
            
            Text("Intensity: \(Int(context.state.currentIntensity * 100))%")
                .font(.caption)
        }
    }
}
