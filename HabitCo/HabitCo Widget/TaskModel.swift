//
//  TaskModel.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 03/04/24.
//

import SwiftUI

struct TaskModel: Identifiable, RawRepresentable, Codable {

    static let defaultJSON = "{\"id\": \"1\", \"taskTitle\":\"Habit Name\", \"filterColor\":\"aluminium\", \"taskCount\": 0, \"totalTask\": 1}"

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return ""
        }
        return result
    }

    var id: String = UUID().uuidString
    var taskTitle: String
    var filterColor: String
    var taskCount: Int
    var totalTask: Int

    enum CodingKeys: String, CodingKey {
        case id
        case taskTitle
        case filterColor
        case taskCount
        case totalTask
    }

    init(taskTitle: String, filterColor: String, taskCount: Int, totalTask: Int) {
        self.taskTitle = taskTitle
        self.filterColor = filterColor
        self.taskCount = taskCount
        self.totalTask = totalTask
    }

    init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(TaskModel.self, from: data)
        else {
            return nil
        }
        self = result
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.taskTitle = try container.decode(String.self, forKey: .taskTitle)
        self.filterColor = try container.decode(String.self, forKey: .filterColor)
        self.taskCount = try container.decode(Int.self, forKey: .taskCount)
        self.totalTask = try container.decode(Int.self, forKey: .totalTask)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.taskTitle, forKey: .taskTitle)
        try container.encode(self.filterColor, forKey: .filterColor)
        try container.encode(self.taskCount, forKey: .taskCount)
        try container.encode(self.totalTask, forKey: .totalTask)
    }
}

class TaskDataModel {
    static let shared = TaskDataModel()
    
    var tasks: [TaskModel] = [
        .init(rawValue: TaskModel.defaultJSON)!,
        .init(rawValue: TaskModel.defaultJSON)!,
        .init(rawValue: TaskModel.defaultJSON)!,
        .init(rawValue: TaskModel.defaultJSON)!,
    ]
}
