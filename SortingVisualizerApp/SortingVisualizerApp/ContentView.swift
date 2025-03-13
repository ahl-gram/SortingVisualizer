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
        GeometryReader { geometry in
            ZStack {
                // Removed NavigationView wrapper as it's restricting width in landscape
                VStack(spacing: 0) {
                    Text("Sorting Visualizer")
                        .font(.title)
                        .padding(.top, 5)
                    
                    // Sorting visualization area - expanded to use more space
                    if viewModel.bars.isEmpty {
                        Text("Press 'Randomize Array' to start")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .padding(.horizontal, 5)
                    } else {
                        // Calculate the width for each bar to fill the available space
                        // with a small fixed gap between bars
                        GeometryReader { vizGeometry in
                            let availableWidth = vizGeometry.size.width
                            let barCount = viewModel.bars.count
                            let barSpacing: CGFloat = 2
                            let totalSpacingWidth = barSpacing * CGFloat(barCount - 1)
                            let barWidth = max(1, (availableWidth - totalSpacingWidth) / CGFloat(barCount))
                            
                            HStack(alignment: .bottom, spacing: barSpacing) {
                                ForEach(viewModel.bars) { bar in
                                    SortingBarView(
                                        height: CGFloat(bar.value),
                                        state: bar.state,
                                        width: barWidth
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black)
                        }
                        .padding(.horizontal, 5)
                    }
                    
                    // Control panel components - adaptive layout based on orientation
                    if geometry.size.width > geometry.size.height {
                        // Landscape mode - wider control panel
                        ControlPanelView(
                            arraySize: $arraySize,
                            animationSpeed: $animationSpeed,
                            isAudioEnabled: $viewModel.isAudioEnabled,
                            onRandomize: {
                                viewModel.randomizeArray(size: Int(arraySize))
                            },
                            onStartSorting: {
                                viewModel.startBubbleSort(animationSpeed: animationSpeed)
                            },
                            onStopSorting: {
                                viewModel.stopSorting()
                            },
                            isSorting: viewModel.isSorting
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                    } else {
                        // Portrait mode - more compact control panel
                        CompactControlPanelView(
                            arraySize: $arraySize,
                            animationSpeed: $animationSpeed,
                            isAudioEnabled: $viewModel.isAudioEnabled,
                            onRandomize: {
                                viewModel.randomizeArray(size: Int(arraySize))
                            },
                            onStartSorting: {
                                viewModel.startBubbleSort(animationSpeed: animationSpeed)
                            },
                            onStopSorting: {
                                viewModel.stopSorting()
                            },
                            isSorting: viewModel.isSorting
                        )
                        .padding(.horizontal, 5)
                        .padding(.bottom, 5)
                    }
                }
                .ignoresSafeArea(edges: [])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .avoidDynamicIsland()
                .onAppear {
                    // Initialize with a random array
                    viewModel.randomizeArray(size: Int(arraySize))
                }
                
                // Show completion animation when sorting is complete
                if viewModel.showCompletionAnimation {
                    CompletionAnimationView()
                        .onTapGesture {
                            withAnimation {
                                viewModel.showCompletionAnimation = false
                            }
                        }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Compact version of control panel for portrait mode
struct CompactControlPanelView: View {
    @Binding var arraySize: Double
    @Binding var animationSpeed: Double
    @Binding var isAudioEnabled: Bool
    var onRandomize: () -> Void
    var onStartSorting: () -> Void
    var onStopSorting: () -> Void
    var isSorting: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            // Controls label and toggles in one row
            HStack {
                Text("Controls")
                    .font(.headline)
                
                Spacer()
                
                Toggle(isOn: $isAudioEnabled) {
                    Text("Audio")
                        .font(.callout)
                }
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            
            // Array Size and Animation Speed sliders in more compact form
            VStack(spacing: 2) {
                HStack {
                    Text("Array Size: \(Int(arraySize))")
                        .font(.caption)
                    Slider(value: $arraySize, in: 10...100, step: 1)
                        .disabled(isSorting)
                }
                
                HStack {
                    Text("Speed: \(String(format: "%.1f", animationSpeed))x")
                        .font(.caption)
                    Slider(value: $animationSpeed, in: 0.1...5.0, step: 0.1)
                }
            }
            
            // Buttons in a row
            HStack(spacing: 8) {
                Button(action: onRandomize) {
                    Text("Randomize")
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.callout)
                }
                .disabled(isSorting)
                
                if isSorting {
                    Button(action: onStopSorting) {
                        Text("Stop")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .font(.callout)
                    }
                } else {
                    Button(action: onStartSorting) {
                        Text("Start")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .font(.callout)
                    }
                }
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    ContentView()
}

#Preview("Portrait") {
    ContentView()
        .previewInterfaceOrientation(.portrait)
}

#Preview("Landscape") {
    ContentView()
        .previewInterfaceOrientation(.landscapeLeft)
}
