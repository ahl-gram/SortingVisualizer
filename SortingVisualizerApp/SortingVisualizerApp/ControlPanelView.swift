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
    @Binding var selectedAlgorithm: SortingAlgorithmType
    var onRandomize: () -> Void
    var onStartSorting: () -> Void
    var onStopSorting: () -> Void
    var isSorting: Bool
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > 600 {
                // Wide landscape layout - horizontal arrangement
                VStack(spacing: 5) {
                    // Top section with algorithm picker, description and sliders
                    HStack(alignment: .top, spacing: 15) {
                        // Left column - algorithm picker and description
                        VStack(alignment: .leading, spacing: 6) {
                            // Algorithm Picker - Dropdown style
                            HStack {
                                Text("Algorithm:")
                                Spacer()
                                Picker("Select Algorithm", selection: $selectedAlgorithm) {
                                    ForEach(SortingAlgorithmType.allCases) { algorithm in
                                        Text(algorithm.rawValue).tag(algorithm)
                                    }
                                }
                                .frame(width: 180)
                                .disabled(isSorting)
                                .accessibilityLabel("Algorithm Selector")
                            }
                            .padding(.bottom, 2)
                            
                            // Algorithm Description
                            Text(selectedAlgorithm.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 3)
                                .accessibilityLabel("Algorithm Description")
                                .frame(height: 50, alignment: .top)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Right column - sliders
                        VStack(alignment: .leading, spacing: 8) {
                            // Array Size Slider
                            HStack {
                                Text("Array Size:")
                                Spacer()
                                Text("\(Int(arraySize))")
                                    .frame(width: 40, alignment: .trailing)
                            }
                            
                            Slider(value: $arraySize, in: 10...100, step: 1)
                                .accessibilityLabel("Array Size Slider")
                                .disabled(isSorting)
                            
                            // Animation Speed Slider
                            HStack {
                                Text("Animation Speed:")
                                Spacer()
                                Text("\(Int(animationSpeed))x")
                                    .frame(width: 40, alignment: .trailing)
                            }
                            
                            Slider(value: $animationSpeed, in: 1...20, step: 1)
                                .accessibilityLabel("Animation Speed Slider")
                            }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Bottom row with buttons and sound toggle aligned horizontally
                    HStack {
                        // Buttons on the left
                        HStack(spacing: 10) {
                            // Randomize Button
                            Button(action: onRandomize) {
                                Text("Randomize")
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(isSorting)
                            .accessibilityLabel("Randomize Button")
                            
                            // Start/Stop Sorting Button
                            if isSorting {
                                Button(action: onStopSorting) {
                                    Text("Stop")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .accessibilityLabel("Stop Button")
                            } else {
                                Button(action: onStartSorting) {
                                    Text("Start")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .accessibilityLabel("Start Button")
                            }
                        }
                        // make the width 50% of the control panel
                        .frame(width: geometry.size.width / 2)
                        
                        Spacer()
                        
                        // Audio Toggle on the right
                        Toggle(isOn: $isAudioEnabled) {
                            Text("Sound Effects")
                        }
                        .accessibilityLabel("Sound Effects Toggle")
                        .frame(width: 180)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            } else {
                // Standard layout for smaller screens - adjust to keep controls visible
                VStack(alignment: .leading, spacing: 6) {
                    // Top row with algorithm picker and audio toggle
                    HStack(alignment: .top) {
                        // Left side - Algorithm picker and description
                        VStack(alignment: .leading, spacing: 4) {
                            // Algorithm Picker - Dropdown style
                            HStack {
                                Text("Algorithm:")
                                Spacer()
                                Picker("Select Algorithm", selection: $selectedAlgorithm) {
                                    ForEach(SortingAlgorithmType.allCases) { algorithm in
                                        Text(algorithm.rawValue).tag(algorithm)
                                    }
                                }
                                .frame(width: 140)
                                .disabled(isSorting)
                                .accessibilityLabel("Algorithm Selector")
                            }
                            
                            // Algorithm Description
                            Text(selectedAlgorithm.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 3)
                                .accessibilityLabel("Algorithm Description")
                                .frame(height: 50, alignment: .top)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Right side - Buttons
                        HStack(spacing: 10) {
                            // Randomize Button
                            Button(action: onRandomize) {
                                Text("Randomize")
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(isSorting)
                            .accessibilityLabel("Randomize Button")
                            
                            // Start/Stop Sorting Button
                            if isSorting {
                                Button(action: onStopSorting) {
                                    Text("Stop")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .accessibilityLabel("Stop Button")
                            } else {
                                Button(action: onStartSorting) {
                                    Text("Start Sorting")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .accessibilityLabel("Start Button")
                            }
                        }
                        .frame(width: 250)
                    }
                    
                    // Middle section - sliders
                    HStack(alignment: .top, spacing: 10) {
                        // Left slider - Array Size
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Array Size:")
                                Spacer()
                                Text("\(Int(arraySize))")
                                    .frame(width: 40, alignment: .trailing)
                            }
                            
                            Slider(value: $arraySize, in: 10...100, step: 1)
                                .accessibilityLabel("Array Size Slider")
                                .accessibilityHint("Adjust to change the number of elements in the array")
                                .disabled(isSorting)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Right slider - Animation Speed
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Animation Speed:")
                                Spacer()
                                Text("\(Int(animationSpeed))x")
                                    .frame(width: 40, alignment: .trailing)
                            }
                            
                            Slider(value: $animationSpeed, in: 1...20, step: 1)
                                .accessibilityLabel("Animation Speed Slider")
                                .accessibilityHint("Adjust to change the speed of the sorting animation")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Sound Effects toggle
                    Toggle(isOn: $isAudioEnabled) {
                        Text("Sound Effects")
                    }
                    .accessibilityLabel("Sound Effects Toggle")
                    .accessibilityHint("Toggle to enable or disable sound effects during sorting")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 3)
                }
                .padding(6)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
}

// Wrapper struct for previews to avoid @State warnings
struct ControlPanelPreviewWrapper: View {
    @State private var arraySize: Double = 50
    @State private var animationSpeed: Double = 1.0
    @State private var isAudioEnabled: Bool = true
    @State private var selectedAlgorithm: SortingAlgorithmType = .bubble
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        ControlPanelView(
            arraySize: $arraySize,
            animationSpeed: $animationSpeed,
            isAudioEnabled: $isAudioEnabled,
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

#Preview("Standard") {
    ControlPanelPreviewWrapper(width: 500, height: 300)
}

#Preview("Wide Landscape") {
    ControlPanelPreviewWrapper(width: 700, height: 200)
} 