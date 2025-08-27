import SwiftUI

class AppState: ObservableObject {
    @Published var currentDayText: String = "" // For the current day's text
    @Published var curriculumOrder: String = "" // For the curriculum order
    
    /// Fetches the current day and curriculum order from the database for the given email.
    func fetchCurrentDay(for email: String) async {
        // Don't fetch if no email is provided
        guard !email.isEmpty else {
            print("No email provided for fetchCurrentDay")
            currentDayText = "1"
            curriculumOrder = "1"
            return
        }
        
        print("Fetching current day and curriculum order for email: \(email)...")
        do {
            // Query the Supabase database for the user's current day and curriculum order.
            let response = try await SupabaseManager.shared.client
                .from("users")
                .select("current_day, curriculum_order")
                .eq("email", value: email) // Now uses the passed email parameter
                .execute()
            
            // Parse the response
            if let dataArray = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
               !dataArray.isEmpty,
               let firstProgress = dataArray.first {
                
                print("Full progress data: \(firstProgress)") // Debug log
                
                await MainActor.run {
                    // Fetch current_day - handle both String and Int types
                    if let currentDay = firstProgress["current_day"] as? String {
                        print("AppState fetched current_day (String): \(currentDay)")
                        self.currentDayText = currentDay
                    } else if let currentDay = firstProgress["current_day"] as? Int {
                        print("AppState fetched current_day (Int): \(currentDay)")
                        self.currentDayText = String(currentDay)
                    } else {
                        print("No current_day found for the user.")
                        self.currentDayText = "1"
                    }
                    
                    // Fetch curriculum_order
                    if let currOrder = firstProgress["curriculum_order"] as? String {
                        print("AppState fetched curriculum_order: \(currOrder)")
                        self.curriculumOrder = currOrder
                    } else if let currOrder = firstProgress["curriculum_order"] as? Int {
                        print("AppState fetched curriculum_order (Int): \(currOrder)")
                        self.curriculumOrder = String(currOrder)
                    } else {
                        print("No curriculum_order found for the user.")
                        self.curriculumOrder = "1"
                    }
                }
            } else {
                print("No progress found for the user.")
                await MainActor.run {
                    currentDayText = "1"
                    curriculumOrder = "1"
                }
            }
        } catch {
            print("Error fetching current day and curriculum order: \(error)")
            await MainActor.run {
                currentDayText = "1"
                curriculumOrder = "1"
            }
        }
    }
    
    /// Updates the curriculum order in the database for the given email
    func updateCurriculumOrder(for email: String, newOrder: String) async {
        guard !email.isEmpty else {
            print("No email provided for updateCurriculumOrder")
            return
        }
        
        do {
            let _ = try await SupabaseManager.shared.client
                .from("users")
                .update(["curriculum_order": newOrder])
                .eq("email", value: email)
                .execute()
            
            await MainActor.run {
                self.curriculumOrder = newOrder
            }
            
            print("✅ Successfully updated curriculum_order to: \(newOrder)")
        } catch {
            print("❌ Error updating curriculum_order: \(error)")
        }
    }
}
