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
        TaskEntry(date: Date(), lastFourTasks: Array(TaskDataModel.shared.tasks.prefix(4)))
    }

    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> ()) {
        let entry = TaskEntry(date: Date(), lastFourTasks: Array(TaskDataModel.shared.tasks.prefix(4)))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [Entry] = []
        let currentDate = Date()
        let calendar = Calendar.current

        for dayOffset in 0...31 {
            let entryDate = calendar.date(byAdding: .day, value: dayOffset, to: currentDate.startOfDay())!
            if let lastFourTasks = UserDefaults(suiteName: "group.HabitCo")!.object(forKey: "WidgetData") as? [String] {
                let lastFourDecodedTasks: [TaskModel] = lastFourTasks.compactMap {
                    TaskModel(rawValue: $0)
                }
                entries.append(TaskEntry(date: entryDate, lastFourTasks: lastFourDecodedTasks))
            } else {
                entries.append(TaskEntry(date: entryDate, lastFourTasks: []))
            }
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct TaskEntry: TimelineEntry {
    let date: Date
    var lastFourTasks: [TaskModel]
}

struct HabitCo_WidgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        let viewEntry = (family == .systemLarge) ? entry.lastFourTasks : Array(entry.lastFourTasks.prefix(2))
        if viewEntry.count == 0 {
            VStack(spacing: 20) {
                Image(systemName: "leaf")
                    .font(.largeTitle)
                Text("There’s no habit recorded yet.")
            }
            .foregroundColor(.getAppColor(.neutral))
        } else {
            VStack (spacing: (family == .systemLarge) ? 19 : 8) {
                ForEach(viewEntry, id:\.id) { task in
                    HStack (spacing: 20) {
                        HStack {
                            Text("\(task.taskTitle)")
                            Spacer()
                            Text("\(task.taskCount)/\(task.totalTask)")
                        }
                        .padding(20)
                        .foregroundColor(.getAppColor(.primary))
                        //                    .frame(width: 210, height: 60)
                        .background(
                            Color.getAppColor(.primary2)
                                .overlay(
                                    HStack {
                                        //                                    Text("\(task.taskCount * 220 / task.totalTask)")
                                        Color(task.filterColor)
                                            .frame(width: CGFloat(task.taskCount * 314 / task.totalTask))
                                        Spacer()
                                    }
                                )
                        )
                        .cornerRadius(12)
                    }
                }
                if (family == .systemLarge && viewEntry.count < 4) || (family == .systemMedium && viewEntry.count < 2) {
                    Spacer()
                }
            }
            .ignoresSafeArea()
        }
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
        .configurationDisplayName("HabitCo's Widget")
        .description("A list of your today's habit")
        .supportedFamilies([.systemLarge, .systemMedium])
    }
}

struct HabitCo_Widget_Previews: PreviewProvider {
    static var previews: some View {
        HabitCo_WidgetEntryView(entry: TaskEntry(date: Date(), lastFourTasks: Array(TaskDataModel.shared.tasks.prefix(4))))
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
