import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false // Change this based on your login logic

    // Example login check (replace with real authentication logic)
    init() {
        // Load authentication state from UserDefaults or another source
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    func logIn() {
        isLoggedIn = true
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
    }
    
    func logOut() {
        isLoggedIn = false
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }
}

