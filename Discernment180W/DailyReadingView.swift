import SwiftUI
import Supabase
import Combine

struct D180mens: Codable, Identifiable {
    let id: Int
    let day_text: String
    let title: String
    let subtitle: String?
    let day: Int
    let curriculum_order: Int?  // Make this optional to handle null values
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

// User Session Manager to get current user
class UserSessionManager: ObservableObject {
    static let shared = UserSessionManager()
    
    @Published var currentUserEmail: String?
    @Published var currentUserId: String?
    
    private init() {}
    
    func getCurrentUser() async throws -> (email: String, userId: String) {
        // Check if we have cached values
        if let email = currentUserEmail, let userId = currentUserId {
            return (email, userId)
        }
        
        // Otherwise fetch from UserDefaults or your auth system
        if let email = UserDefaults.standard.string(forKey: "userEmail"),
           let userId = UserDefaults.standard.string(forKey: "userId") {
            await MainActor.run {
                self.currentUserEmail = email
                self.currentUserId = userId
            }
            return (email, userId)
        }
        
        throw NSError(domain: "UserSession", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user logged in"])
    }
    
    func setCurrentUser(email: String, userId: String) {
        UserDefaults.standard.set(email, forKey: "userEmail")
        UserDefaults.standard.set(userId, forKey: "userId")
        currentUserEmail = email
        currentUserId = userId
    }
    
    func clearSession() {
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userId")
        currentUserEmail = nil
        currentUserId = nil
    }
}

struct DailyReadingView: View {
    var day: String?
    var useCurrentDay: Bool = false
    let showSkipButton: Bool
    var isFromNavigation: Bool = false  // New parameter to indicate source

    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) private var openURL
    
    @EnvironmentObject var appState: AppState  // Add this line
    
    @State private var readings: [D180mens] = []
    @State private var currentDay: String = ""
    @State private var completedDays: [Int] = []
    @State private var isLoading = true
    @State private var currentWeek: Int = 1
    @State private var refreshTrigger = false
    @State private var shouldNavigateToNext = false
    @State private var nextCurriculumOrder: String = ""
    @State private var originalCurriculumOrder: String = ""
    @State private var isSaving = false
    @State private var isSkipping = false
    
    // User session state
    @State private var currentUserEmail: String = ""
    @State private var currentUserId: String = ""
    @State private var hasUserError = false

    // State variables for "Planning Ahead"
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
    
    private var isExcursus: Bool {
        guard let firstReading = readings.first else { return false }
        return firstReading.day == 0
    }
    
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
        guard let firstReading = readings.first else { return false }
        return firstReading.title.contains("Preview of Next Week")
    }
    
    init(day: String? = nil, useCurrentDay: Bool = false, showSkipButton: Bool = false, isFromNavigation: Bool = false) {
        self.day = day
        self.useCurrentDay = useCurrentDay
        self.showSkipButton = showSkipButton
        self.isFromNavigation = isFromNavigation
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1))
                }
                Spacer()
                if !isLoading && !readings.isEmpty {
                    HStack(spacing: 10) {
                        Image("D180Logo").resizable().aspectRatio(contentMode: .fit).frame(width: 50, height: 50)
                        Text(dayDisplayText).font(.system(size: 15, weight: .bold)).foregroundColor(.primary)
                    }
                }
                Spacer()
                if isFromNavigation {
                    Button(action: navigateToHome) {
                        HStack(spacing: 6) {
                            Text("Home")
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1))
                    }
                } else {
                    // Invisible placeholder to balance the layout when home button is hidden
                    HStack(spacing: 6) {
                        Text("Home")
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.clear)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 8).background(Color(.systemGroupedBackground))
            
            // Content
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                if hasUserError {
                    VStack(spacing: 20) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("Please log in to view your readings")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("You need to be logged in to access your personalized content")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else if isLoading {
                    VStack {
                        ProgressView().scaleEffect(1.5)
                        Text("Loading your reading...").padding(.top, 16).foregroundColor(.secondary)
                    }
                } else if readings.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed").font(.system(size: 60)).foregroundColor(.secondary)
                        Text("No readings available").font(.title2).foregroundColor(.secondary)
                        Text("Check back later for your next reading").font(.subheadline).foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(readings) { reading in
                                    ReadingCard(
                                        reading: reading,
                                        isComplete: Binding(
                                            get: { completedDays.contains(reading.day) },
                                            set: { handleToggleComplete(for: reading.day, isComplete: $0) }
                                        ),
                                        accentColor: accentColor,
                                        openURL: openURL,
                                        isExcursus: isExcursus,
                                        isWeeklyPreview: isWeeklyPreview
                                    )
                                }
                                if isWeeklyPreview {
                                    enhancedPlanningAheadSection
                                }
                            }
                            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, (showSkipButton || isExcursus) ? 80 : 16)
                            .id(refreshTrigger)
                        }
                        if (showSkipButton && isWeeklyPreview) || isExcursus {
                            VStack(spacing: 0) {
                                Divider()
                                HStack(spacing: 12) {
                                    Button(action: { if !isSkipping { skipReading() } }) {
                                        HStack {
                                            if isSkipping { ProgressView().scaleEffect(0.8).foregroundColor(.primary) }
                                            Text(isSkipping ? "Skipping..." : "Skip").font(.system(size: 18)).fontWeight(.bold).foregroundColor(.primary)
                                        }
                                        .frame(maxWidth: .infinity).frame(height: 56).background(Color(.systemGray5)).cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGray3), lineWidth: 1))
                                    }
                                    .disabled(isSkipping)
                                }
                                .padding(.horizontal, 16).padding(.vertical, 12).background(Color(.systemGroupedBackground))
                            }
                        }
                    }
                }
                NavigationLink(destination: DailyReadingView(day: nextCurriculumOrder, useCurrentDay: false), isActive: $shouldNavigateToNext) { EmptyView() }.hidden()
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        .task {
            await loadUserSession()
            if !hasUserError {
                await loadAllData()
            }
        }
        .alert("Success", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) { navigateToHome() }
        } message: { Text("Your planning ahead preferences have been saved.") }
        .onAppear {
            if isWeeklyPreview && !currentUserEmail.isEmpty {
                Task { await loadExistingPlanningData() }
            }
        }
    }

    // MARK: - User Session Functions
    
    private func loadUserSession() async {
        do {
            let (email, userId) = try await UserSessionManager.shared.getCurrentUser()
            await MainActor.run {
                self.currentUserEmail = email
                self.currentUserId = userId
                self.hasUserError = false
            }
        } catch {
            print("❌ Error loading user session: \(error)")
            await MainActor.run {
                self.hasUserError = true
            }
        }
    }

    // MARK: - Data Functions

    private func skipReading() {
        Task { @MainActor in isSkipping = true }
        Task {
            await incrementCurriculumOrderOnly(email: currentUserEmail)
            await MainActor.run {
                isSkipping = false
                navigateToHome()
            }
        }
    }

    private func incrementCurriculumOrderOnly(email: String) async {
        guard !email.isEmpty else { return }
        do {
            let response = try await SupabaseManager.shared.client.from("users").select("curriculum_order").eq("email", value: email).execute()
            if let dataArray = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
               let userData = dataArray.first,
               let currentOrderString = userData["curriculum_order"] as? String,
               let currentOrderInt = Int(currentOrderString) {
                let newOrderString = String(currentOrderInt + 1)
                _ = try await SupabaseManager.shared.client.from("users").update(["curriculum_order": newOrderString]).eq("email", value: email).execute()
                
                // Update appState
                await MainActor.run {
                    appState.curriculumOrder = newOrderString
                }
                
                print("✅ Successfully incremented curriculum_order to \(newOrderString)")
            }
        } catch { print("❌ Error incrementing curriculum_order: \(error)") }
    }
    
    // UPDATED: Saves to 'planning_ahead' table
    private func savePlanningAhead() {
        Task {
            do {
                await MainActor.run { isSaving = true }

                let dateFormatter = ISO8601DateFormatter()
                let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

                let massScheduledDaysNames = massScheduledDays.enumerated().filter { $0.element }.map { dayNames[$0.offset] }
                let confessionScheduledDaysNames = confessionScheduledDays.enumerated().filter { $0.element }.map { dayNames[$0.offset] }

                let massScheduledDaysJSON = try JSONSerialization.data(withJSONObject: massScheduledDaysNames)
                let massScheduledDaysString = String(data: massScheduledDaysJSON, encoding: .utf8) ?? "[]"

                let confessionScheduledDaysJSON = try JSONSerialization.data(withJSONObject: confessionScheduledDaysNames)
                let confessionScheduledDaysString = String(data: confessionScheduledDaysJSON, encoding: .utf8) ?? "[]"

                let weekNumber = extractWeekNumber()
                
                var payload: [String: String] = [
                    "created_at": dateFormatter.string(from: Date()),
                    "user_id": currentUserId,
                    "week_number": String(weekNumber),
                    "mass_scheduled_days": massScheduledDaysString,
                    "confession_scheduled_days": confessionScheduledDaysString,
                    "schedule_notes": scheduleNotes
                ]

                if let value = isSpiritualMercyScheduled { payload["spiritual_mercy_scheduled"] = value ? "true" : "false" }
                if let value = isCorporalMercyScheduled { payload["corporal_mercy_scheduled"] = value ? "true" : "false" }
                if let value = isSpiritualDirectionScheduled { payload["spiritual_direction_scheduled"] = value ? "true" : "false" }
                if let value = isSeminaryVisitScheduled { payload["seminary_visit_scheduled"] = value ? "true" : "false" }
                if let value = isDiscernmentRetreatScheduled { payload["discernment_retreat_scheduled"] = value ? "true" : "false" }

                let response = try await SupabaseManager.shared.client
                    .from("planning_ahead")
                    .select("id")
                    .eq("user_id", value: currentUserId)
                    .eq("week_number", value: String(weekNumber))
                    .execute()

                if let dataArray = try JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
                   let existingId = dataArray.first?["id"] as? Int {
                    print("Updating existing planning_ahead record with ID: \(existingId)")
                    try await SupabaseManager.shared.client.from("planning_ahead").update(payload).eq("id", value: String(existingId)).execute()
                } else {
                    print("Creating new planning_ahead record")
                    try await SupabaseManager.shared.client.from("planning_ahead").insert(payload).execute()
                }

                await incrementCurriculumOrder()

                await MainActor.run {
                    isSaving = false
                    showingSaveConfirmation = true
                }
                print("✅ Successfully saved planning ahead data.")
            } catch {
                print("❌ Error saving planning ahead data: \(error)")
                await MainActor.run { isSaving = false }
            }
        }
    }
    
    // UPDATED: Loads from 'planning_ahead' table
    private func loadExistingPlanningData() async {
        do {
            let weekNumber = extractWeekNumber()
            let response = try await SupabaseManager.shared.client
                .from("planning_ahead")
                .select("mass_scheduled_days, confession_scheduled_days, spiritual_mercy_scheduled, corporal_mercy_scheduled, spiritual_direction_scheduled, seminary_visit_scheduled, discernment_retreat_scheduled, schedule_notes")
                .eq("user_id", value: currentUserId)
                .eq("week_number", value: String(weekNumber))
                .execute()

            if let dataArray = try JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
               let existingData = dataArray.first {
                await MainActor.run { loadPlanningDataIntoState(existingData) }
                print("✅ Loaded existing planning data from planning_ahead for week \(weekNumber)")
            } else {
                print("ℹ️ No existing planning data in planning_ahead for week \(weekNumber)")
            }
        } catch {
            print("❌ Error loading existing planning data: \(error)")
        }
    }
    
    // UPDATED: Parses data from 'planning_ahead' schema
    @MainActor
    private func loadPlanningDataIntoState(_ data: [String: Any]) {
        func parseDaysArray(_ jsonString: String?) -> [Bool] {
            let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            var boolArray = Array(repeating: false, count: 7)
            guard let jsonString = jsonString, let jsonData = jsonString.data(using: .utf8),
                  let dayArray = try? JSONSerialization.jsonObject(with: jsonData) as? [String] else {
                return boolArray
            }
            for (index, dayName) in dayNames.enumerated() {
                if dayArray.contains(dayName) { boolArray[index] = true }
            }
            return boolArray
        }
        
        if let massDays = data["mass_scheduled_days"] as? String { massScheduledDays = parseDaysArray(massDays) }
        if let confDays = data["confession_scheduled_days"] as? String { confessionScheduledDays = parseDaysArray(confDays) }
        if let notes = data["schedule_notes"] as? String { scheduleNotes = notes }

        if let spiritualMercy = data["spiritual_mercy_scheduled"] as? String { isSpiritualMercyScheduled = spiritualMercy.lowercased() == "true" }
        if let corporalMercy = data["corporal_mercy_scheduled"] as? String { isCorporalMercyScheduled = corporalMercy.lowercased() == "true" }
        if let spiritualDir = data["spiritual_direction_scheduled"] as? String { isSpiritualDirectionScheduled = spiritualDir.lowercased() == "true" }
        if let seminaryVisit = data["seminary_visit_scheduled"] as? String { isSeminaryVisitScheduled = seminaryVisit.lowercased() == "true" }
        if let discernment = data["discernment_retreat_scheduled"] as? String { isDiscernmentRetreatScheduled = discernment.lowercased() == "true" }
    }

    // MARK: - Subviews

    private var enhancedPlanningAheadSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Planning Ahead").font(.system(size: 18)).fontWeight(.bold).padding(.leading, 16)
            
            planningDaySelector(title: "What day(s) will I go to Mass this week:", days: $massScheduledDays)
            planningDaySelector(title: "What day(s) will I go to Confession this week:", days: $confessionScheduledDays)
            
            enhancedPlanningQuestions
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Additional scheduling notes:").font(.system(size: 16)).padding(.leading, 16)
                TextEditor(text: $scheduleNotes).font(.system(size: 16)).frame(height: 100).padding(8).background(Color.white.opacity(0.9)).cornerRadius(10).padding(.horizontal, 16)
            }
            
            Button(action: { if !isSaving { savePlanningAhead() } }) {
                HStack {
                    if isSaving { ProgressView().scaleEffect(0.8).foregroundColor(.white) }
                    Text(isSaving ? "Saving..." : "Save Planning Ahead").font(.system(size: 18)).fontWeight(.bold).foregroundColor(.white)
                }
                .frame(maxWidth: .infinity).padding().background(isSaving ? Color.gray : Color.blue).cornerRadius(10)
            }
            .disabled(isSaving).padding(.horizontal, 16).padding(.vertical, 8)
        }
        .padding().background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)).shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2))
    }

    private func planningDaySelector(title: String, days: Binding<[Bool]>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.system(size: 16)).padding(.leading, 16)
            HStack {
                ForEach(0..<7) { index in
                    Button(action: { days.wrappedValue[index].toggle() }) {
                        Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                            .font(.system(size: 16))
                            .foregroundColor(days.wrappedValue[index] ? .white : .black)
                            .padding(.vertical, 5).padding(.horizontal, 10)
                            .background(days.wrappedValue[index] ? Color.blue : Color.white)
                            .cornerRadius(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    }
                }
            }.padding(.leading, 16)
        }
    }
    
    private var enhancedPlanningQuestions: some View {
        VStack(spacing: 15) {
            planningQuestion(text: "Am I scheduled for spiritual works of mercy this week?", binding: $isSpiritualMercyScheduled)
            planningQuestion(text: "Am I scheduled for corporal works of mercy this week?", binding: $isCorporalMercyScheduled)
            planningQuestion(text: "Have I scheduled spiritual direction?", binding: $isSpiritualDirectionScheduled)
            planningQuestion(text: "Have I scheduled a seminary visit?", binding: $isSeminaryVisitScheduled)
            planningQuestion(text: "Have I scheduled my discernment retreat?", binding: $isDiscernmentRetreatScheduled)
        }
    }

    private func planningQuestion(text: String, binding: Binding<Bool?>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(text).font(.system(size: 16)).padding(.leading, 16)
                Spacer()
                HStack {
                    yesNoButton(title: "Yes", value: true, binding: binding)
                    yesNoButton(title: "No", value: false, binding: binding)
                }.padding(.trailing, 16)
            }
        }
    }
    
    private func yesNoButton(title: String, value: Bool, binding: Binding<Bool?>) -> some View {
        Button(action: { binding.wrappedValue = value }) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(binding.wrappedValue == value ? .white : .black)
                .padding(.vertical, 5).padding(.horizontal, 10)
                .background(binding.wrappedValue == value ? Color.blue : Color.white)
                .cornerRadius(8).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
        }
    }
    
    // MARK: - Core Logic & Navigation

    private func incrementCurriculumOrder() async {
        guard !currentUserEmail.isEmpty else { return }
        do {
            let response = try await SupabaseManager.shared.client.from("users").select("curriculum_order").eq("email", value: currentUserEmail).execute()
            if let dataArray = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
               let userData = dataArray.first,
               let currentOrderString = userData["curriculum_order"] as? String,
               let currentOrderInt = Int(currentOrderString) {
                let newOrderString = String(currentOrderInt + 1)
                _ = try await SupabaseManager.shared.client.from("users").update(["curriculum_order": newOrderString]).eq("email", value: currentUserEmail).execute()
                
                // Update appState
                await MainActor.run {
                    appState.curriculumOrder = newOrderString
                }
                
                print("✅ Incremented curriculum_order to \(newOrderString)")
            }
        } catch { print("❌ Error incrementing curriculum_order: \(error)") }
    }

    private func extractWeekNumber() -> Int {
        if let firstReading = readings.first {
            if let weekMatch = firstReading.day_text.range(of: #"Week (\d+)"#, options: .regularExpression) {
                let weekString = String(firstReading.day_text[weekMatch])
                if let number = Int(weekString.replacingOccurrences(of: "Week ", with: "")) { return number }
            }
            return ((firstReading.curriculum_order ?? 0) / 7) + 1
        }
        return 1
    }
    
    private func loadAllData() async {
        isLoading = true
        await fetchData()
        await fetchCompletedDays()
        isLoading = false
    }

    private func handleToggleComplete(for day: Int, isComplete: Bool) {
        if isComplete { if !completedDays.contains(day) { completedDays.append(day) } }
        else { completedDays.removeAll { $0 == day } }
        completedDays.sort()
        refreshTrigger.toggle()
        Task {
            await updateReadingProgress(for: day, isComplete: isComplete)
            if isExcursus && isComplete { await handleExcursusCompletion() }
        }
    }

    private func handleExcursusCompletion() async {
        guard let currentCurriculumOrder = Int(originalCurriculumOrder) else { return }
        let newCurriculumOrderString = String(currentCurriculumOrder + 1)
        do {
            _ = try await SupabaseManager.shared.client.from("users").update(["curriculum_order": newCurriculumOrderString]).eq("email", value: currentUserEmail).execute()
            
            // Update appState
            await MainActor.run {
                appState.curriculumOrder = newCurriculumOrderString
            }
        } catch { print("❌ Error handling excursus completion: \(error)") }
    }

    func fetchCompletedDays() async {
        guard !currentUserEmail.isEmpty else { return }
        do {
            struct Response: Decodable { let completed_days: [Int]? }
            let rawResponse = try await SupabaseManager.shared.client.from("users").select("completed_days").eq("email", value: currentUserEmail).execute()
            let decoded = try JSONDecoder().decode([Response].self, from: rawResponse.data)
            await MainActor.run { self.completedDays = decoded.first?.completed_days ?? [] }
        } catch { print("❌ Error fetching/decoding completed days: \(error)") }
    }

    func fetchData() async {
        guard !currentUserEmail.isEmpty else { 
            print("❌ No current user email, cannot fetch data")
            return 
        }
        
        print("🚀 fetchData called - useCurrentDay: \(useCurrentDay), day: \(day ?? "nil"), isFromNavigation: \(isFromNavigation)")
        
        if useCurrentDay {
            print("📍 Using current day path - fetching curriculum_order from database")
            guard let fetchedOrder = await fetchCurriculumOrder() else { return }
            print("📍 Fetched curriculum_order: \(fetchedOrder)")
            currentDay = fetchedOrder
            originalCurriculumOrder = fetchedOrder
            await fetchReadingsByCurriculumOrder()
        } else if let specifiedDay = day, !specifiedDay.isEmpty {
            if isFromNavigation {
                print("📍 Navigation path: fetching by day number \(specifiedDay)")
                // When coming from NavigationHubView, use the day number to fetch by day
                currentDay = specifiedDay
                if let dayInt = Int(specifiedDay) {
                    await fetchReadingsByDay(dayInt)
                }
            } else {
                print("📍 Home path: fetching by curriculum_order \(specifiedDay)")
                // When coming from HomePageView, use curriculum_order
                currentDay = specifiedDay
                originalCurriculumOrder = specifiedDay
                await fetchReadingsByCurriculumOrder()
            }
        } else {
            print("📍 Fallback: fetching current day")
            guard let fetchedDay = await fetchCurrentDay() else { return }
            currentDay = fetchedDay
            originalCurriculumOrder = fetchedDay
            await fetchReadingsByCurriculumOrder()
        }
    }

    func fetchCurriculumOrder() async -> String? {
        guard !currentUserEmail.isEmpty else { return nil }
        do {
            let response: [[String: String]] = try await SupabaseManager.shared.client.from("users").select("curriculum_order").eq("email", value: currentUserEmail).execute().value
            return response.first?["curriculum_order"]
        } catch { print("Error fetching curriculum_order: \(error)"); return nil }
    }

    func fetchCurrentDay() async -> String? {
        guard !currentUserEmail.isEmpty else { return nil }
        do {
            let progress: [[String: String]] = try await SupabaseManager.shared.client.from("users").select("current_day").eq("email", value: currentUserEmail).execute().value
            return progress.first?["current_day"]
        } catch { print("Error fetching current day: \(error)"); return nil }
    }

    func fetchReadingsByCurriculumOrder() async {
        do {
            let curriculumOrderInt = Int(currentDay) ?? 1
            print("🔍 Fetching readings by curriculum_order: \(curriculumOrderInt)")
            readings = try await SupabaseManager.shared.client.from("d180mens").select("*").eq("curriculum_order", value: curriculumOrderInt).execute().value
            print("📚 Found \(readings.count) readings for curriculum_order \(curriculumOrderInt)")
            
            if let firstReading = readings.first {
                let curriculumOrder = firstReading.curriculum_order ?? 0
                print("✅ First reading: Day \(firstReading.day), Curriculum Order \(curriculumOrder), Title: \(firstReading.title)")
                await MainActor.run {
                    if firstReading.day != 0 { self.currentDay = String(firstReading.day) }
                    if self.originalCurriculumOrder.isEmpty { self.originalCurriculumOrder = self.currentDay }
                }
            } else {
                print("❌ No readings found for curriculum_order \(curriculumOrderInt)")
            }
        } catch { print("❌ Error fetching readings by curriculum_order: \(error)") }
    }
    
    
    private func navigateToHome() {
        // Post notification that NavigationHubView should dismiss
        NotificationCenter.default.post(name: Notification.Name("NavigateToHomeFromDailyReading"), object: nil)
        
        // Dismiss DailyReadingView
        presentationMode.wrappedValue.dismiss()
    }
    
    func fetchReadingsByDay(_ dayNumber: Int) async {
        do {
            print("🔍 Fetching readings for day: \(dayNumber)")
            // Try different approaches to ensure we find the record
            
            // First attempt: Direct query with Int
            readings = try await SupabaseManager.shared.client
                .from("d180mens")
                .select("*")
                .eq("day", value: dayNumber)
                .execute().value
            
            print("📚 Found \(readings.count) readings for day \(dayNumber)")
            
            if readings.isEmpty {
                print("🔄 Trying alternative query methods...")
                
                // Second attempt: Query with String conversion
                readings = try await SupabaseManager.shared.client
                    .from("d180mens")
                    .select("*")
                    .eq("day", value: String(dayNumber))
                    .execute().value
                
                print("📚 String query found \(readings.count) readings")
            }
            
            if readings.isEmpty {
                print("🔄 Trying query all and filter...")
                
                // Third attempt: Get all records and filter manually (for debugging)
                let allReadings: [D180mens] = try await SupabaseManager.shared.client
                    .from("d180mens")
                    .select("*")
                    .execute().value
                
                readings = allReadings.filter { $0.day == dayNumber }
                print("📚 Manual filter found \(readings.count) readings for day \(dayNumber)")
                
                // Debug: Show some examples of what days exist
                let dayNumbers = allReadings.map { $0.day }.sorted()
                print("🔍 Available days around \(dayNumber): \(dayNumbers.filter { abs($0 - dayNumber) <= 3 })")
            }
            
            if let firstReading = readings.first {
                let curriculumOrder = firstReading.curriculum_order ?? 0
                print("✅ First reading: Day \(firstReading.day), Curriculum Order \(curriculumOrder), Title: \(firstReading.title)")
                await MainActor.run {
                    self.currentDay = String(firstReading.day)
                    self.originalCurriculumOrder = String(curriculumOrder)
                }
            } else {
                print("❌ No readings found for day \(dayNumber) after all attempts")
                // Fallback: Try to find the closest available reading
                await findClosestReading(to: dayNumber)
            }
        } catch { 
            print("❌ Error fetching readings by day \(dayNumber): \(error)") 
        }
    }
    
    func findClosestReading(to targetDay: Int) async {
        do {
            print("🔍 Looking for closest reading to day \(targetDay)")
            // Get all readings and find the one with the closest day number <= targetDay
            let allReadings: [D180mens] = try await SupabaseManager.shared.client
                .from("d180mens")
                .select("*")
                .order("day", ascending: true)
                .execute()
                .value
            
            // Find the highest day number that is <= targetDay
            let availableReading = allReadings
                .filter { $0.day > 0 && $0.day <= targetDay }
                .last
            
            if let reading = availableReading {
                let curriculumOrder = reading.curriculum_order ?? 0
                print("✅ Found closest reading: Day \(reading.day), Curriculum Order \(curriculumOrder)")
                await MainActor.run {
                    self.readings = [reading]
                    self.currentDay = String(reading.day)
                    self.originalCurriculumOrder = String(curriculumOrder)
                }
            } else {
                print("❌ No suitable fallback reading found")
            }
        } catch {
            print("❌ Error finding closest reading: \(error)")
        }
    }

    func calculateCurrentWeek(fromDays days: [Int]) -> Int {
        return (days.max() ?? 0) / 7 + 1
    }
    
    func updateReadingProgress(for day: Int, isComplete: Bool) async {
        guard !currentUserEmail.isEmpty else { return }
        do {
            struct Response: Decodable {
                let completed_days: [Int]?
            }
            let rawResponse = try await SupabaseManager.shared.client
                .from("users")
                .select("completed_days")
                .eq("email", value: currentUserEmail)
                .execute()
            
            var daysArray = (try? JSONDecoder().decode([Response].self, from: rawResponse.data))?.first?.completed_days ?? []
            
            // Handle both adding and removing
            if isComplete {
                if !daysArray.contains(day) {
                    daysArray.append(day)
                }
            } else {
                daysArray.removeAll { $0 == day }
            }
            daysArray.sort()
            
            let updatedCurriculumOrder = isComplete ? String((Int(originalCurriculumOrder) ?? 0) + 1) : originalCurriculumOrder
            let newCurrentDay = (day < 0) ? (daysArray.max() ?? 0) : (isComplete ? day + 1 : (daysArray.max() ?? 0) + 1)
            
            struct ReadingProgress: Encodable {
                let current_day: Int, completed_days: [Int], current_week: Int, curriculum_order: String
            }
            let progress = ReadingProgress(
                current_day: newCurrentDay,
                completed_days: daysArray,
                current_week: calculateCurrentWeek(fromDays: daysArray),
                curriculum_order: updatedCurriculumOrder
            )
            
            _ = try await SupabaseManager.shared.client
                .from("users")
                .update(progress)
                .eq("email", value: currentUserEmail)
                .execute()
            
            await MainActor.run {
                self.completedDays = daysArray
                self.currentWeek = calculateCurrentWeek(fromDays: daysArray)
                // Update appState to reflect the new curriculum_order and current day
                appState.curriculumOrder = updatedCurriculumOrder
                appState.currentDayText = String(newCurrentDay)
            }
        } catch {
            print("❌ Error updating reading progress: \(error)")
        }
    }
}

// MARK: - ReadingCard View

struct ReadingCard: View {
    let reading: D180mens
    @Binding var isComplete: Bool
    let accentColor: Color
    var openURL: OpenURLAction
    let isExcursus: Bool
    let isWeeklyPreview: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(reading.title).font(.title3).fontWeight(.bold).fixedSize(horizontal: false, vertical: true)
                if reading.title != "Praying with Sacred Scripture" {
                    Text(reading.subtitle ?? "").font(.subheadline).foregroundColor(.primary.opacity(0.7)).fixedSize(horizontal: false, vertical: true)
                }
            }
            Divider()
            Text(reading.day_text.htmlToAttributedString()).lineSpacing(6).tint(accentColor).environment(\.openURL, openURL)
            
            if !isWeeklyPreview {
                HStack {
                    Text(isExcursus ? "Mark as Read & Continue" : "Mark as Complete").font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Toggle("", isOn: $isComplete).toggleStyle(SwitchToggleStyle(tint: accentColor))
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)).shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2))
        .overlay(isComplete && !isWeeklyPreview ? RoundedRectangle(cornerRadius: 16).stroke(accentColor, lineWidth: 2) : nil)
        .animation(.easeInOut(duration: 0.2), value: isComplete)
    }
}
