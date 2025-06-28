import SwiftUI

struct HomePageView: View {
    @State private var currentDayText: String = ""
    @State private var shouldNavigateToWeekReview = false
    @State private var weekNumberForNavigation: Int = 1
    @State private var weeklyReviewTitle: String = "Weekly Review"
    @State private var weeklyReviewDayText: String = "1"
    @State private var dailyReadingTitle: String = "A Devout Life"
    @State private var dailyReadingSubtitle: String = ""
    @State private var isWeeklyReview: Bool = false
    @State private var hasJustUpdatedCurriculum: Bool = false
    @State private var isNavigatingToWeeklyReview: Bool = false // NEW: Flag to prevent onChange during navigation
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authViewModel: AuthViewModel

    // Computed property for greeting


    // Computed property for today's date
    var todayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d yyyy"
        return formatter.string(from: Date())
    }

    // Countdown to Jan 31


    
    // Logo view component
    var logoView: some View {
        Image("D180Logo")
            .resizable()
            .renderingMode(.template)
            .foregroundColor(.white)
            .scaledToFit()
    }
    
    // Gold gradient for buttons
    var goldGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hexString: "#DAA520"),
                Color(hexString: "#CD853F"),
                Color(hexString: "#DAA520")
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Common button style
    func navButtonStyle(icon: String, label: String, iconColor: Color = Color(hexString: "#19223b")) -> some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(goldGradient, lineWidth: 2.5)
            .frame(width: 67.5, height: 67.5)
            .overlay(
                VStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 28.5))
                        .foregroundColor(iconColor)
                    Text(label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(iconColor)
                }
            )
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(hexString: "#E5E5E5"))
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            )
    }
    
    // Navigation buttons
    var ruleButton: some View {
        NavigationLink(destination: WeekReviewView(weekNumber: getCurrentWeekNumber(from: appState.currentDayText))) {
            navButtonStyle(icon: "list.bullet.clipboard", label: "Rule", iconColor: Color(hexString: "#132A47"))
        }
    }
    
    var prayersButton: some View {
        NavigationLink(destination: PrayersView()) {
            navButtonStyle(icon: "hands.sparkles", label: "Prayers")
        }
    }
    
    var navigateButton: some View {
        NavigationLink(destination: NavigationHubView()) {
            navButtonStyle(icon: "map", label: "Navigate")
        }
    }
    
    var resourcesButton: some View {
        NavigationLink(destination: ResourceView()) {
            navButtonStyle(icon: "book.closed", label: "Resources")
        }
    }
    
    // Daily reading title view
    var dailyReadingTitleView: some View {
        VStack(spacing: 12) {
            Text("Day \(appState.currentDayText)")
                .font(.custom("Georgia", size: 32))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(dailyReadingTitle)
                .font(.custom("Georgia", size: 24))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(maxWidth: 280)
                .fixedSize(horizontal: false, vertical: true)
            
            // Subtitle with 20 character limit
            if !dailyReadingSubtitle.isEmpty {
                Text(dailyReadingSubtitle.count > 20 ?
                     String(dailyReadingSubtitle.prefix(20)) + "..." :
                     dailyReadingSubtitle)
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .frame(maxWidth: 280)
            }
            
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 4)
        }
    }
    
    // Simplified weekly review button content
    @ViewBuilder
    var weeklyReviewButtonContent: some View {
        VStack(spacing: 20) {
            logoView
                .frame(height: 100)
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.9))
        }
    }
    
    // Simplified daily reading button content
    @ViewBuilder
    var dailyReadingButtonContent: some View {
        VStack(spacing: 20) {
            logoView
                .frame(height: 100)
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.9))
        }
    }
    
    // Fixed navigation link for weekly review
    @ViewBuilder
    var hiddenWeeklyReviewNavigationLink: some View {
        NavigationLink(
            destination: WeekReviewView(weekNumber: weekNumberForNavigation),
            isActive: $shouldNavigateToWeekReview
        ) {
            EmptyView()
        }
        .hidden()
    }
    
    // Updated content section with fixed navigation
    @ViewBuilder
    var contentSection: some View {
        if appState.curriculumOrder == "-1" {
            // Weekly review for curriculum order -1
            Button(action: handleWeeklyReviewTap) {
                weeklyReviewButtonContent
            }
            .buttonStyle(PlainButtonStyle())
            .background(hiddenWeeklyReviewNavigationLink)
        } else if isWeeklyReview {
            // Weekly review for other cases
            Button(action: handleWeeklyReviewTap) {
                weeklyReviewButtonContent
            }
            .buttonStyle(PlainButtonStyle())
            .background(hiddenWeeklyReviewNavigationLink)
        } else {
            // Daily reading - pass the curriculum_order directly with useCurrentDay flag
            NavigationLink(
                destination: DailyReadingView(day: appState.curriculumOrder, useCurrentDay: true)
            ) {
                dailyReadingButtonContent
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // FIXED: Action handler for weekly review tap
    func handleWeeklyReviewTap() {
        Task {
            // Set navigation flag to prevent onChange from interfering
            await MainActor.run {
                isNavigatingToWeeklyReview = true
            }
            
            // Increment the curriculum order in the database
            await incrementCurriculumOrderInDatabase(email: "Utjohnkkim@gmail.com")
            
            // Navigate to weekly review on the main thread
            await MainActor.run {
                shouldNavigateToWeekReview = true
            }
            
            // Reset the navigation flag after a delay to allow navigation to complete
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            await MainActor.run {
                isNavigatingToWeeklyReview = false
            }
        }
    }
    
    // Function to fetch content based on curriculum_order
    func fetchContentFromCurriculumOrder() async {
        do {
            struct D180MensResponse: Decodable {
                let title: String
                let subtitle: String?
                let day: Int
                let day_text: String
                let curriculum_order: Int
            }
            
            print("Fetching content for curriculum_order: \(appState.curriculumOrder)")
            
            let response = try await SupabaseManager.shared.client
                .from("d180mens")
                .select("title, subtitle, day, day_text, curriculum_order")
                .eq("curriculum_order", value: Int(appState.curriculumOrder) ?? 1)
                .execute()
            
            let decoded = try JSONDecoder().decode([D180MensResponse].self, from: response.data)
            if let firstEntry = decoded.first {
                await MainActor.run {
                    if firstEntry.day == -1 {
                        // This is a weekly review
                        self.isWeeklyReview = true
                        self.weeklyReviewTitle = firstEntry.title
                        self.weeklyReviewDayText = firstEntry.day_text
                        if let weekNum = Int(firstEntry.day_text) {
                            self.weekNumberForNavigation = weekNum
                        }
                        // Clear daily reading fields
                        self.dailyReadingTitle = ""
                        self.dailyReadingSubtitle = ""
                        // For weekly reviews, we might want to keep the previous day number
                    } else {
                        // This is a daily reading - use the day number, not day_text
                        self.isWeeklyReview = false
                        self.dailyReadingTitle = firstEntry.title
                        self.dailyReadingSubtitle = firstEntry.subtitle ?? ""
                        // Update day display with the actual day number
                        self.currentDayText = String(firstEntry.day)
                        appState.currentDayText = String(firstEntry.day)
                        // Clear weekly review fields
                        self.weeklyReviewTitle = ""
                        self.weeklyReviewDayText = ""
                    }
                }
                print("Fetched content - title: \(firstEntry.title), subtitle: \(firstEntry.subtitle ?? ""), day: \(firstEntry.day), day_text: \(firstEntry.day_text)")
            } else {
                print("No content found for curriculum_order: \(appState.curriculumOrder)")
            }
        } catch {
            print("Error fetching content from curriculum_order: \(error)")
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Blue header section
                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text(todayDate)
                                .font(.system(size: 21.16, weight: .bold))  // Increased from 18.4 to 21.16 (15% bigger)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.leading, 20)
                        .padding(.top, 70)

                        Spacer()

                        NavigationLink(destination: UserProfileView()) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .padding(.trailing, 20)
                                .padding(.top, 70)
                        }
                    }
                    
                    Spacer()
                    
                    // Center section with logo and arrow button
                    contentSection
                        .frame(maxHeight: .infinity)
                        .onAppear {
                            let email = authViewModel.userEmail
                            Task {
                                print("HomePageView onAppear - hasJustUpdatedCurriculum: \(hasJustUpdatedCurriculum)")
                                
                                if !hasJustUpdatedCurriculum {
                                    print("Fetching current day from database")
                                    await appState.fetchCurrentDay(for: email)
                                } else {
                                    print("Skipping fetch, using updated curriculum_order: \(appState.curriculumOrder)")
                                    hasJustUpdatedCurriculum = false
                                }
                                
                                print("Current curriculum_order: \(appState.curriculumOrder)")
                                
                                // Use the unified function instead of separate ones
                                await fetchContentFromCurriculumOrder()
                            }
                        }
                        .onChange(of: appState.curriculumOrder) { newValue in
                            // FIXED: Only update content if we're not navigating to weekly review
                            if !isNavigatingToWeeklyReview {
                                Task {
                                    await fetchContentFromCurriculumOrder()
                                }
                            } else {
                                print("Skipping fetchContentFromCurriculumOrder due to navigation in progress")
                            }
                        }
                        .onChange(of: shouldNavigateToWeekReview) { isNavigating in
                            if !isNavigating {
                                // When navigation ends, reset the flag after a small delay
                                Task {
                                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
                                    await MainActor.run {
                                        if !shouldNavigateToWeekReview { // Double check
                                            isNavigatingToWeeklyReview = false
                                        }
                                    }
                                }
                            }
                        }
                    
                    Spacer()
                    
                    // Bottom section with title and subtitle aligned left
                    VStack(alignment: .leading, spacing: 8) {
                        if appState.curriculumOrder == "-1" || isWeeklyReview {
                            Text("WEEK \(weekNumberForNavigation)")
                                .font(.system(size: 15.18, weight: .medium))  // Increased from 13.2 to 15.18 (15% bigger)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white.opacity(0.15))
                                )
                            
                            Text(weeklyReviewTitle)
                                .font(.system(size: 23.1, weight: .bold))  // Increased from 21 to 23.1 (10% bigger)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                                .truncationMode(.tail)
                        } else {
                            // Only show the DAY badge if the day number is positive
                            if let dayNumber = Int(appState.currentDayText), dayNumber > 0 {
                                Text("DAY \(appState.currentDayText)")
                                    .font(.system(size: 15.18, weight: .medium))  // Increased from 13.2 to 15.18 (15% bigger)
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.white.opacity(0.15))
                                    )
                            }
                            
                            Text(dailyReadingTitle)
                                .font(.system(size: 23.1, weight: .bold))  // Increased from 21 to 23.1 (10% bigger)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                                .truncationMode(.tail)
                            
                            if !dailyReadingSubtitle.isEmpty {
                                Text(dailyReadingSubtitle.count > 115 ?
                                     String(dailyReadingSubtitle.prefix(115)) + "..." :
                                     dailyReadingSubtitle)
                                    .font(.system(size: 12, weight: .medium))  // Kept at 12
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
                .frame(height: UIScreen.main.bounds.height * 0.60)
                .background(Color(hexString: "#132A47"))
                
                // Gray section
                ScrollView {
                    VStack(spacing: 0) {
                        VStack(spacing: 20) {
                            HStack(spacing: 20) {
                                ruleButton
                                prayersButton
                                navigateButton
                                resourcesButton
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 30)
                            
                            // Bible quote
                            VStack(spacing: 8) {
                                Text("Romans 12:2")
                                    .font(.custom("Georgia", size: 20.8))  // Increased from 16 to 20.8 (30% bigger)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(hexString: "#132A47"))
                                
                                Text("\"Be transformed by the renewal of your mind, so you may discern what is good, pleasing, and perfect: the will of God.\"")
                                    .font(.custom("Georgia", size: 20.8))  // Increased from 16 to 20.8 (30% bigger)
                                    .fontWeight(.regular)
                                    .foregroundColor(Color(hexString: "#132A47"))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                            }
                            .padding(.bottom, 20)
                        }
                        
                        Spacer(minLength: 20)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.40)
                .background(Color(.systemGray6))
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .ignoresSafeArea()
        }
        .onAppear {
            Task {
                let email = authViewModel.userEmail
                await appState.fetchCurrentDay(for: email)
            }
        }
    }
    
    // Updated increment function that doesn't trigger fetchContentFromCurriculumOrder immediately
    private func incrementCurriculumOrderInDatabase(email: String) async {
        do {
            print("Starting increment for email: \(email)")
            print("Current appState.curriculumOrder before increment: \(appState.curriculumOrder)")
            
            let response = try await SupabaseManager.shared.client
                .from("users")
                .select("curriculum_order")
                .eq("email", value: "Utjohnkkim@gmail.com")
                .execute()
            
            print("Raw response data: \(String(data: response.data, encoding: .utf8) ?? "nil")")
            
            if let dataArray = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
               !dataArray.isEmpty,
               let userData = dataArray.first,
               let currentOrderString = userData["curriculum_order"] as? String,
               let currentOrderInt = Int(currentOrderString) {
                
                print("Current order from DB: \(currentOrderString)")
                
                let newOrder = currentOrderInt + 1
                let newOrderString = String(newOrder)
                
                print("Updating to new order: \(newOrderString)")
                
                let updateResponse = try await SupabaseManager.shared.client
                    .from("users")
                    .update(["curriculum_order": newOrderString])
                    .eq("email", value: "Utjohnkkim@gmail.com")
                    .execute()
                
                print("Update response: \(String(data: updateResponse.data, encoding: .utf8) ?? "nil")")
                
                await MainActor.run {
                    appState.curriculumOrder = newOrderString
                    self.hasJustUpdatedCurriculum = true
                    print("Updated appState.curriculumOrder to: \(appState.curriculumOrder)")
                }
                
                print("✅ Successfully incremented curriculum_order from \(currentOrderString) to \(newOrderString)")
            } else {
                print("❌ Failed to parse user data or curriculum_order")
                print("DataArray: \(String(describing: try? JSONSerialization.jsonObject(with: response.data)))")
            }
        } catch {
            print("❌ Error incrementing curriculum_order: \(error)")
        }
    }
}

func getCurrentWeekNumber(from currentDayText: String) -> Int {
    guard let currentDay = Int(currentDayText), currentDay > 0 else {
        return 1
    }
    
    let weekNumber = ((currentDay - 1) / 7) + 1
    return weekNumber
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
            .environmentObject(AppState())
            .environmentObject(AuthViewModel())
    }
}
