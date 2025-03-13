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
    @StateObject private var viewModel = SortingViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Sorting Visualizer")
                    .font(.largeTitle)
                Spacer()
                // Sorting visualization area
                if viewModel.bars.isEmpty {
                    Text("Press 'Randomize Array' to start")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.gray.opacity(0.2))
                } else {
                    HStack(alignment: .bottom, spacing: 2) {
                        ForEach(viewModel.bars) { bar in
                            SortingBarView(height: CGFloat(bar.value), state: bar.state)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .padding(.horizontal)
                }
                Spacer()
                // Control panel components
                ControlPanelView(
                    arraySize: $arraySize,
                    animationSpeed: $animationSpeed,
                    onRandomize: {
                        viewModel.randomizeArray(size: Int(arraySize))
                    }
                )
                .padding()
            }
            .padding()
            .onAppear {
                // Initialize with a random array
                viewModel.randomizeArray(size: Int(arraySize))
            }
        }
    }
}

#Preview {
    ContentView()
        .previewInterfaceOrientation(.landscapeLeft)
}
