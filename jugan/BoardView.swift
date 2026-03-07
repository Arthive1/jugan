import SwiftUI

struct BoardView: View {
    @EnvironmentObject var dataManager: DataManager
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
    
    // 주어진 날짜가 포함되는지 확인하는 로직
    private func isDate(_ date: Date, inRange start: Date, to end: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: start)
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endOfDay = calendar.date(byAdding: components, to: calendar.startOfDay(for: end)) ?? end
        return date >= startOfDay && date <= endOfDay
    }
    
    
    // 선택된 날짜의 모든 업무와 할일을 사용자별로 그룹화
    private var groupedTasks: [String: [TaskItem]] {
        let allTasks = dataManager.workTasks + dataManager.todoTasks
        let filtered = allTasks.filter { isDate(selectedDate, inRange: $0.startDate, to: $0.endDate) }
        return Dictionary(grouping: filtered, by: { $0.ownerName })
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 상단 캘린더 드롭다운 영역
                if showingDatePicker {
                    VStack {
                        DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .padding()
                            .onChange(of: selectedDate) { oldValue, newValue in
                                withAnimation {
                                    showingDatePicker = false // 날짜 선택 시 자동으로 닫힘
                                }
                            }
                        
                        Button {
                            withAnimation {
                                selectedDate = Date() // 오늘로 이동
                                showingDatePicker = false
                            }
                        } label: {
                            Text("오늘로 이동")
                                .font(.footnote.bold())
                                .padding(.bottom, 10)
                        }
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .navigationTitle("")

                }
                
                ScrollView {
                    VStack(spacing: 1) {
                        // 헤더 (왼쪽: 프로필, 오른쪽: 업무)
                        HStack {
                            Text("Profile")
                                .frame(width: 80, alignment: .center)
                            Divider()
                            Text("Work & Todos")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .font(.footnote.bold())
                        .padding(.vertical, 10)
                        .background(Color(UIColor.secondarySystemBackground))
                        
                        if groupedTasks.isEmpty {
                            Text("선택한 날짜에 등록된 업무가 없습니다.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 50)
                        } else {
                            ForEach(groupedTasks.keys.sorted(), id: \.self) { ownerName in
                                HStack(alignment: .top) {
                                    // 왼쪽 열: 프로필 사진과 이름
                                    VStack {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .foregroundColor(.blue.opacity(0.8))
                                        Text(ownerName)
                                            .font(.caption)
                                            .bold()
                                    }
                                    .frame(width: 80)
                                    .padding(.vertical, 10)
                                    
                                    Divider()
                                    
                                    // 오른쪽 열: 업무 목록
                                    VStack(alignment: .leading, spacing: 8) {
                                        if let tasks = groupedTasks[ownerName] {
                                            ForEach(tasks) { task in
                                                HStack(alignment: .top) {
                                                    Circle()
                                                        .fill(task.type == .work ? Color.blue : Color.green)
                                                        .frame(width: 6, height: 6)
                                                        .padding(.top, 6)
                                                    
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(task.title)
                                                            .font(.subheadline)
                                                            .strikethrough(task.isCompleted || task.isDeleted)
                                                            .foregroundColor(task.isDeleted ? .gray : .primary)
                                                        
                                                        if !task.isAllDay {
                                                            Text(formattedTime(for: task.startDate))
                                                                .font(.system(size: 10))
                                                                .foregroundColor(.secondary)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .background(Color.white)
                                Divider()
                            }
                        }
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
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
        }
    }
    
    private func formattedTime(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView()
    }
}
