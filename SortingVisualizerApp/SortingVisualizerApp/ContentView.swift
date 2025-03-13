//
//  ContentView.swift
//  SortingVisualizerApp
//
//  Created by Alexander Lee on 3/13/25.
//

import SwiftUI

struct ContentView: View {
    @State private var arraySize: Double = 50
    @State private var animationSpeed: Double = 1.0
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Sorting Visualizer")
                    .font(.largeTitle)
                Spacer()
                // Placeholder for visual components (sorting animation)
                Text("Sorting animation here")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.2))
                Spacer()
                // Control panel components
                ControlPanelView(arraySize: $arraySize, animationSpeed: $animationSpeed)
                    .padding()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .previewInterfaceOrientation(.landscapeLeft)
}
