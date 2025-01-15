import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    
    @Published var currentDayText: String = "" // For the current day's text
    
    func fetchCurrentDay() async {
        print("Fetching current day...")  // Check if the function is called
        do {
            let progress: [[String: String]] = try await SupabaseManager.shared.client
                .from("D180Progress")
                .select("current_day")
                .eq("user_id", value: 1)
                .execute()
                .value

            if let firstProgress = progress.first,
               let currentDay = firstProgress["current_day"] {
                print("App State Fetched current_day: \(currentDay)")
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
