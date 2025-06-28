import SwiftUI

class AppState: ObservableObject {
    @Published var currentDayText: String = "" // For the current day's text
    @Published var curriculumOrder: String = "" // For the curriculum order
    
    /// Fetches the current day and curriculum order from the database for the given email.
    func fetchCurrentDay(for email: String) async {
        print("Fetching current day and curriculum order for email: \(email)...")
        do {
            // Query the Supabase database for the user's current day and curriculum order.
            let progress: [[String: String]] = try await SupabaseManager.shared.client
                .from("users")
                .select("current_day, curriculum_order")
                .eq("email", value: "Utjohnkkim@gmail.com")
                .execute()
                .value

            if let firstProgress = progress.first {
                print("Full progress data: \(firstProgress)") // Debug log
                
                // Fetch current_day
                if let currentDay = firstProgress["current_day"] {
                    print("AppState fetched current_day: \(currentDay)")
                    currentDayText = currentDay
                } else {
                    print("No current_day found for the user.")
                    currentDayText = "1"
                }
                
                // Fetch curriculum_order
                if let currOrder = firstProgress["curriculum_order"] {
                    print("AppState fetched curriculum_order: \(currOrder)")
                    curriculumOrder = currOrder
                } else {
                    print("No curriculum_order found for the user.")
                    curriculumOrder = ""
                }
            } else {
                print("No progress found for the user.")
                currentDayText = "1"
                curriculumOrder = ""
            }
        } catch {
            print("Error fetching current day and curriculum order: \(error)")
            currentDayText = "1"
            curriculumOrder = ""
        }
    }
}
