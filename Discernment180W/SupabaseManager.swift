import Foundation
import Supabase

struct User: Encodable {
    let first_name: String
    let last_name: String
    let email: String
    let age: String?
    let diocese: String?
}

class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        let supabaseURL = URL(string: "https://lywnqbwlrnvhoghizfpn.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5d25xYndscm52aG9naGl6ZnBuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY3OTA4MzUsImV4cCI6MjA1MjM2NjgzNX0.4RgHActLZUkRnTvsSxkwu_VMxfZOWQhH8Q_nio2RjJ0" // Make sure this is your actual key
        client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
    func signUpUser(firstName: String, lastName: String, email: String, age: String?, diocese: String?, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
            Task {
                do {
                    // Create a user object
                    let newUser = User(first_name: firstName, last_name: lastName, email: email, age: age, diocese: diocese)

                    // Insert user into Supabase database
                    try await client.database
                        .from("users")
                        .insert(newUser)
                        .execute()

                    // Sign up user with Supabase Authentication
                    _ = try await client.auth.signUp(email: email, password: password)

                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
}
