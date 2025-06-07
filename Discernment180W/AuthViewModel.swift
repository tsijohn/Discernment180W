import SwiftUI
import Supabase

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userCurrentDay: String = ""

    init() {
        checkAuthState()
    }

    func checkAuthState() {
        Task {
            if let session = try? await supabase.auth.session {
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoggedIn = false
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                }
            }
        }
    }
    
    func logIn(name: String, email: String, current_day: String) {
        isLoggedIn = true
        userName = name
        userEmail = email
        userCurrentDay = current_day

        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(name, forKey: "userName")
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(current_day, forKey: "userCurrentDay")

    }
    
    func logOut() {
        Task {
            do {
                try await supabase.auth.signOut()
                DispatchQueue.main.async {
                    self.isLoggedIn = false
                    self.userName = ""
                    self.userEmail = ""
                    
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    UserDefaults.standard.removeObject(forKey: "userName")
                    UserDefaults.standard.removeObject(forKey: "userEmail")
                }
            } catch {
                print("Error logging out: \(error)")
            }
        }
    }
}
