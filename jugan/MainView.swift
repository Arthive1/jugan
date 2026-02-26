import SwiftUI

struct MainView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddWork = false
    @State private var showingAddTodo = false
    
    @State private var selectedDate = Date()
    
    private var dateTitle: String {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 2 corresponds to Monday
        let weekOfYear = calendar.component(.weekOfYear, from: selectedDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: selectedDate)
        
        return "\(weekOfYear)주차 \(weekDay)"
    }
    
    private var filteredWorkTasks: [TaskItem] {
        dataManager.workTasks.filter { task in
            isDate(selectedDate, inRange: task.startDate, to: task.endDate)
        }
    }
    
    private var filteredTodoTasks: [TaskItem] {
        dataManager.todoTasks.filter { task in
            isDate(selectedDate, inRange: task.startDate, to: task.endDate)
        }
    }
    
    // 주어진 날짜가 시작일과 종료일 사이에 있는지(해당 날짜가 포함되는지) 확인하는 함수
    private func isDate(_ date: Date, inRange start: Date, to end: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: start)
        
        // 종료일은 다음날 자정 전까지 포함시켜야 그날 하루종일 이어지는 것으로 계산
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endOfDay = calendar.date(byAdding: components, to: calendar.startOfDay(for: end)) ?? end
        
        return date >= startOfDay && date <= endOfDay
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 상단: 업무
                VStack(alignment: .leading, spacing: 0) {
                    SectionHeader(title: "업무", action: { showingAddWork = true })
                    
                    List {
                        ForEach(filteredWorkTasks) { task in
                            TaskRow(task: task)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                .frame(maxHeight: .infinity)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                // 하단: 할일
                VStack(alignment: .leading, spacing: 0) {
                    SectionHeader(title: "할일", action: { showingAddTodo = true })
                    
                    List {
                        ForEach(filteredTodoTasks) { task in
                            TaskRow(task: task)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                .frame(maxHeight: .infinity)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 16) {
                        Button(action: {
                            if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
                                selectedDate = newDate
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Text(dateTitle)
                            .font(.headline)
                        
                        Button(action: {
                            if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
                                selectedDate = newDate
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddWork) {
                TaskEntryView(type: .work, initialDate: selectedDate)
            }
            .sheet(isPresented: $showingAddTodo) {
                TaskEntryView(type: .todo, initialDate: selectedDate)
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 28, weight: .bold))
            Spacer()
            Button(action: action) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

struct TaskRow: View {
    @ObservedObject var task: TaskItem
    
    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? .blue : .gray)
                .onTapGesture {
                    task.isCompleted.toggle()
                }
            
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isDeleted)
                    .foregroundColor(task.isDeleted ? .gray : .primary)
                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.caption)
                        .strikethrough(task.isDeleted)
                        .foregroundColor(task.isDeleted ? .gray : .secondary)
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            withAnimation {
                task.isDeleted.toggle()
            }
        }
    }
}
