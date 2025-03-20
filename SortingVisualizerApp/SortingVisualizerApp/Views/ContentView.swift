//
//  ContentView.swift
//  SortingVisualizerApp
//
//  Created by Alexander Lee on 3/13/25.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var arraySize: Double = 50
    @State private var animationSpeed: Double = 1.0
    @State private var isUniformDistribution: Bool = false
    @StateObject private var viewModel = SortingViewModel()
    @State private var safeAreaInsets: EdgeInsets = EdgeInsets()
    @State private var arraySizeDebounceTimer: Timer?
    @State private var showAboutView: Bool = false
    
    var body: some View {
        // Remove the NavigationView
        GeometryReader { geometry in
            ZStack {
                // Add safe area insets reader to capture dynamic island and other insets
                SafeAreaInsetsReader(insets: $safeAreaInsets)
                
                VStack(spacing: 0) {
                    // Title and info button at the top
                    HStack {
                        // Info button
                        Button(action: {
                            withAnimation(.spring()) {
                                showAboutView = true
                                HapticManager.shared.buttonTap()
                            }
                        }) {
                            Image(systemName: "info.circle")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .padding(.leading, 16)
                        }
                        .accessibility(label: Text("About this app"))
                        
                        Spacer()
                        
                        // Title at the top
                        Text("Sorting Visualizer")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.top, safeAreaInsets.top > 0 ? 0 : 10)
                    .padding(.bottom, 5)
                    
                    // add a spacer to the top of the view
                    Spacer()
                    // Sorting visualization area with proper insets
                    if viewModel.bars.isEmpty {
                        Text("Press 'Randomize Array' to start")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.2))
                            .padding(.horizontal, 16)
                    } else {
                        // Calculate the width for each bar to fill the available space
                        // while respecting safe areas
                        GeometryReader { vizGeometry in
                            // Calculate total available width - accounting for safe areas
                            // We want the visualization to align with the actual content of the control panel
                            // not including its padding
                            let availableWidth = vizGeometry.size.width - (safeAreaInsets.leading)/4 - (safeAreaInsets.trailing)/4
                            let barCount = viewModel.bars.count
                            
                            // Use smaller spacing for more bars to maximize space usage
                            let barSpacing: CGFloat = barCount > 60 ? 1 : 2
                            
                            // Calculate total width used by spacing between bars
                            let totalSpacingWidth = barSpacing * CGFloat(barCount - 1)
                            
                            // Calculate width per bar - ensure we fill the available space
                            let barWidth = max(1, (availableWidth - totalSpacingWidth) / CGFloat(barCount))
                            
                            // Calculate maximum bar height to prevent overlap with control panel
                            // Use 95% of the available height to ensure we leave space for the control panel
                            let maxAvailableHeight = vizGeometry.size.height * 0.95
                            
                            // Find the max value in the array to normalize heights
                            let maxBarValue = viewModel.bars.map { $0.value }.max() ?? AppConstants.Audio.maxBarValue
                            
                            HStack(alignment: .bottom, spacing: barSpacing) {
                                ForEach(viewModel.bars) { bar in
                                    // Normalize height to fit within available space
                                    let normalizedHeight = CGFloat(bar.value) / CGFloat(maxBarValue) * maxAvailableHeight
                                    
                                    SortingBarView(
                                        height: normalizedHeight,
                                        state: bar.state,
                                        width: barWidth
                                    )
                                }
                            }
                            .frame(width: availableWidth, height: vizGeometry.size.height, alignment: .bottom)
                            .background(Color.black)
                            // Center the visualization in the available space
                            .position(x: vizGeometry.size.width / 2, y: vizGeometry.size.height / 2)
                        }
                        // Remove padding so bars span the full width
                        .padding(.horizontal, 0)
                    }
                    
                    Spacer(minLength: 10)
                    
                    // Control panel
                    ControlPanelView(
                        arraySize: $arraySize,
                        animationSpeed: $animationSpeed,
                        isAudioEnabled: $viewModel.isAudioEnabled,
                        isUniformDistribution: $isUniformDistribution,
                        selectedAlgorithm: $viewModel.selectedAlgorithm,
                        onRandomize: {
                            viewModel.randomizeArray(size: Int(arraySize), isUniformDistribution: isUniformDistribution)
                        },
                        onStartSorting: {
                            viewModel.startSorting(animationSpeed: animationSpeed)
                        },
                        onStopSorting: {
                            viewModel.stopSorting()
                        },
                        isSorting: viewModel.isSorting
                    )
                    .padding(.horizontal, 5)
                    .padding(.bottom, 5)
                    // Set minimum height for the control panel to ensure all controls are visible
                    .frame(minHeight: 190)
                }
                // Don't ignore safe areas
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .avoidDynamicIsland()
                .onAppear {
                    // Initialize with a random array
                    viewModel.randomizeArray(size: Int(arraySize), isUniformDistribution: isUniformDistribution)
                }
                .onChange(of: arraySize) { oldSize, newSize in
                    // Don't update during sorting
                    guard !viewModel.isSorting else { return }
                    
                    // Cancel any existing timer
                    arraySizeDebounceTimer?.invalidate()
                    
                    // Debounce the array generation to avoid performance issues during slider dragging
                    arraySizeDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        viewModel.randomizeArray(size: Int(newSize), isUniformDistribution: isUniformDistribution)
                    }
                }
                .onChange(of: animationSpeed) { oldSpeed, newSpeed in
                    // Update animation speed in real-time if sorting is in progress
                    if viewModel.isSorting {
                        viewModel.updateAnimationSpeed(newSpeed)
                    }
                }
                .onChange(of: isUniformDistribution) { oldValue, newValue in
                    // Don't update during sorting
                    guard !viewModel.isSorting else { return }
                    
                    // Regenerate array with new distribution type
                    viewModel.randomizeArray(size: Int(arraySize), isUniformDistribution: newValue)
                }
                .onChange(of: viewModel.selectedAlgorithm) { oldAlgorithm, newAlgorithm in
                    // Don't update during sorting
                    guard !viewModel.isSorting else { return }
                    
                    // Regenerate array when switching algorithms
                    viewModel.randomizeArray(size: Int(arraySize), isUniformDistribution: isUniformDistribution)
                }
            }
        }
        .respectSafeAreas() // Use our custom modifier instead of ignoring safe areas
        .sheet(isPresented: $showAboutView) {
            AboutView(isPresented: $showAboutView)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
        }
    }
}

#Preview(traits: .landscapeLeft) {
    ContentView()
}

#Preview("Landscape", traits: .landscapeLeft) {
    ContentView()
}
