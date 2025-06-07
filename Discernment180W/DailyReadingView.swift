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

// Helper function to convert HTML to AttributedString with proper text size
extension String {
    func htmlToAttributedString() -> AttributedString {
        // Add base CSS to maintain font size
        let htmlWithStyle = """
        <html>
        <head>
        <style>
        body {
            font-family: Palatino;
            font-size: 18px;
            color: black;
        }
        a {
            text-decoration: underline;
        }
        </style>
        </head>
        <body>
        \(self)
        </body>
        </html>
        """
        
        guard let data = htmlWithStyle.data(using: .utf8) else {
            return AttributedString(self)
        }
        
        do {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            
            let nsAttributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            return AttributedString(nsAttributedString)
        } catch {
            print("Error converting HTML to AttributedString: \(error)")
            return AttributedString(self)
        }
    }
}

struct DailyReadingView: View {
    var day: String?

    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) private var openURL
    
    @State private var readings: [D180mens] = []
    @State private var currentDay: String = ""
    @State private var completedDays: [Int] = []
    @State private var isLoading = true
    @State private var currentWeek: Int = 1
    @State private var refreshTrigger = false

    // Color constants
    private let accentColor = Color.blue
    private let backgroundColor: Color = Color(.systemBackground)
    private let cardColor: Color = Color(.secondarySystemBackground)
    
    init(day: String? = nil) {
        self.day = day
        print("DailyReadingView initialized with day parameter: \(String(describing: day))")
    }
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            if isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading your reading...")
                        .padding(.top, 16)
                        .foregroundColor(.secondary)
                }
            } else if readings.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No readings available")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Check back later for your next reading")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(readings) { reading in
                            ReadingCard(
                                reading: reading,
                                isComplete: Binding(
                                    get: {
                                        let isComplete = completedDays.contains(reading.day)
                                        print("📱 Getting isComplete for day \(reading.day): \(isComplete), completedDays: \(completedDays)")
                                        return isComplete
                                    },
                                    set: { newValue in
                                        print("📱 Setting isComplete for day \(reading.day) to \(newValue)")
                                        handleToggleComplete(for: reading.day, isComplete: newValue)
                                    }
                                ),
                                accentColor: accentColor,
                                openURL: openURL
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 24) // Increased from default to 24
                    .padding(.bottom, 16)
                    .id(refreshTrigger)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 8) {
                            Image("D180Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 24)
                            
                            Text("Day \(readings.first?.day ?? 0)")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .task {
            await loadAllData()
        }
    }
    
    // Load data in the correct order
    private func loadAllData() async {
        isLoading = true
        
        // First fetch the reading data
        await fetchData()
        
        // Then fetch completed days BEFORE showing the UI
        await fetchCompletedDays()
        
        // Only now show the UI
        isLoading = false
        
        print("🎯 Data loading complete. CompletedDays: \(completedDays)")
    }
    
    private func handleToggleComplete(for day: Int, isComplete: Bool) {
        print("🔄 Toggling day \(day) to \(isComplete)")
        
        // Update local state immediately
        if isComplete {
            if !completedDays.contains(day) {
                completedDays.append(day)
                print("✅ Added day \(day) to completedDays locally")
            }
        } else {
            completedDays.removeAll { $0 == day }
            print("❌ Removed day \(day) from completedDays locally")
        }
        
        // Sort to maintain order
        completedDays.sort()
        print("📱 Final local completedDays: \(completedDays)")
        
        // Force UI refresh
        refreshTrigger.toggle()
        
        // Update database
        Task {
            await updateReadingProgress(for: day, isComplete: isComplete)
        }
    }

    func fetchCompletedDays() async {
        do {
            struct Response: Decodable {
                let completed_days: [Int]?
            }

            print("📡 Fetching completed days for email: Utjohnkkim@gmail.com")
            let rawResponse = try await SupabaseManager.shared.client
                .from("users")
                .select("completed_days")
                .eq("email", value: "Utjohnkkim@gmail.com")
                .execute()

            let data = rawResponse.data
            
            do {
                let decoded = try JSONDecoder().decode([Response].self, from: data)
                print("📡 Successfully decoded \(decoded.count) user records")
                
                if let firstUser = decoded.first {
                    if let existingDays = firstUser.completed_days {
                        // Update on main thread
                        await MainActor.run {
                            self.completedDays = existingDays
                            print("✅ Fetched completed days: \(existingDays)")
                            if let currentDayInt = Int(self.currentDay) {
                                print("🎯 Is current day \(currentDayInt) in completed days? \(existingDays.contains(currentDayInt))")
                            }
                        }
                    } else {
                        print("❌ completed_days field is null")
                        await MainActor.run {
                            self.completedDays = []
                        }
                    }
                } else {
                    print("❌ No user records found")
                }
            } catch {
                print("❌ Error decoding completed days: \(error)")
            }
        } catch {
            print("❌ Error fetching completed days: \(error)")
        }
    }

    func fetchData() async {
        print("day parameter: \(String(describing: day)), type: \(type(of: day))")
        
        if let specifiedDay = day, !specifiedDay.isEmpty {
            print("Using specified day: \(specifiedDay)")
            currentDay = specifiedDay
            await fetchReadings()
        } else {
            print("No day specified (or empty string), fetching user's current day")
            guard let fetchedDay = await fetchcurrentDay() else {
                print("Unable to fetch current day. Exiting fetchData.")
                return
            }
            currentDay = fetchedDay
            await fetchReadings()
        }
    }

    func fetchcurrentDay() async -> String? {
        do {
            let progress: [[String: String]] = try await SupabaseManager.shared.client
                .from("users")
                .select("current_day")
                .eq("email", value: "Utjohnkkim@gmail.com")
                .execute()
                .value

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

    func fetchReadings() async {
        do {
            readings = try await SupabaseManager.shared.client
                .from("d180mens")
                .select("*")
                .eq("day", value: currentDay)
                .execute()
                .value
            
            print("Fetched readings: \(readings)")
        } catch {
            print("Error fetching readings: \(error)")
        }
    }

    func calculateCurrentWeek(fromDays days: [Int]) -> Int {
        let highestCompletedDay = days.max() ?? 0
        let weekNumber = (highestCompletedDay / 7) + 1
        return weekNumber
    }
    
    func updateReadingProgress(for day: Int, isComplete: Bool) async {
        do {
            struct Response: Decodable {
                let completed_days: [Int]?
            }

            let rawResponse = try await SupabaseManager.shared.client
                .from("users")
                .select("completed_days")
                .eq("email", value: "Utjohnkkim@gmail.com")
                .execute()

            var daysArray: [Int] = []
            let data = rawResponse.data
            
            do {
                let decoded = try JSONDecoder().decode([Response].self, from: data)
                if let firstUser = decoded.first, let existingDays = firstUser.completed_days {
                    daysArray = existingDays
                    print("📀 Database completed_days: \(daysArray)")
                }
            } catch {
                print("Error decoding response: \(error)")
            }

            // Handle both adding and removing
            if isComplete {
                if !daysArray.contains(day) {
                    daysArray.append(day)
                    print("📀 Added day \(day) to database")
                }
            } else {
                daysArray.removeAll { $0 == day }
                print("📀 Removed day \(day) from database")
            }
            
            daysArray.sort()
            print("📀 Final database array: \(daysArray)")
            
            struct ReadingProgress: Encodable {
                let current_day: Int
                let completed_days: [Int]
                let current_week: Int
            }

            // Smart current_day logic
            let newCurrentDay = isComplete ? day + 1 : (daysArray.max() ?? 0) + 1

            let progress = ReadingProgress(
                current_day: newCurrentDay,
                completed_days: daysArray,
                current_week: calculateCurrentWeek(fromDays: daysArray)
            )

            let _ = try await SupabaseManager.shared.client
                .from("users")
                .update(progress)
                .eq("email", value: "Utjohnkkim@gmail.com")
                .execute()
            
            // Update local state to match database
            await MainActor.run {
                self.completedDays = daysArray
                self.currentWeek = calculateCurrentWeek(fromDays: daysArray)
            }
            
            print("✅ Database updated successfully - current_day: \(newCurrentDay), completed_days: \(daysArray)")
        } catch {
            print("❌ Error updating reading progress: \(error)")
        }
    }
}

struct ReadingCard: View {
    let reading: D180mens
    @Binding var isComplete: Bool
    let accentColor: Color
    var openURL: OpenURLAction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(reading.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
            
            Text(reading.day_text.htmlToAttributedString())
                .lineSpacing(6)
                .tint(accentColor)
                .environment(\.openURL, openURL)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack {
                Text("Mark as Complete")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()

                
                Toggle("", isOn: $isComplete)
                    .toggleStyle(SwitchToggleStyle(tint: accentColor))
                    .onChange(of: isComplete) { newValue in
                        print("🎚️ Toggle changed for day \(reading.day): \(newValue)")
                    }
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .overlay(
            isComplete ?
            RoundedRectangle(cornerRadius: 16)
                .stroke(accentColor, lineWidth: 2)
            : nil
        )
        .animation(.easeInOut(duration: 0.2), value: isComplete)
    }
}
