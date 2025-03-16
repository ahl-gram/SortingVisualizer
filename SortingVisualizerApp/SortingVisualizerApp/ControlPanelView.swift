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
    @Binding var isLiveActivityEnabled: Bool
    @Binding var selectedAlgorithm: SortingAlgorithmType
    var onRandomize: () -> Void
    var onStartSorting: () -> Void
    var onStopSorting: () -> Void
    var isSorting: Bool
    
    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > 600 {
                // Wide landscape layout - horizontal arrangement
                HStack(alignment: .center, spacing: 15) {
                    // Left column - sliders and algorithm picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Controls")
                            .font(.headline)
                        
                        // Algorithm Picker
                        HStack {
                            Text("Algorithm:")
                            Picker("Algorithm", selection: $selectedAlgorithm) {
                                ForEach(SortingAlgorithmType.allCases) { algorithm in
                                    Text(algorithm.rawValue).tag(algorithm)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .disabled(isSorting)
                            .accessibilityLabel("Algorithm Selector")
                        }
                        .padding(.bottom, 5)
                        
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
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Right column - toggles and buttons
                    VStack(alignment: .leading, spacing: 8) {
                        // Audio Toggle
                        Toggle(isOn: $isAudioEnabled) {
                            Text("Audio Feedback")
                        }
                        .accessibilityLabel("Audio Feedback Toggle")
                        
                        // Live Activity Toggle
                        Toggle(isOn: $isLiveActivityEnabled) {
                            Text("Dynamic Island")
                        }
                        .accessibilityLabel("Live Activity Toggle")
                        
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
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            } else {
                // Standard layout for smaller screens
                VStack(alignment: .leading, spacing: 8) {
                    Text("Controls")
                        .font(.headline)
                        .padding(.bottom, 2)
                    
                    // Algorithm Picker
                    HStack {
                        Text("Algorithm:")
                        Spacer()
                        Picker("Algorithm", selection: $selectedAlgorithm) {
                            ForEach(SortingAlgorithmType.allCases) { algorithm in
                                Text(algorithm.rawValue).tag(algorithm)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(maxWidth: 240)
                        .disabled(isSorting)
                        .accessibilityLabel("Algorithm Selector")
                    }
                    .padding(.vertical, 2)
                    
                    // Array Size Slider
                    HStack {
                        Text("Array Size:")
                        Spacer()
                        Text("\(Int(arraySize))")
                            .frame(width: 40, alignment: .trailing)
                    }
                    
                    Slider(value: $arraySize, in: 10...100, step: 1)
                        .padding(.vertical, 2)
                        .accessibilityLabel("Array Size Slider")
                        .accessibilityHint("Adjust to change the number of elements in the array")
                        .disabled(isSorting)
                    
                    // Animation Speed Slider
                    HStack {
                        Text("Animation Speed:")
                        Spacer()
                        Text("\(String(format: "%.1f", animationSpeed))x")
                            .frame(width: 40, alignment: .trailing)
                    }
                    
                    Slider(value: $animationSpeed, in: 0.1...20.0, step: 0.1)
                        .padding(.vertical, 2)
                        .accessibilityLabel("Animation Speed Slider")
                        .accessibilityHint("Adjust to change the speed of the sorting animation")
                    
                    // Audio Toggle
                    Toggle(isOn: $isAudioEnabled) {
                        Text("Audio Feedback")
                    }
                    .padding(.vertical, 2)
                    .accessibilityLabel("Audio Feedback Toggle")
                    .accessibilityHint("Toggle to enable or disable audio feedback during sorting")
                    
                    // Live Activity Toggle
                    Toggle(isOn: $isLiveActivityEnabled) {
                        Text("Dynamic Island")
                    }
                    .padding(.vertical, 2)
                    .accessibilityLabel("Live Activity Toggle")
                    .accessibilityHint("Toggle to enable or disable Live Activity feature")
                    
                    // Buttons row
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
    @State var previewLiveActivityEnabled: Bool = true
    @State var previewSelectedAlgorithm: SortingAlgorithmType = .bubble
    
    return ControlPanelView(
        arraySize: $previewArraySize,
        animationSpeed: $previewAnimationSpeed,
        isAudioEnabled: $previewAudioEnabled,
        isLiveActivityEnabled: $previewLiveActivityEnabled,
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
    @State var previewLiveActivityEnabled: Bool = true
    @State var previewSelectedAlgorithm: SortingAlgorithmType = .bubble
    
    return ControlPanelView(
        arraySize: $previewArraySize,
        animationSpeed: $previewAnimationSpeed,
        isAudioEnabled: $previewAudioEnabled,
        isLiveActivityEnabled: $previewLiveActivityEnabled,
        selectedAlgorithm: $previewSelectedAlgorithm,
        onRandomize: { print("Randomize tapped") },
        onStartSorting: { print("Start Sorting tapped") },
        onStopSorting: { print("Stop Sorting tapped") },
        isSorting: false
    )
    .frame(width: 700, height: 200)
    .padding()
} 