import SwiftUI
import Supabase

struct NavigationHubView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel  // Add this to access logged-in user
    
    // Group days into weeks for organization
    let weeks = Array(stride(from: 1, to: 181, by: 7)).map { weekStart in
        Array(weekStart...(min(weekStart + 6, 180)))
    }
    
    @State private var expandedWeek: Int? = nil
    @State private var currentDay: Int = 1
    @State private var isLoading: Bool = true
    @State private var completedDays: [Int] = []
    @State private var dayToCurriculumOrder: [Int: Int] = [:] // NEW: Map day to curriculum_order
    
    // Calculate current week from current day
    private var currentWeek: Int {
        return ((currentDay - 1) / 7) + 1
    }
    
    // Find which week contains the current day
    private func weekForDay(_ day: Int) -> Int? {
        for (index, weekDays) in weeks.enumerated() {
            if weekDays.contains(day) {
                return index + 1
            }
        }
        return nil
    }
    
    private func weekCircleButton(for week: Int) -> some View {
        VStack {
            Circle()
                .fill(Color(hexString: "#19223b"))
                .frame(width: 56, height: 56)
                .overlay(
                    Text("W\(week)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                )
            Text("Week \(week)")
                .font(.caption2)
                .foregroundColor(Color(hexString: "#19223b"))
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed header with back button only
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                        Text("Home")
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
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGroupedBackground))
            
            // Scrollable content
            ScrollView {
                if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading your progress...")
                            .padding(.top, 16)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 60)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        // Enhanced Current Day Indicator with Progress Bar
                        VStack(spacing: 12) {
                            // Current Day Header
                            HStack {
                                Text("Currently on: ")
                                    .font(.headline)
                                Text("Day \(max(1, currentDay))")
                                    .font(.headline)
                                    .foregroundColor(Color(hexString: "#19223b"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(hexString: "#19223b").opacity(0.2))
                                    )
                                
                                Spacer()
                                
                                // Use day number for navigation from NavigationHubView
                                NavigationLink(destination: DailyReadingView(day: String(currentDay), isFromNavigation: true)) {
                                    Text("Continue")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 7)
                                        .background(
                                            RoundedRectangle(cornerRadius: 7)
                                                .fill(Color(hexString: "#19223b"))
                                        )
                                }
                            }
                            
                            // Progress Bar Section
                            NavigationProgressIndicator(currentDay: currentDay, currentWeek: currentWeek)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.secondarySystemBackground))
                                .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(hexString: "#19223b").opacity(0.25), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                        
                        // Quick jump section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weekly Reviews")
                                .font(.headline)
                                .padding(.horizontal, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(1..<26) { week in
                                        let destination = WeekReviewView(weekNumber: week)
                                        NavigationLink(destination: destination) {
                                            weekCircleButton(for: week)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        // Excursus section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Excursus Readings")
                                .font(.headline)
                                .padding(.horizontal, 16)
                            
                            NavigationLink(destination: ExcursusView()) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Additional Spiritual Readings")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(hexString: "#19223b"))
                                        
                                        Text("Explore supplementary materials and deeper spiritual insights")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "book.closed")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(hexString: "#19223b"))
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hexString: "#19223b").opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color(hexString: "#19223b").opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        // Day 0 Button
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Introduction")
                                .font(.headline)
                                .padding(.horizontal, 16)
                            
                            NavigationLink(destination: Day0View()
                                .environmentObject(authViewModel)
                                .environmentObject(AppState())) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Day 0: Welcome to Discernment 180")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(hexString: "#19223b"))
                                        
                                        Text("Begin your journey with an introduction to the program")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(hexString: "#DAA520"))
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hexString: "#DAA520").opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color(hexString: "#DAA520").opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                            .padding(.horizontal, 16)
                        
                        // Days section
                        Text("Daily Readings")
                            .font(.headline)
                            .padding(.horizontal, 16)
                        
                        // Week for current day should be first
                        if let currentWeek = weekForDay(currentDay) {
                            weekSection(weekIndex: currentWeek - 1, isCurrentWeek: true)
                        }
                        
                        // Other weeks
                        ForEach(weeks.indices, id: \.self) { index in
                            let weekNumber = index + 1
                            // Skip the current week as it's already shown
                            if weekNumber != weekForDay(currentDay) {
                                weekSection(weekIndex: index, isCurrentWeek: false)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.top, 8)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NavigateToHomeFromDailyReading"))) { _ in
            // When notification is received, dismiss NavigationHubView after a small delay
            // to ensure DailyReadingView has dismissed first
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await fetchDayToCurriculumMapping()
                await fetchCurrentDay()
                isLoading = false
            }
        }
    }
    
    // Helper function to create week sections
    private func weekSection(weekIndex: Int, isCurrentWeek: Bool) -> some View {
        let weekNumber = weekIndex + 1
        let weekDays = weeks[weekIndex]
        
        return VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation {
                    if expandedWeek == weekNumber {
                        expandedWeek = nil
                    } else {
                        expandedWeek = weekNumber
                    }
                }
            }) {
                HStack {
                    Text("Week \(weekNumber): Days \(weekDays.first ?? 0)-\(weekDays.last ?? 0)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hexString: "#19223b"))
                    
                    if isCurrentWeek {
                        Text("Current")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(hexString: "#19223b"))
                            )
                    }
                    
                    Spacer()
                    
                    Image(systemName: expandedWeek == weekNumber ? "chevron.up" : "chevron.down")
                        .foregroundColor(Color(hexString: "#19223b"))
                        .font(.system(size: 12))
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(isCurrentWeek ? Color(hexString: "#19223b").opacity(0.15) : Color.gray.opacity(0.08))
                )
            }
            .onAppear {
                // Auto-expand the current week when view appears
                if isCurrentWeek {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            expandedWeek = weekNumber
                        }
                    }
                }
            }
            
            if expandedWeek == weekNumber {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(weekDays, id: \.self) { day in
                        // Use day number for navigation from NavigationHubView
                        NavigationLink(destination: DailyReadingView(day: String(day), isFromNavigation: true)) {
                            dayButton(day: day)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // Helper function to create consistent day buttons
    func dayButton(day: Int) -> some View {
        let isCurrentDay = day == currentDay
        let isDayCompleted = completedDays.contains(day)
        
        return VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(isCurrentDay
                          ? Color(hexString: "#19223b")
                          : Color(hexString: "#19223b").opacity(0.1))
                    .frame(height: 44)
                
                HStack {
                    if isDayCompleted {
                        // Show checkmark for completed days
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(isCurrentDay ? .white : Color.green)
                            .font(.system(size: 12))
                    }
                    
                    Text("Day \(day)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(isCurrentDay ? .white : Color(hexString: "#19223b"))
                }
            }
        }
    }
    
    // NEW: Fetch mapping between day and curriculum_order
    func fetchDayToCurriculumMapping() async {
        do {
            struct DayMapping: Decodable {
                let day: Int
                let curriculum_order: Int?  // Make this optional to handle null values
            }
            
            let mappings: [DayMapping] = try await SupabaseManager.shared.client
                .from("d180mens")
                .select("day, curriculum_order")
                .gte("day", value: 1) // Only get regular days (not weekly reviews or excursus)
                .lte("day", value: 180)
                .execute()
                .value
            
            DispatchQueue.main.async {
                // Create the mapping dictionary
                for mapping in mappings {
                    if let curriculumOrder = mapping.curriculum_order {
                        self.dayToCurriculumOrder[mapping.day] = curriculumOrder
                    }
                }
                print("Day to curriculum_order mapping loaded: \(self.dayToCurriculumOrder.count) entries")
            }
        } catch {
            print("Error fetching day to curriculum_order mapping: \(error)")
        }
    }
    
    // Fetch the current day and completed days from Supabase
    func fetchCurrentDay() async {
        guard !authViewModel.userEmail.isEmpty else {
            print("❌ No user email available")
            return
        }
        
        do {
            // Fetch current day
            let result: [[String: String]] = try await SupabaseManager.shared.client
                .from("users")
                .select("current_day")
                .eq("email", value: authViewModel.userEmail)  // Changed from hardcoded email
                .execute()
                .value
            
            if let firstResult = result.first,
               let currentDayString = firstResult["current_day"],
               let day = Int(currentDayString) {
                DispatchQueue.main.async {
                    self.currentDay = day
                    print("Current day set to: \(day)")
                }
            }
            
            // Fetch completed days
            struct Response: Decodable {
                let completed_days: [Int]?
            }
            
            let completedResponse = try await SupabaseManager.shared.client
                .from("users")
                .select("completed_days")
                .eq("email", value: authViewModel.userEmail)  // Changed from hardcoded email
                .execute()
            
            let data = completedResponse.data
            do {
                let decoded = try JSONDecoder().decode([Response].self, from: data)
                if let firstUser = decoded.first, let completed = firstUser.completed_days {
                    DispatchQueue.main.async {
                        self.completedDays = completed
                        print("Completed days: \(completed)")
                    }
                }
            } catch {
                print("Error decoding completed days: \(error)")
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }
}

// MARK: - Navigation Progress Indicator Component
struct NavigationProgressIndicator: View {
    let currentDay: Int
    let currentWeek: Int
    
    private var safeCurrentDay: Int {
        return max(1, currentDay)
    }
    
    private var safeCurrentWeek: Int {
        return max(1, currentWeek)
    }
    
    private var progressPercentage: Double {
        return min(max(Double(safeCurrentDay) / 180.0, 0.0), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Progress stats
            HStack {
                Text("Week \(safeCurrentWeek) of 26")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(Int(progressPercentage * 100))% Complete")
                    .font(.subheadline)
                    .foregroundColor(Color(hexString: "#19223b"))
                    .fontWeight(.bold)
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 5) {
                ProgressView(value: progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hexString: "#19223b")))
                    .scaleEffect(x: 1, y: 1.8, anchor: .center)
                
                // Milestone markers (optional)
                HStack {
                    Text("Start")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if progressPercentage >= 0.5 {
                        Text("Halfway!")
                            .font(.caption2)
                            .foregroundColor(Color(hexString: "#19223b"))
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    Text("180 Days")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct NavigationHubView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NavigationHubView()
                .environmentObject(AuthViewModel())
        }
    }
}
