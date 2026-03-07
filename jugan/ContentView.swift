import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var selectedTab: Tab = .my
    
    enum Tab {
        case my, group, board, chat, calendar, settings
    }
    
    var body: some View {
        if isLoggedIn {
            VStack(spacing: 0) {
                // 상단 콘텐츠 영역
                ZStack {
                    switch selectedTab {
                    case .my:
                        MainView()
                    case .group:
                        GroupView()
                    case .board:
                        BoardView()
                    case .chat:
                        ChatView()
                    case .calendar:
                        CalendarView()
                    case .settings:
                        SettingsView(isLoggedIn: $isLoggedIn)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 커스텀 탭 바 (아이콘 6개)
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 0) {
                        tabButton(tab: .my, icon: "person.fill")
                        tabButton(tab: .group, icon: "person.2.fill")
                        tabButton(tab: .board, icon: "list.bullet.indent")
                        tabButton(tab: .chat, icon: "bubble.left.and.bubble.right.fill")
                        tabButton(tab: .calendar, icon: "calendar")
                        tabButton(tab: .settings, icon: "gearshape")
                    }
                    .padding(.top, 10)
                    .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom == 0 ? 10 : 0)
                    .background(Color(UIColor.systemBackground))
                }
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        } else {
            WelcomeView(isLoggedIn: $isLoggedIn)
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
        }
    }
    
    @ViewBuilder
    private func tabButton(tab: Tab, icon: String) -> some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            selectedTab = tab
        }) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(selectedTab == tab ? .blue : .gray)
                .frame(maxWidth: .infinity)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataManager())
    }
}
