//
//  SortingVisualizerWidgetLiveActivity.swift
//  SortingVisualizerWidget
//
//  Created by Alexander Lee on 3/16/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SortingVisualizerWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SortingVisualizerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SortingVisualizerWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SortingVisualizerWidgetAttributes {
    fileprivate static var preview: SortingVisualizerWidgetAttributes {
        SortingVisualizerWidgetAttributes(name: "World")
    }
}

extension SortingVisualizerWidgetAttributes.ContentState {
    fileprivate static var smiley: SortingVisualizerWidgetAttributes.ContentState {
        SortingVisualizerWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SortingVisualizerWidgetAttributes.ContentState {
         SortingVisualizerWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SortingVisualizerWidgetAttributes.preview) {
   SortingVisualizerWidgetLiveActivity()
} contentStates: {
    SortingVisualizerWidgetAttributes.ContentState.smiley
    SortingVisualizerWidgetAttributes.ContentState.starEyes
}
