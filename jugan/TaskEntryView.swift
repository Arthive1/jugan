import SwiftUI

struct TaskEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    
    let type: TaskType
    let initialDate: Date
    
    @State private var title: String = ""
    @State private var location: String = ""
    @State private var isAllDay: Bool = false
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var notes: String = ""
    @State private var showInCalendar: Bool = false // 캘린더 반영 여부 상태
    
    init(type: TaskType, initialDate: Date) {
        self.type = type
        self.initialDate = initialDate
        self._startDate = State(initialValue: initialDate)
        self._endDate = State(initialValue: initialDate.addingTimeInterval(3600))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("제목", text: $title)
                    TextField("위치", text: $location)
                }
                
                Section {
                    Toggle("하루 종일", isOn: $isAllDay)
                    
                    if isAllDay {
                        DatePicker("시작", selection: $startDate, displayedComponents: .date)
                        DatePicker("종료", selection: $endDate, displayedComponents: .date)
                    } else {
                        DatePicker("시작", selection: $startDate)
                        DatePicker("종료", selection: $endDate)
                    }
                }
                
                Section {
                    Toggle("캘린더에 반영", isOn: $showInCalendar)
                }
                
                Section("메모") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(type == .work ? "새로운 업무" : "새로운 할일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("추가") {
                        if !title.isEmpty {
                            dataManager.addTask(title: title, isAllDay: isAllDay, startDate: startDate, endDate: endDate, location: location, notes: notes, showInCalendar: showInCalendar, type: type, ownerId: "temporary_user")
                        }
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                    .fontWeight(.bold)
                }
            }
        }
    }
}

struct TaskEntryView_Previews: PreviewProvider {
    static var previews: some View {
        TaskEntryView(type: .work, initialDate: Date())
            .environmentObject(DataManager())
    }
}
