//
//  TaskModel.swift
//  HabitCo
//
//  Created by Figo Alessandro Lehman on 03/04/24.
//

import SwiftUI

struct TaskModel: Identifiable {
    var id: String = UUID().uuidString
    var taskTitle: String
    var filterColor: Color
    var taskCount: Int
    var totalTask: Int
}

class TaskDataModel {
    static let shared = TaskDataModel()
    
    var tasks: [TaskModel] = [
        .init(taskTitle: "Satu", filterColor: .cornflower, taskCount: 1, totalTask: 1),
        .init(taskTitle: "Dua", filterColor: .blossom, taskCount: 1, totalTask: 2),
        .init(taskTitle: "Tiga", filterColor: .roseGold, taskCount: 1, totalTask: 3),
        .init(taskTitle: "Empat", filterColor: .turquoise, taskCount: 3, totalTask: 4),
    ]
}
