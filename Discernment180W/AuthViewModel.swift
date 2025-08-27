import SwiftUI
import Supabase
import CryptoKit

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userName = ""
    @Published var userEmail = ""
    @Published var userId = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    init() {
        // Check if user is already logged in
        checkStoredCredentials()
    }
    
    private func checkStoredCredentials() {
        // Use UserDefaults.standard synchronize to ensure data is loaded
        UserDefaults.standard.synchronize()
        
        let storedEmail = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        let storedUserId = UserDefaults.standard.string(forKey: "userId") ?? ""
        
        print("🔍 Checking stored credentials:")
        print("   Stored email: \(storedEmail)")
        print("   Stored userId: \(storedUserId)")
        
        if !storedEmail.isEmpty && !storedUserId.isEmpty {
            // Set the values immediately
            self.userEmail = storedEmail
            self.userId = storedUserId
            
            // Also load the stored name
            if let storedUserName = UserDefaults.standard.string(forKey: "userName") {
                self.userName = storedUserName
            }
            
            // Set authenticated to true immediately
            self.isAuthenticated = true
            
            print("✅ User authenticated from stored credentials")
            
            // Update UserSessionManager as well
            UserSessionManager.shared.setCurrentUser(email: storedEmail, userId: storedUserId)
            
            // Fetch fresh data from database in background
            Task {
                await refreshUserData()
            }
        } else {
            print("❌ No stored credentials found")
        }
    }
    
    func login(email: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }
        
        do {
            // Query the users table to find the user
            let response = try await SupabaseManager.shared.client
                .from("users")
                .select("*")
                .eq("email", value: email)
                .execute()
            
            print("Login response data: \(String(data: response.data, encoding: .utf8) ?? "nil")")
            
            if let userData = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
               !userData.isEmpty,
               let user = userData.first {
                
                print("User data found: \(user)")
                
                // Get the user ID - handle both numeric and string IDs
                var userIdString = ""
                if let numericId = user["id"] as? Int {
                    userIdString = String(numericId)
                } else if let stringId = user["id"] as? String {
                    userIdString = stringId
                } else if let numericUserId = user["user_id"] as? Int {
                    userIdString = String(numericUserId)
                } else if let stringUserId = user["user_id"] as? String {
                    userIdString = stringUserId
                }
                
                // Check if password_hash exists and verify password
                if let storedPasswordHash = user["password_hash"] as? String, !password.isEmpty {
                    let inputPasswordHash = hashPassword(password)
                    
                    if storedPasswordHash == inputPasswordHash {
                        // Password matches, proceed with login
                        await MainActor.run {
                            self.userId = userIdString
                            self.userEmail = user["email"] as? String ?? email
                            
                            // Try different possible field names for name
                            if let fullName = user["name"] as? String, !fullName.isEmpty {
                                self.userName = fullName
                            } else if let firstName = user["first_name"] as? String,
                                      let lastName = user["last_name"] as? String {
                                self.userName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                            } else if let firstName = user["firstName"] as? String,
                                      let lastName = user["lastName"] as? String {
                                self.userName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                            }
                            
                            self.isAuthenticated = true
                            
                            // Store credentials persistently
                            UserDefaults.standard.set(self.userEmail, forKey: "userEmail")
                            UserDefaults.standard.set(self.userId, forKey: "userId")
                            if !self.userName.isEmpty {
                                UserDefaults.standard.set(self.userName, forKey: "userName")
                            }
                            
                            // Force synchronize to ensure data is saved
                            UserDefaults.standard.synchronize()
                            
                            // Update UserSessionManager
                            UserSessionManager.shared.setCurrentUser(email: self.userEmail, userId: self.userId)
                            
                            print("✅ Login successful, credentials saved")
                            print("   Email: \(self.userEmail)")
                            print("   UserId: \(self.userId)")
                            
                            isLoading = false
                        }
                    } else {
                        await MainActor.run {
                            errorMessage = "Invalid email or password"
                            isLoading = false
                        }
                    }
                } else {
                    // No password hash in database or empty password - for backward compatibility
                    print("Warning: No password_hash found for user or empty password provided")
                    
                    // For backward compatibility - allow login without password
                    // REMOVE THIS IN PRODUCTION!
                    if password.isEmpty {
                        await MainActor.run {
                            self.userId = userIdString
                            self.userEmail = user["email"] as? String ?? email
                            
                            if let fullName = user["name"] as? String, !fullName.isEmpty {
                                self.userName = fullName
                            } else if let firstName = user["first_name"] as? String,
                                      let lastName = user["last_name"] as? String {
                                self.userName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                            }
                            
                            self.isAuthenticated = true
                            
                            UserDefaults.standard.set(self.userEmail, forKey: "userEmail")
                            UserDefaults.standard.set(self.userId, forKey: "userId")
                            if !self.userName.isEmpty {
                                UserDefaults.standard.set(self.userName, forKey: "userName")
                            }
                            
                            // Force synchronize
                            UserDefaults.standard.synchronize()
                            
                            // Update UserSessionManager
                            UserSessionManager.shared.setCurrentUser(email: self.userEmail, userId: self.userId)
                            
                            isLoading = false
                        }
                    } else {
                        await MainActor.run {
                            errorMessage = "Invalid email or password"
                            isLoading = false
                        }
                    }
                }
            } else {
                await MainActor.run {
                    errorMessage = "User not found"
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Login failed: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    // Add this method to refresh user data from database
    func refreshUserData() async {
        guard !userEmail.isEmpty else { return }
        
        do {
            let response = try await SupabaseManager.shared.client
                .from("users")
                .select("*")
                .eq("email", value: userEmail)
                .execute()
            
            if let userData = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
               !userData.isEmpty,
               let user = userData.first {
                
                await MainActor.run {
                    // Update name if found
                    if let fullName = user["name"] as? String, !fullName.isEmpty {
                        self.userName = fullName
                        UserDefaults.standard.set(fullName, forKey: "userName")
                    } else if let firstName = user["first_name"] as? String,
                              let lastName = user["last_name"] as? String {
                        let combinedName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
                        if !combinedName.isEmpty {
                            self.userName = combinedName
                            UserDefaults.standard.set(combinedName, forKey: "userName")
                        }
                    }
                    
                    // Force synchronize
                    UserDefaults.standard.synchronize()
                }
            }
        } catch {
            print("Error refreshing user data: \(error)")
        }
    }
    
    func logout() {
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userName")
        
        // Force synchronize to ensure data is cleared
        UserDefaults.standard.synchronize()
        
        // Clear UserSessionManager
        UserSessionManager.shared.clearSession()
        
        // Reset properties
        isAuthenticated = false
        userName = ""
        userEmail = ""
        userId = ""
        
        print("🚪 User logged out, credentials cleared")
    }
    
    // Password hashing function - INSIDE the class
    private func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
