import SwiftUI

struct SettingsView: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 타이틀
            HStack {
                Text("설정")
                    .font(.title2.bold())
                Spacer()
            }
            .padding()
            
            // 메뉴 리스트
            List {
                Section {
                    Button(action: {
                        // 프로필 관리 로직
                    }) {
                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundColor(.blue)
                            Text("프로필 관리")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: {
                        isLoggedIn = false
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.red)
                            Text("로그아웃")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}
