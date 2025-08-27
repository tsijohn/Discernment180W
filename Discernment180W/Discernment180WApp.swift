import SwiftUI
import AVFoundation

@main
struct Discernment180WApp: App {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject private var appState = AppState()
    let persistenceController = PersistenceController.shared

    init() {
        // Configure audio session for video playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        
        // Customize the back button globally
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [
            .font: UIFont(name: "Georgia", size: 18) ?? UIFont.systemFont(ofSize: 18)
        ]
        
        // Customize back button text
        UINavigationBar.appearance().topItem?.backBarButtonItem = UIBarButtonItem(
            title: "Return", style: .plain, target: nil, action: nil
        )

        // Apply appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            // Always start with SplashScreenView
            // The authentication state will be checked inside HomePageView
            SplashScreenView()
                .environmentObject(appState)
                .environmentObject(authViewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
