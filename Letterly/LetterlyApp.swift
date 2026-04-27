import SwiftUI

@main
struct LetterlyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            StartView()
        }
    }
}
