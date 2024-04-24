//
//  HabitCo_Widget.swift
//  HabitCo Widget
//
//  Created by Figo Alessandro Lehman on 19/03/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(lastFourTasks: Array(TaskDataModel.shared.tasks.prefix(4)))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> ()) {
        let entry = TaskEntry(lastFourTasks: Array(TaskDataModel.shared.tasks.prefix(4)))
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let latestTasks = Array(TaskDataModel.shared.tasks.prefix(4))
        let latestEntries = [TaskEntry(lastFourTasks: latestTasks)]
        
        let timeline = Timeline(entries: latestEntries, policy: .atEnd)
        completion(timeline)
    }
}

struct TaskEntry: TimelineEntry {
    let date: Date = Date()
    var lastFourTasks: [TaskModel]
}

struct HabitCo_WidgetEntryView : View {
    var entry: Provider.Entry
    let userDefaults = UserDefaults(suiteName: "group.HabitCo")
    
    
    var body: some View {
        
        VStack {
                
            ForEach(entry.lastFourTasks, id:\.id) { task in
                HStack (spacing: 20) {
                    HStack {
                        Text("\(task.taskTitle)")
                        Spacer()
                        Text("\(task.taskCount)/\(task.totalTask)")
                    }
                    .padding(20)
//                    .frame(width: 210, height: 60)
                    .background(
                        Color.getAppColor(.primary2)
                            .overlay(
                                HStack {
//                                    Text("\(task.taskCount * 220 / task.totalTask)")
                                    task.filterColor
                                        .frame(width: CGFloat(task.taskCount * 266 / task.totalTask))
                                    Spacer()
                                }
                            )
                    )
                    .cornerRadius(12)
                }
                if task.id != entry.lastFourTasks.last!.id {
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
        .padding(24)
        .foregroundColor(.getAppColor(.primary))
    }
}

@main
struct HabitCo_Widget: Widget {
    let kind: String = "HabitCo_Widget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HabitCo_WidgetEntryView(entry: entry)
                .widgetBackground(.getAppColor(.neutral3))
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemLarge])
    }
}

struct HabitCo_Widget_Previews: PreviewProvider {
    static var previews: some View {
        HabitCo_WidgetEntryView(entry: TaskEntry(lastFourTasks: Array(TaskDataModel.shared.tasks.prefix(4))))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .widgetBackground(.getAppColor(.neutral3))
    }
}
//

// MARK: - Widget Preview Compatibility
extension View {
    func widgetBackground(_ color: Color) -> some View {
        if #available(iOSApplicationExtension 17.0, macOSApplicationExtension 14.0, *) {
            return  containerBackground(color, for: .widget)
        } else {
            return background(color)
        }
    }
}

// MARK: - Color Palette
extension Color {
    enum AppColors: String {
        case danger
        case primary
        case primary2
        case primary3
        case secondary
        case neutral
        case neutral2
        case neutral3
        
        
        // Elevation Effect
        case shadow
    }
    
    static func getAppColor(_ appColor: AppColors) -> Color {
        return Color("\(appColor.rawValue)")
    }
}

// MARK: - Filter Colors
extension Color {
    enum FilterColors: String, CaseIterable {
        case aluminium
        case lavender
        case mushroom
        case glacier
        case wisteria
        case blush
        case turquoise
        case roseGold
        case peach
        case cornflower
        case blossom
        case goldenrod
    }
}
