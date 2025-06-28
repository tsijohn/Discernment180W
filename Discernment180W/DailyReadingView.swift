import SwiftUI
import Supabase
import Combine

struct D180mens: Codable, Identifiable {
    let id: Int
    let day_text: String
    let title: String
    let subtitle: String?  // FIXED: Made optional to handle null values
    let day: Int
    let curriculum_order: Int  // Changed to Int to match database
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
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            font-size: 16px;
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
    var useCurrentDay: Bool = false // New parameter to indicate if we should use curriculum_order

    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) private var openURL
    
    @State private var readings: [D180mens] = []
    @State private var currentDay: String = ""
    @State private var completedDays: [Int] = []
    @State private var isLoading = true
    @State private var currentWeek: Int = 1
    @State private var refreshTrigger = false
    @State private var shouldNavigateToNext = false // NEW: Navigation trigger
    @State private var nextCurriculumOrder: String = "" // NEW: Store next curriculum order
    @State private var originalCurriculumOrder: String = "" // NEW: Store original curriculum_order
    
    // ENHANCED: Complete Planning Ahead state variables for weekly previews
    @State private var massScheduledDays: [Bool] = Array(repeating: false, count: 7)
    @State private var confessionScheduledDays: [Bool] = Array(repeating: false, count: 7)
    @State private var meditationReadingDate = Date()
    @State private var isSpiritualMercyScheduled: Bool? = nil
    @State private var isCorporalMercyScheduled: Bool? = nil
    @State private var scheduleNotes: String = ""
    @State private var isSpiritualDirectionScheduled: Bool? = nil
    @State private var isSeminaryVisitScheduled: Bool? = nil
    @State private var isDiscernmentRetreatScheduled: Bool? = nil
    @State private var showingSaveConfirmation = false

    // Color constants
    private let accentColor = Color.blue
    private let backgroundColor: Color = Color(.systemBackground)
    private let cardColor: Color = Color(.secondarySystemBackground)
    
    // NEW: Check if this is an excursus page
    private var isExcursus: Bool {
        guard let firstReading = readings.first else { return false }
        return firstReading.day == 0 // FIXED: Excursus pages have day = 0
    }
    
    // Computed property for day display text
    private var dayDisplayText: String {
        if isExcursus {
            return "Excursus"
        } else if isWeeklyPreview {
            return "Weekly Preview"
        } else if let firstReading = readings.first, firstReading.day > 0 {
            return "Day \(firstReading.day)"
        } else {
            return "D180"
        }
    }
    private var isWeeklyPreview: Bool {
        guard let firstReading = readings.first else {
            print("❌ No readings found for isWeeklyPreview check")
            return false
        }
        let isPreview = firstReading.title.contains("Preview of Next Week")
        print("🔍 isWeeklyPreview check - title: '\(firstReading.title)', isPreview: \(isPreview)")
        return isPreview
    }
    
    init(day: String? = nil, useCurrentDay: Bool = false) {
        self.day = day
        self.useCurrentDay = useCurrentDay
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed header with back button and day indicator
            HStack {
                // Back button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                        Text("Back")
                            .font(.system(size: 17, weight: .medium))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                    )
                }
                
                Spacer()
                
                // Day indicator with d180 icon - truly centered
                if !isLoading && !readings.isEmpty {
                    HStack(spacing: 10) {
                        Image("D180Logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                        
                        Text(dayDisplayText)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                // Home button
                Button(action: {
                    // Multiple approaches to ensure we get to root
                    
                    // First dismiss all modal presentations
                    presentationMode.wrappedValue.dismiss()
                    
                    // Then try multiple methods to get to root
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        // Method 1: Try UIKit navigation
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            
                            var currentVC = window.rootViewController
                            
                            // Navigate through the hierarchy to find navigation controller
                            while currentVC != nil {
                                if let navController = currentVC as? UINavigationController {
                                    navController.popToRootViewController(animated: true)
                                    return
                                } else if let tabController = currentVC as? UITabBarController {
                                    if let selectedNav = tabController.selectedViewController as? UINavigationController {
                                        selectedNav.popToRootViewController(animated: true)
                                        return
                                    }
                                } else if let presented = currentVC?.presentedViewController {
                                    currentVC = presented
                                } else if let children = currentVC?.children, !children.isEmpty {
                                    currentVC = children.first
                                } else {
                                    break
                                }
                            }
                        }
                        
                        // Method 2: Dismiss all and try again
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first,
                               let rootNav = window.rootViewController as? UINavigationController {
                                rootNav.popToRootViewController(animated: true)
                            }
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        Text("Home")
                            .font(.system(size: 17, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGroupedBackground))
            
            // Scrollable content
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
                                            completedDays.contains(reading.day)
                                        },
                                        set: { newValue in
                                            handleToggleComplete(for: reading.day, isComplete: newValue)
                                        }
                                    ),
                                    accentColor: accentColor,
                                    openURL: openURL,
                                    isExcursus: isExcursus,
                                    isWeeklyPreview: isWeeklyPreview
                                )
                            }
                            
                            // ENHANCED: Complete Planning Ahead section for weekly previews
                            if isWeeklyPreview {
                                enhancedPlanningAheadSection
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                        .id(refreshTrigger)
                    }
                }
                
                // NEW: Hidden NavigationLink for auto-navigation
                NavigationLink(
                    destination: DailyReadingView(day: nextCurriculumOrder, useCurrentDay: false),
                    isActive: $shouldNavigateToNext
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        .task {
            await loadAllData()
        }
        .alert("Success", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your planning ahead preferences have been saved.")
        }
        .onAppear {
            if isWeeklyPreview {
                Task {
                    await loadExistingPlanningData()
                }
            }
        }
    }
    
    // ENHANCED: Complete Planning Ahead Section View
    private var enhancedPlanningAheadSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Planning Ahead")
                .font(.custom("Georgia", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.leading, 16)
            
            // Mass Schedule
            VStack(alignment: .leading, spacing: 10) {
                Text("I will attend Mass on the following days this week:")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                
                HStack {
                    ForEach(0..<7) { index in
                        Button(action: {
                            massScheduledDays[index].toggle()
                        }) {
                            Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(massScheduledDays[index] ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(massScheduledDays[index] ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.leading, 16)
            }
            
            // Confession Schedule
            VStack(alignment: .leading, spacing: 10) {
                Text("I will go to Confession on the following days this week:")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                
                HStack {
                    ForEach(0..<7) { index in
                        Button(action: {
                            confessionScheduledDays[index].toggle()
                        }) {
                            Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(confessionScheduledDays[index] ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(confessionScheduledDays[index] ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.leading, 16)
            }
            
            // Meditation Reading Date
            VStack(alignment: .leading, spacing: 10) {
                Text("When will you complete your meditation reading for next week?")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                
                DatePicker("", selection: $meditationReadingDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding(.horizontal, 16)
            }
            
            // Yes/No Questions
            enhancedPlanningQuestions
            
            // Schedule Notes
            VStack(alignment: .leading, spacing: 10) {
                Text("Additional scheduling notes:")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                
                TextEditor(text: $scheduleNotes)
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(8)
                    .frame(height: 100)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
            }
            
            // Save Button
            Button(action: {
                savePlanningAhead()
            }) {
                Text("Save Planning Ahead")
                    .font(.custom("Georgia", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
    
    // ENHANCED: Complete Planning Questions Section
    private var enhancedPlanningQuestions: some View {
        VStack(spacing: 15) {
            planningQuestion(
                text: "Will you schedule spiritual works of mercy this week?",
                binding: $isSpiritualMercyScheduled
            )
            
            planningQuestion(
                text: "Will you schedule corporal works of mercy this week?",
                binding: $isCorporalMercyScheduled
            )
            
            planningQuestion(
                text: "Will you schedule spiritual direction this week?",
                binding: $isSpiritualDirectionScheduled
            )
            
            planningQuestion(
                text: "Will you schedule a seminary visit this week?",
                binding: $isSeminaryVisitScheduled
            )
            
            planningQuestion(
                text: "Will you schedule a discernment retreat this week?",
                binding: $isDiscernmentRetreatScheduled
            )
        }
    }
    
    // Helper function for Yes/No questions
    private func planningQuestion(text: String, binding: Binding<Bool?>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(text)
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                Spacer()
                HStack {
                    Button(action: { binding.wrappedValue = true }) {
                        Text("Yes")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(binding.wrappedValue == true ? .white : .black)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(binding.wrappedValue == true ? Color.blue : Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    }
                    Button(action: { binding.wrappedValue = false }) {
                        Text("No")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(binding.wrappedValue == false ? .white : .black)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(binding.wrappedValue == false ? Color.blue : Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    }
                }
                .padding(.trailing, 16)
            }
        }
    }
    
    // ENHANCED: Load existing planning data when viewing weekly preview
    private func loadExistingPlanningData() async {
        do {
            let weekNumber = extractWeekNumber()
            
            let response = try await SupabaseManager.shared.client
                .from("WeekReview")
                .select("mass_scheduled_days, confession_scheduled_days, meditation_reading_date, is_spiritual_mercy_scheduled, is_corporal_mercy_scheduled, is_spiritual_direction_scheduled, is_seminary_visit_scheduled, is_discernment_retreat_scheduled, schedule_notes")
                .eq("user_id", value: "ae88bf9d-f37b-4919-88b8-74a8c2ff5c8b")
                .eq("week_number", value: String(weekNumber))
                .execute()
            
            let jsonData = response.data
            
            if let dataArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
               !dataArray.isEmpty {
                let existingData = dataArray[0]
                
                await MainActor.run {
                    loadPlanningDataIntoState(existingData)
                }
                
                print("✅ Loaded existing planning data for week \(weekNumber)")
            } else {
                print("ℹ️ No existing planning data found for week \(weekNumber)")
            }
        } catch {
            print("❌ Error loading existing planning data: \(error)")
        }
    }
    
    // Helper function to load planning data into state
    @MainActor
    private func loadPlanningDataIntoState(_ data: [String: Any]) {
        // Helper function to parse JSON array strings
        func parseDaysArray(_ jsonString: String?) -> [Bool] {
            let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            var boolArray = Array(repeating: false, count: 7)
            
            guard let jsonString = jsonString,
                  let jsonData = jsonString.data(using: .utf8),
                  let dayArray = try? JSONSerialization.jsonObject(with: jsonData) as? [String] else {
                return Array(repeating: false, count: 7)
            }
            
            for (index, dayName) in dayNames.enumerated() {
                if dayArray.contains(dayName) {
                    boolArray[index] = true
                }
            }
            
            return boolArray
        }
        
        // Load mass scheduled days
        if let massScheduledDaysString = data["mass_scheduled_days"] as? String {
            massScheduledDays = parseDaysArray(massScheduledDaysString)
        }
        
        // Load confession scheduled days
        if let confessionScheduledDaysString = data["confession_scheduled_days"] as? String {
            confessionScheduledDays = parseDaysArray(confessionScheduledDaysString)
        }
        
        // Load meditation reading date
        if let meditationDateString = data["meditation_reading_date"] as? String {
            let dateFormatter = ISO8601DateFormatter()
            if let parsedDate = dateFormatter.date(from: meditationDateString) {
                meditationReadingDate = parsedDate
            }
        }
        
        // Load boolean values
        if let spiritualMercyString = data["is_spiritual_mercy_scheduled"] as? String {
            isSpiritualMercyScheduled = spiritualMercyString.lowercased() == "true" ? true : (spiritualMercyString.lowercased() == "false" ? false : nil)
        }
        
        if let corporalMercyString = data["is_corporal_mercy_scheduled"] as? String {
            isCorporalMercyScheduled = corporalMercyString.lowercased() == "true" ? true : (corporalMercyString.lowercased() == "false" ? false : nil)
        }
        
        if let spiritualDirectionString = data["is_spiritual_direction_scheduled"] as? String {
            isSpiritualDirectionScheduled = spiritualDirectionString.lowercased() == "true" ? true : (spiritualDirectionString.lowercased() == "false" ? false : nil)
        }
        
        if let seminaryVisitString = data["is_seminary_visit_scheduled"] as? String {
            isSeminaryVisitScheduled = seminaryVisitString.lowercased() == "true" ? true : (seminaryVisitString.lowercased() == "false" ? false : nil)
        }
        
        if let discernmentRetreatString = data["is_discernment_retreat_scheduled"] as? String {
            isDiscernmentRetreatScheduled = discernmentRetreatString.lowercased() == "true" ? true : (discernmentRetreatString.lowercased() == "false" ? false : nil)
        }
        
        // Load schedule notes
        if let notes = data["schedule_notes"] as? String {
            scheduleNotes = notes
        }
    }
    
    // ENHANCED: Save Planning Ahead data to database and increment curriculum_order
    private func savePlanningAhead() {
        Task {
            do {
                let dateFormatter = ISO8601DateFormatter()
                let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                
                // Convert boolean arrays to arrays of day names
                let massScheduledDaysNames = massScheduledDays.enumerated()
                    .filter { $0.element }
                    .map { dayNames[$0.offset] }
                
                let confessionScheduledDaysNames = confessionScheduledDays.enumerated()
                    .filter { $0.element }
                    .map { dayNames[$0.offset] }
                
                // Convert arrays to JSON strings for Supabase storage
                let massScheduledDaysJSON = try JSONSerialization.data(withJSONObject: massScheduledDaysNames)
                let massScheduledDaysString = String(data: massScheduledDaysJSON, encoding: .utf8) ?? "[]"
                
                let confessionScheduledDaysJSON = try JSONSerialization.data(withJSONObject: confessionScheduledDaysNames)
                let confessionScheduledDaysString = String(data: confessionScheduledDaysJSON, encoding: .utf8) ?? "[]"
                
                // Get the current week number
                let weekNumber = extractWeekNumber()
                print("🔍 Saving planning data for week: \(weekNumber)")
                
                // Build the payload for planning ahead data (matching WeekReview structure)
                var payload: [String: String] = [
                    "created_at": dateFormatter.string(from: Date()),
                    "user_id": "ae88bf9d-f37b-4919-88b8-74a8c2ff5c8b",
                    "week_number": String(weekNumber),
                    "mass_scheduled_days": massScheduledDaysString,
                    "confession_scheduled_days": confessionScheduledDaysString,
                    "meditation_reading_date": dateFormatter.string(from: meditationReadingDate),
                    "schedule_notes": scheduleNotes
                ]
                
                print("🔍 Mass scheduled days: \(massScheduledDaysString)")
                print("🔍 Confession scheduled days: \(confessionScheduledDaysString)")
                print("🔍 Schedule notes: \(scheduleNotes)")
                print("🔍 Meditation date: \(dateFormatter.string(from: meditationReadingDate))")
                
                // Add optional booleans with null handling
                if let value = isSpiritualMercyScheduled {
                    payload["is_spiritual_mercy_scheduled"] = value ? "true" : "false"
                    print("🔍 Spiritual mercy scheduled: \(value)")
                }
                
                if let value = isCorporalMercyScheduled {
                    payload["is_corporal_mercy_scheduled"] = value ? "true" : "false"
                    print("🔍 Corporal mercy scheduled: \(value)")
                }
                
                if let value = isSpiritualDirectionScheduled {
                    payload["is_spiritual_direction_scheduled"] = value ? "true" : "false"
                    print("🔍 Spiritual direction scheduled: \(value)")
                }
                
                if let value = isSeminaryVisitScheduled {
                    payload["is_seminary_visit_scheduled"] = value ? "true" : "false"
                    print("🔍 Seminary visit scheduled: \(value)")
                }
                
                if let value = isDiscernmentRetreatScheduled {
                    payload["is_discernment_retreat_scheduled"] = value ? "true" : "false"
                    print("🔍 Discernment retreat scheduled: \(value)")
                }
                
                print("🔍 Final payload: \(payload)")
                
                // Check if a record already exists with this user_id and week_number
                let response = try await SupabaseManager.shared.client
                    .from("WeekReview")
                    .select("id")
                    .eq("user_id", value: "ae88bf9d-f37b-4919-88b8-74a8c2ff5c8b")
                    .eq("week_number", value: String(weekNumber))
                    .execute()
                
                let jsonData = response.data
                
                // Try to parse the response to see if we found an existing record
                if let dataArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
                   !dataArray.isEmpty,
                   let existingId = dataArray[0]["id"] as? Int {
                    
                    // Record exists, perform an update
                    print("Updating existing WeekReview record with ID: \(existingId)")
                    
                    try await SupabaseManager.shared.client
                        .from("WeekReview")
                        .update(payload)
                        .eq("id", value: String(existingId))
                        .execute()
                } else {
                    // No existing record, perform an insert
                    print("Creating new WeekReview record for planning ahead")
                    
                    try await SupabaseManager.shared.client
                        .from("WeekReview")
                        .insert(payload)
                        .execute()
                }
                
                // IMPORTANT: Increment curriculum_order after saving planning data
                await incrementCurriculumOrder()
                
                await MainActor.run {
                    showingSaveConfirmation = true
                }
                
                print("✅ Successfully saved planning ahead data and incremented curriculum_order")
                
            } catch {
                print("❌ Error saving planning ahead data: \(error)")
            }
        }
    }
    
    // NEW: Function to increment curriculum_order
    private func incrementCurriculumOrder() async {
        do {
            print("🔄 Starting curriculum_order increment")
            
            // Get current curriculum_order from database
            let response = try await SupabaseManager.shared.client
                .from("users")
                .select("curriculum_order")
                .eq("email", value: "Utjohnkkim@gmail.com")
                .execute()
            
            if let dataArray = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
               !dataArray.isEmpty,
               let userData = dataArray.first,
               let currentOrderString = userData["curriculum_order"] as? String,
               let currentOrderInt = Int(currentOrderString) {
                
                print("📊 Current curriculum_order: \(currentOrderString)")
                
                let newOrder = currentOrderInt + 1
                let newOrderString = String(newOrder)
                
                print("📊 Incrementing to: \(newOrderString)")
                
                // Update curriculum_order in database
                let _ = try await SupabaseManager.shared.client
                    .from("users")
                    .update(["curriculum_order": newOrderString])
                    .eq("email", value: "Utjohnkkim@gmail.com")
                    .execute()
                
                print("✅ Successfully incremented curriculum_order from \(currentOrderString) to \(newOrderString)")
            } else {
                print("❌ Failed to parse curriculum_order from database")
            }
        } catch {
            print("❌ Error incrementing curriculum_order: \(error)")
        }
    }
    
    // Extract week number from reading content
    private func extractWeekNumber() -> Int {
        // Try to extract week number from the reading title or day_text
        if let firstReading = readings.first {
            // If day_text contains week number info, parse it
            if let weekMatch = firstReading.day_text.range(of: #"Week (\d+)"#, options: .regularExpression) {
                let weekString = String(firstReading.day_text[weekMatch])
                if let number = Int(weekString.replacingOccurrences(of: "Week ", with: "")) {
                    return number
                }
            }
            
            // Fallback: calculate week from curriculum_order
            let estimatedWeek = (firstReading.curriculum_order / 7) + 1
            return estimatedWeek
        }
        
        return 1 // Default fallback
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
    }
    
    // UPDATED: Handle toggle complete with excursus navigation
    private func handleToggleComplete(for day: Int, isComplete: Bool) {
        // Update local state immediately
        if isComplete {
            if !completedDays.contains(day) {
                completedDays.append(day)
            }
        } else {
            completedDays.removeAll { $0 == day }
        }
        
        // Sort to maintain order
        completedDays.sort()
        
        // Force UI refresh
        refreshTrigger.toggle()
        
        // Update database and handle excursus completion
        Task {
            await updateReadingProgress(for: day, isComplete: isComplete)
            
            // NEW: If this is an excursus and it was marked complete, update curriculum_order but don't navigate
            if isExcursus && isComplete {
                await handleExcursusCompletion()
            }
        }
    }
    
    // NEW: Handle excursus completion (update curriculum_order only, no navigation)
    private func handleExcursusCompletion() async {
        do {
            // FIXED: Use original curriculum_order instead of currentDay
            guard let currentCurriculumOrder = Int(originalCurriculumOrder) else {
                print("❌ Could not convert originalCurriculumOrder to Int: \(originalCurriculumOrder)")
                return
            }
            
            // Increment curriculum_order
            let newCurriculumOrder = currentCurriculumOrder + 1
            let newCurriculumOrderString = String(newCurriculumOrder)
            
            // Update curriculum_order in database (no navigation)
            let _ = try await SupabaseManager.shared.client
                .from("users")
                .update(["curriculum_order": newCurriculumOrderString])
                .eq("email", value: "Utjohnkkim@gmail.com")
                .execute()
            
        } catch {
            print("❌ Error handling excursus completion: \(error)")
        }
    }

    func fetchCompletedDays() async {
        do {
            struct Response: Decodable {
                let completed_days: [Int]?
            }

            let rawResponse = try await SupabaseManager.shared.client
                .from("users")
                .select("completed_days")
                .eq("email", value: "Utjohnkkim@gmail.com")
                .execute()

            let data = rawResponse.data
            
            do {
                let decoded = try JSONDecoder().decode([Response].self, from: data)
                
                if let firstUser = decoded.first {
                    if let existingDays = firstUser.completed_days {
                        // Update on main thread
                        await MainActor.run {
                            self.completedDays = existingDays
                        }
                    } else {
                        await MainActor.run {
                            self.completedDays = []
                        }
                    }
                }
            } catch {
                print("❌ Error decoding completed days: \(error)")
            }
        } catch {
            print("❌ Error fetching completed days: \(error)")
        }
    }

    func fetchData() async {
        if useCurrentDay {
            // Coming from home page - fetch curriculum_order and use it to look up content
            guard let fetchedCurriculumOrder = await fetchCurriculumOrder() else {
                return
            }
            currentDay = fetchedCurriculumOrder
            originalCurriculumOrder = fetchedCurriculumOrder
            await fetchReadingsByCurriculumOrder()
        } else if let specifiedDay = day, !specifiedDay.isEmpty {
            // Coming from navigation hub or other sources
            currentDay = specifiedDay
            originalCurriculumOrder = specifiedDay
            
            // FIXED: Always use fetchReadingsByDay for navigation hub
            // Navigation hub always passes day numbers (1-180)
            if let dayNumber = Int(specifiedDay), dayNumber >= 1 && dayNumber <= 180 {
                await fetchReadingsByDay(dayNumber)
            } else {
                // For other cases (like weekly reviews, excursus), use curriculum_order lookup
                await fetchReadingsByCurriculumOrder()
            }
        } else {
            // Fallback to current_day
            guard let fetchedDay = await fetchCurrentDay() else {
                return
            }
            currentDay = fetchedDay
            originalCurriculumOrder = fetchedDay
            await fetchReadingsByCurriculumOrder()
        }
    }

    func fetchCurriculumOrder() async -> String? {
        do {
            let response: [[String: String]] = try await SupabaseManager.shared.client
                .from("users")
                .select("curriculum_order")
                .eq("email", value: "Utjohnkkim@gmail.com")
                .execute()
                .value

            if let firstUser = response.first,
               let curriculumOrder = firstUser["curriculum_order"] {
                return curriculumOrder
            } else {
                return nil
            }
        } catch {
            print("Error fetching curriculum_order: \(error)")
            return nil
        }
    }

    func fetchCurrentDay() async -> String? {
        do {
            let progress: [[String: String]] = try await SupabaseManager.shared.client
                .from("users")
                .select("current_day")
                .eq("email", value: "Utjohnkkim@gmail.com")
                .execute()
                .value

            if let firstProgress = progress.first,
               let currentDay = firstProgress["current_day"] {
                return currentDay
            } else {
                return nil
            }
        } catch {
            print("Error fetching current day: \(error)")
            return nil
        }
    }

    func fetchReadingsByCurriculumOrder() async {
        do {
            readings = try await SupabaseManager.shared.client
                .from("d180mens")
                .select("*")
                .eq("curriculum_order", value: Int(currentDay) ?? 1)
                .execute()
                .value
            
            // Update currentDay appropriately based on content type
            if let firstReading = readings.first {
                await MainActor.run {
                    if firstReading.day == 0 {
                        // This is an excursus - keep currentDay as curriculum_order for proper display
                        // Don't change currentDay - it should remain as the curriculum_order
                    } else {
                        // This is a regular daily reading - update currentDay to the actual day number
                        self.currentDay = String(firstReading.day)
                    }
                    // Always store the original curriculum_order for database operations
                    if self.originalCurriculumOrder.isEmpty {
                        self.originalCurriculumOrder = self.currentDay
                    }
                }
            }
        } catch {
            print("Error fetching readings by curriculum_order: \(error)")
        }
    }

    func fetchReadingsByDay(_ dayNumber: Int) async {
        do {
            readings = try await SupabaseManager.shared.client
                .from("d180mens")
                .select("*")
                .eq("day", value: dayNumber)
                .execute()
                .value
            
            // For day-based lookups, we need to get the curriculum_order for database operations
            if let firstReading = readings.first {
                await MainActor.run {
                    self.currentDay = String(firstReading.day)
                    self.originalCurriculumOrder = String(firstReading.curriculum_order)
                }
            }
        } catch {
            print("Error fetching readings by day: \(error)")
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
                }
            } catch {
                print("Error decoding response: \(error)")
            }
            
            // Handle both adding and removing
            if isComplete {
                if !daysArray.contains(day) {
                    daysArray.append(day)
                }
            } else {
                daysArray.removeAll { $0 == day }
            }
            
            daysArray.sort()
            
            // EXISTING: Handle curriculum_order increment for database logic
            var nextCurriculumOrder = "1" // Default value
            
            if day < 0 {
                // This is a weekly review (negative day) - increment from current curriculum_order
                if let currentCurriculumOrderInt = Int(originalCurriculumOrder) {
                    nextCurriculumOrder = String(currentCurriculumOrderInt + 1)
                } else {
                    print("❌ Could not convert originalCurriculumOrder to Int: \(originalCurriculumOrder)")
                }
            } else {
                // This is a regular daily reading - look up by day
                let largestCompletedDay = daysArray.max() ?? 0
                
                if largestCompletedDay > 0 {
                    struct D180MensResponse: Decodable {
                        let curriculum_order: Int
                    }
                    
                    let d180Response = try await SupabaseManager.shared.client
                        .from("d180mens")
                        .select("curriculum_order")
                        .eq("day", value: largestCompletedDay)
                        .execute()
                    
                    do {
                        let decoded = try JSONDecoder().decode([D180MensResponse].self, from: d180Response.data)
                        if let firstEntry = decoded.first {
                            let currentOrder = firstEntry.curriculum_order
                            nextCurriculumOrder = String(currentOrder + 1)
                        }
                    } catch {
                        print("Error decoding d180mens response: \(error)")
                    }
                }
            }
            
            // NEW: Calculate curriculum_order for the current page
            var updatedCurriculumOrder = "1" // Default value
            
            if isComplete {
                // When marking complete: increment current page's curriculum_order by 1
                if let currentCurriculumOrderInt = Int(originalCurriculumOrder) {
                    updatedCurriculumOrder = String(currentCurriculumOrderInt + 1)
                } else {
                    print("❌ Could not convert originalCurriculumOrder to Int for curriculum_order update: \(originalCurriculumOrder)")
                    updatedCurriculumOrder = nextCurriculumOrder // Fallback to existing logic
                }
            } else {
                // When marking incomplete: set curriculum_order back to current page's curriculum_order
                updatedCurriculumOrder = originalCurriculumOrder
            }
            
            struct ReadingProgress: Encodable {
                let current_day: Int
                let completed_days: [Int]
                let current_week: Int
                let curriculum_order: String
            }
            
            // EXISTING: Smart current_day logic that handles weekly reviews
            let newCurrentDay: Int
            if day < 0 {
                // Weekly review (negative day) - don't change current_day
                newCurrentDay = daysArray.max() ?? 0
            } else {
                // Regular daily reading
                newCurrentDay = isComplete ? day + 1 : (daysArray.max() ?? 0) + 1
            }
            
            let progress = ReadingProgress(
                current_day: newCurrentDay,
                completed_days: daysArray,
                current_week: calculateCurrentWeek(fromDays: daysArray),
                curriculum_order: updatedCurriculumOrder // NEW: Use the updated curriculum_order
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
            
            print("✅ Updated current_day to: \(newCurrentDay), curriculum_order to: \(updatedCurriculumOrder) for day: \(day), isComplete: \(isComplete)")
            
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
    let isExcursus: Bool
    let isWeeklyPreview: Bool // NEW: Weekly preview flag
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(reading.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(reading.subtitle ?? "")  // FIXED: Handle optional subtitle
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundColor(.primary.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Divider()
            
            Text(reading.day_text.htmlToAttributedString())
                .lineSpacing(6)
                .tint(accentColor)
                .environment(\.openURL, openURL)
                .fixedSize(horizontal: false, vertical: true)
            
            // Only show toggle for non-weekly preview items
            if !isWeeklyPreview {
                HStack {
                    // Different text for excursus pages with smaller, lighter font
                    Text(isExcursus ? "Mark as Read & Continue" : "Mark as Complete")
                        .font(.caption)
                        .fontWeight(.regular)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Toggle("", isOn: $isComplete)
                        .toggleStyle(SwitchToggleStyle(tint: accentColor))
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .overlay(
            isComplete && !isWeeklyPreview ?
            RoundedRectangle(cornerRadius: 16)
                .stroke(accentColor, lineWidth: 2)
            : nil
        )
        .animation(.easeInOut(duration: 0.2), value: isComplete)
    }
}
