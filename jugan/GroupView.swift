import SwiftUI

struct GroupView: View {
    @State private var isAdmin = true // 현재 사용자가 관리자인지 여부 (나중에 DB 연동)
    @State private var showingInviteSheet = false
    @State private var showingInviteAlert = false
    @State private var inviteLink = "https://jugan.app/invite/group123"
    
    // 임시 데이터
    @State var members = [
        GroupMember(name: "홍길동", image: "person.crop.circle.fill", tasks: ["회의 참여", "보고서 작성"]),
        GroupMember(name: "김철수", image: "person.crop.circle.badge.plus", tasks: ["디자인 리뷰"]),
        GroupMember(name: "이영희", image: "person.crop.circle.badge.checkmark", tasks: ["코드 리팩토링", "테스트 진행"])
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(members) { member in
                        NavigationLink(destination: MemberDetailView(member: member)) {
                            VStack {
                                Image(systemName: member.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.blue)
                                    .padding(.top, 10)
                                
                                Text(member.name)
                                    .font(.headline)
                                    .padding(.bottom, 10)
                            }
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Group")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isAdmin {
                        Button(action: {
                            actionSheet()
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                }
            }
            .alert("초대 수락", isPresented: $showingInviteAlert) {
                Button("취소", role: .cancel) { }
                Button("확인") {
                    // 실제로는 상대방이 확인을 눌렀을 때 멤버 리스트에 추가되는 로직
                    withAnimation {
                        members.append(GroupMember(name: "새로운 멤버", image: "person.badge.plus", tasks: ["인사하기"]))
                    }
                }
            } message: {
                Text("'주간 업무 그룹'에 초대되었습니다. 수락하시겠습니까?")
            }
        }
    }
    
    // 공유 시트 호출 함수 (문자, 카톡 등 연동)
    func actionSheet() {
        let textToShare = "[주간] 그룹에 초대합니다.\n초대 링크: \(inviteLink)"
        let activityVC = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        // 현재 화면에서 띄우기 위해 WindowScene 활용
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}

// 상대방의 업무 정보를 보여주는 상세 화면
struct MemberDetailView: View {
    let member: GroupMember
    
    var body: some View {
        List {
            Section(header: Text("\(member.name)님의 이번 주 업무")) {
                ForEach(member.tasks, id: \.self) { task in
                    Text(task)
                }
            }
        }
        .navigationTitle(member.name)
    }
}

struct GroupMember: Identifiable {
    let id = UUID()
    let name: String
    let image: String
    let tasks: [String]
}

struct GroupView_Previews: PreviewProvider {
    static var previews: some View {
        GroupView()
    }
}
