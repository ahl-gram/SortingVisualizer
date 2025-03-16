//
//  ContentView.swift
//  SortingVisualizerApp
//
//  Created by Alexander Lee on 3/13/25.
//

import SwiftUI
import Combine
import ActivityKit

struct ContentView: View {
    @State private var arraySize: Double = 50
    @State private var animationSpeed: Double = 1.0
    @StateObject private var viewModel = SortingViewModel()
    @State private var safeAreaInsets: EdgeInsets = EdgeInsets()
    @State private var arraySizeDebounceTimer: Timer?
    @State private var diagnosticMessage: String = ""
    @State private var showDiagnosticAlert: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Add safe area insets reader to capture dynamic island and other insets
                SafeAreaInsetsReader(insets: $safeAreaInsets)
                
                VStack(spacing: 0) {
                    Text("Sorting Visualizer")
                        .font(.title)
                        .padding(.top, 5)
                    
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
                            let maxBarValue = viewModel.bars.map { $0.value }.max() ?? 200
                            
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
                        isLiveActivityEnabled: $viewModel.isLiveActivityEnabled,
                        selectedAlgorithm: $viewModel.selectedAlgorithm,
                        onRandomize: {
                            viewModel.randomizeArray(size: Int(arraySize))
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
                    .background(Color.black.opacity(0.1))
                    // Set minimum height for the control panel to ensure all controls are visible
                    .frame(minHeight: 180)
                    
                    // Debug test buttons (only in debug builds)
                    #if DEBUG
                    HStack {
                        Button("Test Live Activity") {
                            // Create a test LiveActivityManager
                            let testManager = LiveActivityManager()
                            // Start a test activity with sample data
                            testManager.startLiveActivity(
                                algorithmName: "Test",
                                barHeights: [100, 200, 150, 300, 250, 180, 120, 220]
                            )
                            print("Manually triggered Live Activity test")
                        }
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Button("Diagnostics") {
                            runLiveActivityDiagnostics()
                        }
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(.bottom, 10)
                    #endif
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .avoidDynamicIsland()
                .onAppear {
                    // Initialize with a random array
                    viewModel.randomizeArray(size: Int(arraySize))
                }
                .onChange(of: arraySize) { newSize in
                    // Don't update during sorting
                    guard !viewModel.isSorting else { return }
                    
                    // Cancel any existing timer
                    arraySizeDebounceTimer?.invalidate()
                    
                    // Debounce the array generation to avoid performance issues during slider dragging
                    arraySizeDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                        viewModel.randomizeArray(size: Int(newSize))
                    }
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
        .respectSafeAreas() // Use our custom modifier instead of ignoring safe areas
        .alert("Live Activity Diagnostics", isPresented: $showDiagnosticAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(diagnosticMessage)
        }
    }
    
    private func runLiveActivityDiagnostics() {
        var message = ""
        
        // Check authorization
        let authInfo = ActivityAuthorizationInfo()
        message += "Live Activities enabled: \(authInfo.areActivitiesEnabled)\n"
        
        // Check bundle ID
        message += "Main App Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")\n"
        
        // Check for active activities
        if #available(iOS 16.2, *) {
            let activities = Activity<VerticalBarsAttributes>.activities
            message += "Active Activities: \(activities.count)\n"
            
            if activities.isEmpty {
                // Try to start a test activity
                do {
                    let initialState = VerticalBarsAttributes.ContentState(
                        barHeights: [0.5, 0.3, 0.8, 0.2],
                        currentIntensity: 0.5,
                        isPlaying: true
                    )
                    
                    let attributes = VerticalBarsAttributes(
                        sessionName: "Diagnostic Test",
                        startTime: Date()
                    )
                    
                    let activity = try Activity.request(
                        attributes: attributes,
                        contentState: initialState,
                        pushType: nil
                    )
                    
                    message += "Successfully created diagnostic Live Activity: \(activity.id)\n"
                    message += "IMPORTANT: Check Device menu now for 'Trigger Live Activity' option"
                } catch {
                    message += "Error creating diagnostic activity: \(error.localizedDescription)\n"
                    message += "Detailed error: \(error)\n"
                }
            }
        } else {
            message += "iOS 16.2+ required for Activity.activities API\n"
        }
        
        print("DIAGNOSTIC: \(message)")
        self.diagnosticMessage = message
        self.showDiagnosticAlert = true
    }
}

#Preview {
    ContentView()
        .previewInterfaceOrientation(.landscapeLeft)
}

#Preview("Landscape") {
    ContentView()
        .previewInterfaceOrientation(.landscapeLeft)
}
