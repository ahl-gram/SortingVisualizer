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
    var onRandomize: () -> Void
    var onStartSorting: () -> Void
    var onStopSorting: () -> Void
    var isSorting: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Controls")
                .font(.headline)
                .padding(.bottom, 5)
            
            // Array Size Slider
            HStack {
                Text("Array Size:")
                Spacer()
                Text("\(Int(arraySize))")
                    .frame(width: 40, alignment: .trailing)
            }
            
            Slider(value: $arraySize, in: 10...100, step: 1)
                .padding(.vertical, 5)
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
            
            Slider(value: $animationSpeed, in: 0.1...5.0, step: 0.1)
                .padding(.vertical, 5)
                .accessibilityLabel("Animation Speed Slider")
                .accessibilityHint("Adjust to change the speed of the sorting animation")
            
            HStack(spacing: 10) {
                // Randomize Array Button
                Button(action: onRandomize) {
                    Text("Randomize Array")
                        .padding()
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
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .accessibilityLabel("Stop Sorting Button")
                } else {
                    Button(action: onStartSorting) {
                        Text("Start Sorting")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .accessibilityLabel("Start Sorting Button")
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    @State var previewArraySize: Double = 50
    @State var previewAnimationSpeed: Double = 1.0
    
    return ControlPanelView(
        arraySize: $previewArraySize,
        animationSpeed: $previewAnimationSpeed,
        onRandomize: { print("Randomize tapped") },
        onStartSorting: { print("Start Sorting tapped") },
        onStopSorting: { print("Stop Sorting tapped") },
        isSorting: false
    )
    .frame(width: 500)
    .padding()
} 