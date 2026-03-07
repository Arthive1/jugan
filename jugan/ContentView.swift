import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false
    
    var body: some View {
        if isLoggedIn {
            TabView {
                BoardView()
                    .tabItem {
                        Image(systemName: "list.bullet.indent")
                        Text("Board")
                    }
                
                GroupView()
                    .tabItem {
                        Image(systemName: "person.2.fill")
                        Text("Group")
                    }
                
                ChatView()
                    .tabItem {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                        Text("Chat")
                    }
                
                MainView() // My
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("My")
                    }
                
                CalendarView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Calendar")
                    }
            }
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
        } else {
            WelcomeView(isLoggedIn: $isLoggedIn)
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(DataManager())
    }
}
