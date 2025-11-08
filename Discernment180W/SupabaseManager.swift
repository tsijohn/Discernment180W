import Foundation
import Supabase

// User signup data structure
struct UserSignUpData: Encodable {
    let first_name: String
    let last_name: String
    let email: String
    let password_hash: String
    let age: String?
    let diocese: String?
    let current_day: String
    let curriculum_order: String
    let created_at: String
}

// Homepage excerpt data structure
struct HomepageExcerpt: Decodable {
    let page_text: String
    let start_day: Int
    let end_day: Int
}

class SupabaseManager {
    static let shared = SupabaseManager()
    let client: SupabaseClient
    private let baseURL: URL  // Store the URL separately
    
    private init() {
        // Your Supabase credentials
        let supabaseURL = URL(string: "https://lywnqbwlrnvhoghizfpn.supabase.co")!
        let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx5d25xYndscm52aG9naGl6ZnBuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY3OTA4MzUsImV4cCI6MjA1MjM2NjgzNX0.4RgHActLZUkRnTvsSxkwu_VMxfZOWQhH8Q_nio2RjJ0"
        
        // Store the URL for later use
        self.baseURL = supabaseURL
        
        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
    
    // Sign up user with password
    func signUpUser(
        firstName: String,
        lastName: String,
        email: String,
        passwordHash: String,
        age: String?,
        diocese: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            // Create userData without id field
            let userData = UserSignUpData(
                first_name: firstName,
                last_name: lastName,
                email: email,
                password_hash: passwordHash,
                age: age,
                diocese: diocese,
                current_day: "0",
                curriculum_order: "0",
                created_at: ISO8601DateFormatter().string(from: Date())
            )
            
            // Debug print to see exactly what we're sending
            print("🔍 Attempting to insert user data:")
            print("   first_name: \(userData.first_name)")
            print("   last_name: \(userData.last_name)")
            print("   email: \(userData.email)")
            print("   age: \(userData.age ?? "nil")")
            print("   diocese: \(userData.diocese ?? "nil")")
            print("   current_day: \(userData.current_day)")
            print("   curriculum_order: \(userData.curriculum_order)")
            print("   created_at: \(userData.created_at)")
            
            do {
                // Insert into database
                _ = try await client
                    .from("users")
                    .insert(userData)
                    .execute()
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                print("❌ Sign up error: \(error)")
                print("📝 Full error: \(String(describing: error))")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Legacy sign up user without password (for backward compatibility)
    func signUpUser(
        firstName: String,
        lastName: String,
        email: String,
        age: String?,
        diocese: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // For backward compatibility - create empty password hash
        signUpUser(
            firstName: firstName,
            lastName: lastName,
            email: email,
            passwordHash: "", // Empty password hash for old method
            age: age,
            diocese: diocese,
            completion: completion
        )
    }
    
    // Fetch user by email
    func fetchUser(email: String) async throws -> [String: Any]? {
        let response = try await client
            .from("users")
            .select("*")
            .eq("email", value: email)
            .execute()
        
        if let userData = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
           !userData.isEmpty {
            return userData.first
        }
        
        return nil
    }
    
    // Update user profile
    func updateUserProfile(userId: String, updates: [String: Any]) async throws {
        // Create a struct for the updates to make it Encodable
        struct UserUpdate: Encodable {
            let name: String?
            let first_name: String?
            let last_name: String?
            
            init(from dictionary: [String: Any]) {
                self.name = dictionary["name"] as? String
                self.first_name = dictionary["first_name"] as? String
                self.last_name = dictionary["last_name"] as? String
            }
        }
        
        let userUpdate = UserUpdate(from: updates)
        
        _ = try await client
            .from("users")
            .update(userUpdate)
            .eq("id", value: userId)  // Changed from user_id to id
            .execute()
    }
    
    // Check if email already exists
    func checkEmailExists(email: String) async throws -> Bool {
        let response = try await client
            .from("users")
            .select("email")
            .eq("email", value: email)
            .execute()
        
        if let userData = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]] {
            return !userData.isEmpty
        }
        
        return false
    }
    
    // Update user's curriculum progress
    func updateCurriculumProgress(
        email: String,
        currentDay: Int,
        curriculumOrder: String,
        completedDays: [Int]? = nil
    ) async throws {
        struct ProgressUpdate: Encodable {
            let current_day: String  // Changed to String
            let curriculum_order: String
            let completed_days: [Int]?
        }
        
        let update = ProgressUpdate(
            current_day: String(currentDay),  // Convert Int to String
            curriculum_order: curriculumOrder,
            completed_days: completedDays
        )
        
        _ = try await client
            .from("users")
            .update(update)
            .eq("email", value: email)
            .execute()
    }
    
    // Fetch user's progress
    func fetchUserProgress(email: String) async throws -> (currentDay: Int, curriculumOrder: String, completedDays: [Int]) {
        let response = try await client
            .from("users")
            .select("current_day, curriculum_order, completed_days")
            .eq("email", value: email)
            .execute()
        
        if let userData = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
           let firstUser = userData.first {
            
            // Convert String to Int for currentDay
            let currentDayString = firstUser["current_day"] as? String ?? "0"
            let currentDay = Int(currentDayString) ?? 1
            let curriculumOrder = firstUser["curriculum_order"] as? String ?? "0"
            let completedDays = firstUser["completed_days"] as? [Int] ?? []
            
            return (currentDay, curriculumOrder, completedDays)
        }
        
        return (1, "1", [])
    }
    
    // Test connection method
    func testConnection() async {
        print("🔄 Testing Supabase connection...")
        print("📍 URL: \(baseURL)")  // Use the stored baseURL instead of client.supabaseURL
        
        do {
            // Try a simple query to test the connection
            let response = try await client
                .from("users")
                .select("email")
                .limit(1)
                .execute()
            
            print("✅ Connection successful!")
            print("📊 Response status: Success")
            
            if let data = String(data: response.data, encoding: .utf8) {
                print("📄 Response data: \(data)")
            }
            
        } catch {
            print("❌ Connection failed!")
            print("🚨 Error: \(error)")
            print("📝 Error details: \(error.localizedDescription)")
            
            // Check if it's an authentication error
            if let urlError = error as? URLError {
                print("🔍 URL Error code: \(urlError.code)")
            }
        }
    }
}

// MARK: - Extension for specific table operations

extension SupabaseManager {
    // Fetch homepage excerpt based on current day
    func fetchHomepageExcerpt(forDay currentDay: Int) async throws -> String? {
        do {
            let response = try await client
                .from("homepage_excerpts")
                .select("*")
                .lte("start_day", value: currentDay)  // start_day <= currentDay
                .gte("end_day", value: currentDay)    // end_day >= currentDay
                .single()
                .execute()

            let decoder = JSONDecoder()
            let excerpt = try decoder.decode(HomepageExcerpt.self, from: response.data)
            return excerpt.page_text

        } catch {
            print("Error fetching homepage excerpt: \(error)")
            // Return default Romans 12:2 verse if no excerpt found or error occurs
            return nil
        }
    }

    // Fetch D180 content by curriculum order
    func fetchD180Content(curriculumOrder: Int) async throws -> [[String: Any]] {
        let response = try await client
            .from("d180mens")
            .select("*")
            .eq("curriculum_order", value: curriculumOrder)
            .execute()
        
        if let data = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]] {
            return data
        }
        
        return []
    }
    
    // Fetch D180 content by day
    func fetchD180ContentByDay(day: Int) async throws -> [[String: Any]] {
        let response = try await client
            .from("d180mens")
            .select("*")
            .eq("day", value: day)
            .execute()
        
        if let data = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]] {
            return data
        }
        
        return []
    }
}

// MARK: - Extension for WeekReview and Planning operations

extension SupabaseManager {
    // Save or update weekly review
    func saveWeeklyReview(userId: String, weekNumber: Int, reviewData: [String: Any]) async throws {
        struct WeekReviewData: Encodable {
            let user_id: String  // This might still be user_id in the WeekReview table
            let week_number: String
            let created_at: String
            // Add other fields as needed based on your WeekReview table structure
        }
        
        // Implementation depends on your WeekReview table structure
    }
    
    // Save or update planning ahead
    func savePlanningAhead(userId: String, weekNumber: Int, planningData: [String: Any]) async throws {
        struct PlanningAheadData: Encodable {
            let user_id: String  // This might still be user_id in the planning_ahead table
            let week_number: String
            let created_at: String
            // Add other fields as needed based on your planning_ahead table structure
        }
        
        // Implementation depends on your planning_ahead table structure
    }
}
