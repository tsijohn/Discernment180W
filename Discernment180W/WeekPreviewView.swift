import SwiftUI

struct WeekPreviewView: View {
    @Environment(\.presentationMode) var presentationMode // For navigating back
    @State private var studyText: String = "Loading..."
    @State private var previewText: String = "Loading..."
    @State private var isCompleted: Bool = false // Tracks completion state

    var body: some View {
        ZStack {
            Color(.systemGray6) // Light grey background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 15) {
                // Title and Completion Toggle
                VStack {
                    Text("Week 2 Preview")
                        .font(.custom("Georgia", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 10)

                    // Toggle Slider for Completion
                    HStack {
                        Text("Mark as Completed")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(.black)

                        Spacer()

                        Toggle("", isOn: $isCompleted)
                            .toggleStyle(SwitchToggleStyle(tint: .blue)) // iOS-style switch
                            .onChange(of: isCompleted) { newValue in
                                print("Week preview marked as \(newValue ? "completed" : "not completed")")
                                Task {
                                    await updateCompletionStatus(isCompleted: newValue)
                                }
                            }
                    }
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Prayer Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Prayer")
                                .font(.custom("Georgia", size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.leading, 16)

                            Text(previewText)
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(.black)
                                .lineSpacing(5)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                        }

                        // Study Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Study")
                                .font(.custom("Georgia", size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.leading, 16)

                            Text(studyText)
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(.black)
                                .lineSpacing(5)
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchWeekPreview()
        }
    }

    // Fetches study and preview text from Supabase
    func fetchWeekPreview() async {
        do {
            print("Fetching data from Supabase...") // Debugging Start

            let result: [[String: String]] = try await SupabaseManager.shared.client
                .from("d180menspreview")
                .select("study, prayer, Complete")
                .eq("day", value: "8") // Ensure correct filtering
                .execute()
                .value // Directly access the value without JSON decoding

            print("Raw result from Supabase:", result) // Print full result
            
            if let firstResult = result.first {
                print("First result:", firstResult) // Print first record
                
                studyText = firstResult["study"] ?? "No study content available."
                previewText = firstResult["prayer"] ?? "No preview content available."
                isCompleted = (firstResult["Complete"] == "Yes") // Convert "Yes"/"No" to Boolean
            } else {
                print("No matching records found.")
                studyText = "No study content available."
                previewText = "No preview content available."
            }
        } catch {
            print("Error fetching week preview:", error) // Print error details
            studyText = "Failed to load study content."
            previewText = "Failed to load preview content."
        }
    }

    // Updates completion status in Supabase
    func updateCompletionStatus(isCompleted: Bool) async {
            let completionStatus = isCompleted ? "Yes" : "No"

            do {
                print("Updating completion status to \(completionStatus)...")
                
                let _ = try await SupabaseManager.shared.client
                    .from("d180menspreview")
                    .update(["Complete": completionStatus]) // Pass the dictionary directly, no 'values:' label
                    .eq("day", value: "8") // Match the correct user_id
                    .execute()
                

            } catch {
                print("Error updating completion status:", error)
            }
        }
}

struct WeekPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        WeekPreviewView()
    }
}

