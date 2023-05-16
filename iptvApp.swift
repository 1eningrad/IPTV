import SwiftUI

@main
struct iptvapp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(EPGManager.shared)
        }
    }
}
