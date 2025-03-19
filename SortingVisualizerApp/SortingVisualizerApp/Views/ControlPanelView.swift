//
//  ControlPanelView.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import SwiftUI

struct ControlPanelView: View {
    @Binding var arraySize: Double
    @Binding var animationSpeed: Double
    @Binding var isAudioEnabled: Bool
    @Binding var isUniformDistribution: Bool
    @Binding var selectedAlgorithm: SortingAlgorithmType
    var onRandomize: () -> Void
    var onStartSorting: () -> Void
    var onStopSorting: () -> Void
    var isSorting: Bool
    
    var body: some View {
            ControlPanelLayout(
                arraySize: $arraySize,
                animationSpeed: $animationSpeed,
                isAudioEnabled: $isAudioEnabled, 
                isUniformDistribution: $isUniformDistribution,
                selectedAlgorithm: $selectedAlgorithm,
                onRandomize: onRandomize,
                onStartSorting: onStartSorting,
                onStopSorting: onStopSorting,
                isSorting: isSorting
            )
        }
    }


// Preview wrapper
struct ControlPanelPreviewWrapper: View {
    @State private var arraySize: Double = 50
    @State private var animationSpeed: Double = 1.0
    @State private var isAudioEnabled: Bool = true
    @State private var isUniformDistribution: Bool = false
    @State private var selectedAlgorithm: SortingAlgorithmType = .bubble
    var width: CGFloat
    var height: CGFloat
    var previewLayout: Bool = true // true = preview view, false = preview layout directly
    
    var body: some View {
        if previewLayout {
            ControlPanelView(
                arraySize: $arraySize,
                animationSpeed: $animationSpeed,
                isAudioEnabled: $isAudioEnabled,
                isUniformDistribution: $isUniformDistribution,
                selectedAlgorithm: $selectedAlgorithm,
                onRandomize: { print("Randomize tapped") },
                onStartSorting: { print("Start tapped") },
                onStopSorting: { print("Stop tapped") },
                isSorting: false
            )
            .frame(width: width, height: height)
            .padding()
        } else {
            ControlPanelLayout(
                arraySize: $arraySize,
                animationSpeed: $animationSpeed,
                isAudioEnabled: $isAudioEnabled,
                isUniformDistribution: $isUniformDistribution,
                selectedAlgorithm: $selectedAlgorithm,
                onRandomize: { print("Randomize tapped") },
                onStartSorting: { print("Start tapped") },
                onStopSorting: { print("Stop tapped") },
                isSorting: false
            )
            .frame(width: width, height: height)
            .padding()
        }
    }
}

#Preview("Landscape - View") {
    ControlPanelPreviewWrapper(width: 700, height: 200)
}

#Preview("Landscape - Layout") {
    ControlPanelPreviewWrapper(width: 700, height: 200, previewLayout: false)
} 
