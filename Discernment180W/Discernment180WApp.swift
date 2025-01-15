import SwiftUI

@main
struct Discernment180WApp: App {
    @StateObject private var appState = AppState() // Initialize AppState
    @StateObject private var authViewModel = AuthViewModel() // Manage authentication state

    let persistenceController = PersistenceController.shared

    init() {
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
            SplashScreenView() // Start with SplashScreenView
                .environmentObject(appState)
                .environmentObject(authViewModel) // Provide AuthViewModel globally
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

