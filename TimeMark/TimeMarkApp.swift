import Firebase
import SwiftUI

@main
struct TimeMarkApp: App {
    init() {
        FirebaseApp.configure()
        

    }
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
