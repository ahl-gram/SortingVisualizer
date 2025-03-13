//
//  ControlPanelView.swift
//  SortingVisualizerApp
//
//  Created for Sorting Visualizer App
//

import SwiftUI

struct ControlPanelView: View {
    @Binding var arraySize: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Controls")
                .font(.headline)
                .padding(.bottom, 5)
            
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
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    @State var previewArraySize: Double = 50
    
    return ControlPanelView(arraySize: $previewArraySize)
        .frame(width: 300)
        .padding()
} 