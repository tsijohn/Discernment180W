import SwiftUI


class AppState: ObservableObject {
    @Published var currentDayText: String = "" // For the current day's text
    
    /// Fetches the current day from the database for the given email.
    func fetchCurrentDay(for email: String) async {
        print("Fetching current day for email: \(email)...")
        do {
            // Query the Supabase database for the user's current day.
            let progress: [[String: String]] = try await SupabaseManager.shared.client
                .from("users")
                .select("current_day")
                .eq("email", value: "Utjohnkkim@gmail.com")
                .execute()
                .value

            if let firstProgress = progress.first,
               let currentDay = firstProgress["current_day"] {
                print("AppState fetched current_day: \(currentDay)")
                currentDayText = currentDay
            } else {
                print("No progress found for the user.")
                currentDayText = "Day 1"
            }
        } catch {
            print("Error fetching current day: \(error)")
            currentDayText = "Day 1"
        }
    }
}
