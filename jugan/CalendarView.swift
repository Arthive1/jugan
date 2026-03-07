import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    @EnvironmentObject var dataManager: DataManager
    
    // 현재 선택된 날짜에 해당하는, 캘린더 표시가 활성화된 모든 업무/할일
    private var filteredCalendarTasks: [TaskItem] {
        let allTasks = dataManager.workTasks + dataManager.todoTasks
        return allTasks.filter { task in
            task.showInCalendar && isDate(selectedDate, inRange: task.startDate, to: task.endDate)
        }
    }
    
    // 주어진 날짜가 포함되는지 확인하는 로직 (MainView와 동일)
    private func isDate(_ date: Date, inRange start: Date, to end: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: start)
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endOfDay = calendar.date(byAdding: components, to: calendar.startOfDay(for: end)) ?? end
        return date >= startOfDay && date <= endOfDay
    }
    
    private func formattedTime(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 상단: 제목 (여백 최소화를 위해 직접 구현)
                HStack {
                    Text("Calendar")
                        .font(.system(size: 28, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // 상단: 캘린더 (Apple 스타일)
                DatePicker("날짜 선택", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .labelsHidden() // 라벨 숨김으로 공간 절약
                
                Divider()
                
                // 하단: 해당 날짜의 캘린더 반영 항목들
                List {
                    if filteredCalendarTasks.isEmpty {
                        Text("선택한 날짜에 표시할 일정이 없습니다.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        Section(header: Text("나의 일정")) {
                            ForEach(filteredCalendarTasks) { task in
                                HStack {
                                    Rectangle()
                                        .fill(task.type == .work ? Color.blue : Color.green)
                                        .frame(width: 4)
                                    
                                    HStack(spacing: 8) {
                                        Text(task.ownerName)
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.blue)
                                            .frame(width: 40, alignment: .leading)
                                        
                                        if !task.isAllDay {
                                            Text(formattedTime(for: task.startDate))
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Text(task.title)
                                            .font(.subheadline)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environmentObject(DataManager())
    }
}
