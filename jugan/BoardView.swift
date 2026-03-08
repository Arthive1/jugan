import SwiftUI

struct BoardView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedDate = Date()
    @State private var showingDatePicker = false
    
    // 날짜 제목 (예: "10주차 일요일")
    private var dateTitle: String {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday start
        let weekOfYear = calendar.component(.weekOfYear, from: selectedDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: selectedDate)
        
        return "\(weekOfYear)주차 \(weekDay)"
    }
    
    // 서브 날짜 (예: "2026년 03월 08일")
    private var subDateTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: selectedDate)
    }
    
    // 주어진 날짜가 시작일과 종료일 사이에 있는지(해당 날짜가 포함되는지) 확인
    private func isDate(_ date: Date, inRange start: Date, to end: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: start)
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let endOfDay = calendar.date(byAdding: components, to: calendar.startOfDay(for: end)) ?? end
        return date >= startOfDay && date <= endOfDay
    }
    
    // 선택된 날짜의 업무를 사용자별로 그룹화
    private var groupedTasks: [(owner: String, tasks: [TaskItem])] {
        let allTasks = dataManager.workTasks + dataManager.todoTasks
        let filteredTasks = allTasks.filter { isDate(selectedDate, inRange: $0.startDate, to: $0.endDate) }
        
        // 소유자별 그룹화
        let grouped = Dictionary(grouping: filteredTasks, by: { $0.ownerName })
        
        // 날짜순(시간순) 정렬 및 소유자 이름순 정렬
        return grouped.map { (owner: $0.key, tasks: $0.value.sorted(by: { $0.startDate < $1.startDate })) }
                      .sorted(by: { $0.owner < $1.owner })
    }
    
    // 임시 프로필 이미지 매칭
    private func getProfileImage(for name: String) -> String {
        switch name {
        case "나", "Me", "temporary_user": return "person.circle.fill"
        case "홍길동": return "person.crop.circle.fill"
        case "김철수": return "person.crop.circle.badge.plus"
        case "이영희": return "person.crop.circle.badge.checkmark"
        default: return "person.circle.fill"
        }
    }
    
    private func formattedTime(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 상단 날짜 선택 UI (My 화면 스타일)
            HStack(spacing: 20) {
                // 어제 버튼
                Button(action: {
                    withAnimation {
                        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
                            selectedDate = newDate
                        }
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // 날짜 버튼 (클릭 시 팝오버 달력)
                Button {
                    showingDatePicker.toggle()
                } label: {
                    VStack(spacing: 2) {
                        Text(dateTitle)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        Text(subDateTitle)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .popover(isPresented: $showingDatePicker) {
                    VStack {
                        DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .padding()
                            .onChange(of: selectedDate) { _, _ in
                                showingDatePicker = false // 날짜 선택 시 닫기
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
                    .frame(width: 350, height: 450)
                }
                
                Spacer()
                
                // 내일 버튼
                Button(action: {
                    withAnimation {
                        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
                            selectedDate = newDate
                        }
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 15)
            .background(Color(UIColor.systemBackground))
            
            Divider()
            
            // MARK: - 컬럼 헤더 가이드
            HStack(spacing: 0) {
                Text("Profile")
                    .font(.footnote.bold())
                    .frame(width: 80, alignment: .center)
                
                Divider()
                    .frame(height: 20)
                
                Text("Work & Todos")
                    .font(.footnote.bold())
                    .padding(.leading, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            .background(Color(UIColor.secondarySystemBackground))
            
            Divider()
            
            // MARK: - 그룹별 업무 리스트 (왼쪽: 프로필, 오른쪽: 업무 목록)
            ScrollView {
                if groupedTasks.isEmpty {
                    VStack(spacing: 11) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("선택한 날짜에 등록된 업무가 없습니다.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 80)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedTasks, id: \.owner) { group in
                            HStack(alignment: .top, spacing: 0) {
                                // 왼쪽 열: 프로필 사진 및 이름
                                VStack(spacing: 6) {
                                    Image(systemName: getProfileImage(for: group.owner))
                                        .resizable()
                                        .frame(width: 45, height: 45)
                                        .foregroundColor(group.owner == "temporary_user" || group.owner == "나" ? .blue : .blue.opacity(0.8))
                                    Text(group.owner == "temporary_user" ? "나" : group.owner)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .frame(width: 80)
                                .padding(.top, 16)
                                .padding(.bottom, 16)
                                
                                Divider()
                                
                                // 오른쪽 열: 업무 목록 (시간 표기 추가)
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(group.tasks) { task in
                                        HStack(alignment: .top, spacing: 10) {
                                            // 표기 형식: 시간 (고정 폭을 주어 줄 맞춤)
                                            if !task.isAllDay {
                                                Text(formattedTime(for: task.startDate))
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(task.type == .work ? .blue : .green)
                                                    .frame(width: 45, alignment: .leading)
                                            } else {
                                                Text("종일")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(task.type == .work ? .blue : .green)
                                                    .frame(width: 45, alignment: .leading)
                                            }
                                            
                                            // 할일 제목
                                            Text(task.title)
                                                .font(.body)
                                                .strikethrough(task.isCompleted || task.isDeleted, color: .gray)
                                                .foregroundColor((task.isCompleted || task.isDeleted) ? .gray : .primary)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                }
                                .padding(.all, 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .background(Color(UIColor.systemBackground))
                            
                            Divider()
                        }
                    }
                }
            }
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarHidden(true)
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView()
            .environmentObject(DataManager())
    }
}
