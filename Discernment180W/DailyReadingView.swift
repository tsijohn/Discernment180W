import SwiftUI
import Supabase
import Combine

struct D180mens: Codable, Identifiable {
    let id: Int
    let day_text: String
    let title: String
    let day: Int
}

struct D180Progress: Codable {
    let user_id: Int
    var current_day: String
}

struct DailyReadingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var readings: [D180mens] = []
    @State private var currentDay: String = ""
    @State private var completedDays: [Int] = []
    @State private var isReadingComplete = false
    
    var body: some View {
        List {
            ForEach(readings) { reading in
                VStack(alignment: .leading) {
                    Text(reading.title)
                        .font(.title3)
                        .fontWeight(.bold) // Make it bold
                        .padding(.bottom) // Add some space below
                    
                    Text(reading.day_text)
                        .navigationTitle("Day \(reading.day)") // Set the navigationTitle based on day_text
                           
                    HStack {
                        Text("Mark Reading as Complete")
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { completedDays.contains(reading.id) },
                            set: { newValue in
                                Task {
                                    if newValue {
                                        completedDays.append(reading.id)
                                        await updateReadingProgress(for: reading.day)
                                    } else {
                                        completedDays.removeAll { $0 == reading.id }
                                    }
                                    await fetchReadings()
                                }
                            }
                        ))
                        .onAppear {
                            isReadingComplete = completedDays.contains(reading.id)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding()
            }
        }

//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: {
//                    // Action here
//                }) {
//                    Image(systemName: "star")
//                }
//            }
//        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: {
//                    dismiss()
//                }) {
//                    Image(systemName: "xmark.circle.fill")
//                        .font(.title2)
//                }
//            }
//        }
        .overlay {
            if readings.isEmpty {
                ProgressView()
            }
        }
        .task {
            // Fetch the current day and use it to fetch readings
            await fetchData()
        }
    }

    func fetchData() async {
        // Fetch current day and readings
        guard let fetchedDay = await fetchcurrentDay() else {
            print("Unable to fetch current day. Exiting fetchData.")
            return
        }
        currentDay = fetchedDay
        await fetchReadings()
    }

    // Fetch the current day as a string
    func fetchcurrentDay() async -> String? {
        do {
            // Fetch the current_day from the database
            let progress: [[String: String]] = try await SupabaseManager.shared.client
                .from("D180Progress")
                .select("current_day")
                .eq("user_id", value: 1)
                .execute()
                .value

            // Ensure we have a result and return the current_day
            if let firstProgress = progress.first,
               let currentDay = firstProgress["current_day"] {
                print("Fetched current_day: \(currentDay)")
                return currentDay
            } else {
                print("No progress found for the user.")
                return nil
            }
        } catch {
            print("Error fetching current day: \(error)")
            return nil
        }
    }

    // Fetch readings for the current day
    func fetchReadings() async {
        do {
            readings = try await SupabaseManager.shared.client
                .from("d180mens")
                .select("*")
                .eq("day", value: currentDay) // Use the current day
                .execute()
                .value
            
            print("Fetched readings: \(readings)")
        } catch {
            print("Error fetching readings: \(error)")
        }
    }

//    func loadReadingProgress() async {
//        do {
//            // let currentUser = try await supabase.auth.session.user
//
//            let progress: UserReadingProgress = try await supabase.database
//                .from("user_reading_progress")
//                .select()
//                .eq("user_id", value: 1)
//                .single()
//                .execute()
//                .value
//
//            currentDay = progress.current_day
//
//        } catch {
//            debugPrint(error)
//        }
//    }
    
//    func updateReadingProgress(for day: Int, isComplete: Bool) {
//        guard let userId = SupabaseManager.shared.client.auth.currentUser?.id else {
//            print("No user logged in.")
//            return
//        }
//
//        Task {
//            do {
//                if isComplete {
//                    if !completedDays.contains(day) {
//                        completedDays.append(day)
//                    }
//                    if day == currentDay && day < 180 {
//                        currentDay += 1
//                    }
//                } else {
//                    completedDays.removeAll(where: { $0 == day })
//                    if day == currentDay && day > 1 {
//                        currentDay -= 1
//                    }
//                }
//
//                let updatedProgress = UserReadingProgress(
//                    user_id: 4,
//                    current_day: currentDay,
//                    completed_days: completedDays
//                )
//
//                let _: UserReadingProgress = try await SupabaseManager.shared.client
//                    .from("user_reading_progress")
//                    .upsert(updatedProgress, onConflict: "user_id")
//                    .execute()
//                    .value
//
//                await fetchReadings()
//            } catch {
//                print("Error updating reading progress: \(error)")
//            }
//        }
//    }

    func updateReadingProgress(for day: Int) async {
        do {
            // Create a dictionary with the updated value
            let updatedProgress = ["current_day": day + 1]
            
            // Perform the update query
            let _ = try await SupabaseManager.shared.client
                .from("D180Progress")
                .update(updatedProgress) // Pass the dictionary directly, no 'values:' label
                .eq("user_id", value: 1) // Match the correct user_id
                .execute()
            
            print("Successfully updated current_day to \(day + 1)")
        } catch {
            print("Error updating reading progress: \(error)")
        }
    }
}

