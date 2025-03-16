//
//  SortingVisualizerWidgetBundle.swift
//  SortingVisualizerWidget
//
//  Created by Alexander Lee on 3/16/25.
//

import WidgetKit
import SwiftUI

@main
struct SortingVisualizerWidgetBundle: WidgetBundle {
    var body: some Widget {
        SortingVisualizerWidget()
        SortingVisualizerWidgetControl()
        SortingVisualizerWidgetLiveActivity()
    }
}
