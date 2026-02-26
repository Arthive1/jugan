import SwiftUI
import Combine

final class TaskItem: Identifiable, ObservableObject {
    let id = UUID()
    @Published var title: String
    @Published var isAllDay: Bool
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var location: String
    @Published var notes: String
    @Published var isCompleted: Bool
    @Published var isDeleted: Bool
    let type: TaskType
    
    init(title: String, isAllDay: Bool = false, startDate: Date = Date(), endDate: Date = Date().addingTimeInterval(3600), location: String = "", notes: String = "", isCompleted: Bool = false, isDeleted: Bool = false, type: TaskType) {
        self.title = title
        self.isAllDay = isAllDay
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.notes = notes
        self.isCompleted = isCompleted
        self.isDeleted = isDeleted
        self.type = type
    }
}

enum TaskType {
    case work
    case todo
}

final class DataManager: ObservableObject {
    @Published var workTasks: [TaskItem] = []
    @Published var todoTasks: [TaskItem] = []
    
    func addTask(title: String, isAllDay: Bool, startDate: Date, endDate: Date, location: String, notes: String, type: TaskType) {
        let newTask = TaskItem(title: title, isAllDay: isAllDay, startDate: startDate, endDate: endDate, location: location, notes: notes, type: type)
        if type == .work {
            workTasks.append(newTask)
        } else {
            todoTasks.append(newTask)
        }
    }
}
