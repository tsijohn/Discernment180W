import SwiftUI
import Supabase

struct NavigationHubView: View {
    // Group days into weeks for organization
    let weeks = Array(stride(from: 1, to: 181, by: 7)).map { weekStart in
        Array(weekStart...(min(weekStart + 6, 180)))
    }
    
    @State private var expandedWeek: Int? = nil
    @State private var currentDay: Int = 1
    @State private var isLoading: Bool = true
    @State private var completedDays: [Int] = []
    
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
                .frame(width: 60, height: 60)
                .overlay(
                    Text("W\(week)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )
            Text("Week \(week)")
                .font(.caption)
                .foregroundColor(Color(hexString: "#19223b"))
        }
    }
    
    var body: some View {
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
                .padding(.top, 100)
            } else {
                VStack(alignment: .leading, spacing: 20) {
                    // Enhanced Current Day Indicator with Progress Bar
                    VStack(spacing: 16) {
                        // Current Day Header
                        HStack {
                            Text("Currently on: ")
                                .font(.headline)
                            Text("Day \(currentDay)")
                                .font(.headline)
                                .foregroundColor(Color(hexString: "#19223b"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(hexString: "#19223b").opacity(0.2))
                                )
                            
                            Spacer()
                            
                            NavigationLink(destination: DailyReadingView(day: String(currentDay))) {
                                Text("Continue")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(hexString: "#19223b"))
                                    )
                            }
                        }
                        
                        // Progress Bar Section
                        NavigationProgressIndicator(currentDay: currentDay, currentWeek: currentWeek)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(hexString: "#19223b").opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Quick jump section
                    VStack(alignment: .leading) {
                        Text("Weekly Reviews")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(1..<26) { week in
                                    let destination = WeekReviewView(weekNumber: week)
                                    NavigationLink(destination: destination) {
                                        weekCircleButton(for: week)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    
                    Divider()
                    
                    // Excursus section
                    VStack(alignment: .leading) {
                        Text("Excursus Readings")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: ExcursusView()) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
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
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hexString: "#19223b"))
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hexString: "#19223b").opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hexString: "#19223b").opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    
                    Divider()
                    
                    // Days section
                    Text("Daily Readings")
                        .font(.headline)
                        .padding(.horizontal)
                    
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
                .padding(.vertical)
            }
        }
        .navigationTitle("Navigate")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await fetchCurrentDay()
                isLoading = false
            }
        }
    }
    
    // Helper function to create week sections
    private func weekSection(weekIndex: Int, isCurrentWeek: Bool) -> some View {
        let weekNumber = weekIndex + 1
        let weekDays = weeks[weekIndex]
        
        return VStack(alignment: .leading) {
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
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(hexString: "#19223b"))
                            )
                    }
                    
                    Spacer()
                    
                    Image(systemName: expandedWeek == weekNumber ? "chevron.up" : "chevron.down")
                        .foregroundColor(Color(hexString: "#19223b"))
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isCurrentWeek ? Color(hexString: "#19223b").opacity(0.15) : Color.gray.opacity(0.1))
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
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(weekDays, id: \.self) { day in
                        NavigationLink(destination: DailyReadingView(day: String(day))) {
                            dayButton(day: day)
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
        .padding(.horizontal)
    }
    
    // Helper function to create consistent day buttons
    func dayButton(day: Int) -> some View {
        let isCurrentDay = day == currentDay
        let isDayCompleted = completedDays.contains(day)
        
        return VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isCurrentDay
                          ? Color(hexString: "#19223b")
                          : Color(hexString: "#19223b").opacity(0.1))
                    .frame(height: 50)
                
                HStack {
                    if isDayCompleted {
                        // Show checkmark for completed days
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(isCurrentDay ? .white : Color.green)
                            .font(.system(size: 14))
                    }
                    
                    Text("Day \(day)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isCurrentDay ? .white : Color(hexString: "#19223b"))
                }
            }
        }
    }
    
    // Fetch the current day and completed days from Supabase
    func fetchCurrentDay() async {
        do {
            // Fetch current day
            let result: [[String: String]] = try await SupabaseManager.shared.client
                .from("users")
                .select("current_day")
                .eq("email", value: "Utjohnkkim@gmail.com")
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
                .eq("email", value: "Utjohnkkim@gmail.com")
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
    
    private var progressPercentage: Double {
        return min(Double(currentDay) / 180.0, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Progress stats
            HStack {
                Text("Week \(currentWeek) of 26")
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
            VStack(alignment: .leading, spacing: 6) {
                ProgressView(value: progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hexString: "#19223b")))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
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
        }
    }
}
