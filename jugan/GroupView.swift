import SwiftUI

struct GroupView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var isAdmin = true
    @State private var showingInviteSheet = false
    @State private var showingInviteAlert = false
    @State private var inviteLink = "https://jugan.app/invite/group123"
    
    // 임시 데이터 (나를 포함하여 초기화)
    @State var members = [
        GroupMember(name: "나", image: "person.circle.fill", tasks: [], isMe: true),
        GroupMember(name: "홍길동", image: "person.crop.circle.fill", tasks: ["회의 참여", "보고서 작성"]),
        GroupMember(name: "김철수", image: "person.crop.circle.badge.plus", tasks: ["디자인 리뷰"]),
        GroupMember(name: "이영희", image: "person.crop.circle.badge.checkmark", tasks: ["코드 리팩토링", "테스트 진행"])
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SectionHeader(title: "Group", action: { actionSheet() })
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(members) { member in
                            NavigationLink(destination: MemberDetailView(member: member)) {
                                VStack {
                                    Image(systemName: member.image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(member.isMe ? .blue : .gray.opacity(0.7))
                                        .padding(.top, 10)
                                    
                                    Text(member.name)
                                        .font(.headline)
                                        .padding(.bottom, 10)
                                        .foregroundColor(member.isMe ? .blue : .primary)
                                }
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(member.isMe ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .alert("초대 수락", isPresented: $showingInviteAlert) {
                Button("취소", role: .cancel) { }
                Button("확인") {
                    withAnimation {
                        members.append(GroupMember(name: "새로운 멤버", image: "person.badge.plus", tasks: ["인사하기"]))
                    }
                }
            } message: {
                Text("'주간 업무 그룹'에 초대되었습니다. 수락하시겠습니까?")
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
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
    }
    
    func actionSheet() {
        let textToShare = "[주간] 그룹에 초대합니다.\n초대 링크: \(inviteLink)"
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

// 상대방의 업무 정보를 보여주는 상세 화면
struct MemberDetailView: View {
    @EnvironmentObject var dataManager: DataManager
    let member: GroupMember
    
    var body: some View {
        List {
            Section(header: Text("\(member.name)님의 이번 주 업무")) {
                if member.isMe {
                    // '나'의 경우 DataManager에서 실제 데이터 연동
                    let myTasks = dataManager.workTasks + dataManager.todoTasks
                    if myTasks.isEmpty {
                        Text("등록된 업무가 없습니다.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(myTasks) { task in
                            HStack {
                                Circle()
                                    .fill(task.type == .work ? Color.blue : Color.green)
                                    .frame(width: 8, height: 8)
                                Text(task.title)
                                    .strikethrough(task.isCompleted)
                                Spacer()
                                if !task.isAllDay {
                                    Text(formattedTime(for: task.startDate))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                } else {
                    // 다른 멤버의 경우 기존 임시 데이터 유지
                    ForEach(member.tasks, id: \.self) { task in
                        Text(task)
                    }
                }
            }
        }
        .navigationTitle(member.name)
    }
    
    private func formattedTime(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct GroupMember: Identifiable {
    let id = UUID()
    let name: String
    let image: String
    let tasks: [String]
    var isMe: Bool = false
}

struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        GroupView()
            .environmentObject(DataManager())
    }
}
