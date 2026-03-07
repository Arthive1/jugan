import SwiftUI

struct MainView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddWork = false
    @State private var showingAddTodo = false
    
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false // 캘린더 표시 여부
    
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
    
    // 현재 선택된 날짜의 YYYY.MM.dd 표시용
    private var subDateTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: selectedDate)
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
                    SectionHeader(title: "업무", action: { showingAddWork = true }, isTop: true)
                    
                    List {
                        ForEach(filteredWorkTasks, id: \.id) { task in
                            TaskRow(task: task)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        dataManager.deleteTask(task)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        // 수정 로직 (나중에 상세 구현)
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.white)
                }
                .frame(maxHeight: .infinity)
                
                // 하단: 할일
                VStack(alignment: .leading, spacing: 0) {
                    SectionHeader(title: "할일", action: { showingAddTodo = true })
                    
                    List {
                        ForEach(filteredTodoTasks, id: \.id) { task in
                            TaskRow(task: task)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        dataManager.deleteTask(task)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button {
                                        // 수정 로직
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.white)
                }
                .frame(maxHeight: .infinity)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 16) {
                        Button(action: {
                            withAnimation {
                                if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
                                    selectedDate = newDate
                                }
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Button {
                            withAnimation {
                                showingDatePicker.toggle()
                            }
                        } label: {
                            VStack(spacing: 2) {
                                Text(dateTitle)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(subDateTitle)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button(action: {
                            withAnimation {
                                if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
                                    selectedDate = newDate
                                }
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .onAppear {
                dataManager.fetchTasks(ownerId: "temporary_user")
            }
            .popover(isPresented: $showingDatePicker) {
                VStack {
                    DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .padding()
                        .onChange(of: selectedDate) { oldValue, newValue in
                            showingDatePicker = false
                        }
                    
                    Button {
                        selectedDate = Date()
                        showingDatePicker = false
                    } label: {
                        Text("오늘로 이동")
                            .font(.footnote.bold())
                            .padding(.bottom, 20)
                    }
                }
                .presentationDetents([.medium]) // iOS 16+ support for adjustable sheets if popover is treated as sheet
                .frame(width: 350, height: 450)
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
    var isTop: Bool = false
    
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
        .padding(.horizontal)
        .padding(.vertical, 8)
        .padding(.top, isTop ? -10 : 0) // 최상단 섹션의 경우 위쪽 여백 제거
        .background(Color(UIColor.systemBackground))
    }
}

struct TaskRow: View {
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var task: TaskItem
    
    private var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: task.startDate)
    }
    
    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? .blue : .gray)
                .onTapGesture {
                    dataManager.toggleCompletion(for: task)
                }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    if !task.isAllDay {
                        Text(formattedStartTime)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    
                    Text(task.title)
                        .font(.body)
                }
                .strikethrough(task.isDeleted)
                .foregroundColor(task.isDeleted ? .gray : .primary)
                
                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.caption)
                        .strikethrough(task.isDeleted)
                        .foregroundColor(task.isDeleted ? .gray : .secondary)
                        .padding(.leading, task.isAllDay ? 0 : 45) // 시간 표시 공간만큼 들여쓰기
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            withAnimation {
                dataManager.toggleDeletion(for: task)
            }
        }
    }
}
