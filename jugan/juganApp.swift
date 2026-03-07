import SwiftUI
import FirebaseCore

@main
struct JuganApp: App {
    @StateObject private var dataManager = DataManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
