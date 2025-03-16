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
                HStack(alignment: .top, spacing: 15) {
                    // Left column - algorithm picker and description
                    VStack(alignment: .leading, spacing: 8) {
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
                            .padding(.bottom, 5)
                            .accessibilityLabel("Algorithm Description")
                        
                        Spacer()
                        
                        // Buttons
                        HStack(spacing: 10) {
                            // Randomize Array Button
                            Button(action: onRandomize) {
                                Text("Randomize Array")
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(isSorting)
                            .accessibilityLabel("Randomize Array Button")
                            
                            // Start/Stop Sorting Button
                            if isSorting {
                                Button(action: onStopSorting) {
                                    Text("Stop Sorting")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .accessibilityLabel("Stop Sorting Button")
                            } else {
                                Button(action: onStartSorting) {
                                    Text("Start Sorting")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .accessibilityLabel("Start Sorting Button")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Right column - sliders and audio toggle
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
                            Text("\(String(format: "%.1f", animationSpeed))x")
                                .frame(width: 40, alignment: .trailing)
                        }
                        
                        Slider(value: $animationSpeed, in: 0.1...20.0, step: 0.1)
                            .accessibilityLabel("Animation Speed Slider")
                        
                        Spacer()
                        
                        // Audio Toggle
                        Toggle(isOn: $isAudioEnabled) {
                            Text("Sound Effects")
                        }
                        .accessibilityLabel("Sound Effects Toggle")
                        .padding(.top, 5)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            } else {
                // Standard layout for smaller screens - adjust to keep controls visible
                VStack(alignment: .leading, spacing: 8) {
                    // Top row with algorithm picker and audio toggle
                    HStack(alignment: .top) {
                        // Left side - Algorithm picker and description
                        VStack(alignment: .leading, spacing: 5) {
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
                                .padding(.bottom, 5)
                                .accessibilityLabel("Algorithm Description")
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Right side - Buttons
                        HStack(spacing: 10) {
                            // Randomize Array Button
                            Button(action: onRandomize) {
                                Text("Randomize Array")
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(isSorting)
                            .accessibilityLabel("Randomize Array Button")
                            
                            // Start/Stop Sorting Button
                            if isSorting {
                                Button(action: onStopSorting) {
                                    Text("Stop Sorting")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .accessibilityLabel("Stop Sorting Button")
                            } else {
                                Button(action: onStartSorting) {
                                    Text("Start Sorting")
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .accessibilityLabel("Start Sorting Button")
                            }
                        }
                        .frame(width: 250)
                    }
                    
                    // Middle section - sliders
                    HStack(alignment: .top, spacing: 12) {
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
                                Text("\(String(format: "%.1f", animationSpeed))x")
                                    .frame(width: 40, alignment: .trailing)
                            }
                            
                            Slider(value: $animationSpeed, in: 0.1...20.0, step: 0.1)
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
                    .padding(.top, 5)
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
}

#Preview("Standard") {
    @State var previewArraySize: Double = 50
    @State var previewAnimationSpeed: Double = 1.0
    @State var previewAudioEnabled: Bool = true
    @State var previewSelectedAlgorithm: SortingAlgorithmType = .bubble
    
    return ControlPanelView(
        arraySize: $previewArraySize,
        animationSpeed: $previewAnimationSpeed,
        isAudioEnabled: $previewAudioEnabled,
        selectedAlgorithm: $previewSelectedAlgorithm,
        onRandomize: { print("Randomize tapped") },
        onStartSorting: { print("Start Sorting tapped") },
        onStopSorting: { print("Stop Sorting tapped") },
        isSorting: false
    )
    .frame(width: 500, height: 300)
    .padding()
}

#Preview("Wide Landscape") {
    @State var previewArraySize: Double = 50
    @State var previewAnimationSpeed: Double = 1.0
    @State var previewAudioEnabled: Bool = true
    @State var previewSelectedAlgorithm: SortingAlgorithmType = .bubble
    
    return ControlPanelView(
        arraySize: $previewArraySize,
        animationSpeed: $previewAnimationSpeed,
        isAudioEnabled: $previewAudioEnabled,
        selectedAlgorithm: $previewSelectedAlgorithm,
        onRandomize: { print("Randomize tapped") },
        onStartSorting: { print("Start Sorting tapped") },
        onStopSorting: { print("Stop Sorting tapped") },
        isSorting: false
    )
    .frame(width: 700, height: 200)
    .padding()
} 