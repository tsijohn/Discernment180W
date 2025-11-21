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
    @State private var isNavigatingToWeeklyReview: Bool = false
    @State private var completedDays: [Int]? = nil
    @State private var homepageExcerptText: String? = nil // Dynamic excerpt from database
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authViewModel: AuthViewModel

    // Computed property for today's date - SMALLER FONT
    var todayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    // Logo view component with subtle glow effect
    var logoView: some View {
        ZStack {
            // Subtle glow behind logo
            Image("D180Logo")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color(hexString: "#DAA520").opacity(0.3))
                .scaledToFit()
                .blur(radius: 20)
            
            Image("D180Logo")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .scaledToFit()
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
    
    // Enhanced gold gradient
    var goldGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hexString: "#FFD700"),
                Color(hexString: "#DAA520"),
                Color(hexString: "#B8860B")
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Enhanced dark blue gradient
    var darkBlueGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(hexString: "#1A3556"),
                Color(hexString: "#132A47"),
                Color(hexString: "#0F2339")
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // Enhanced button style with better shadows and filled icons
    func navButtonStyle(icon: String, label: String, iconColor: Color = Color(hexString: "#132A47")) -> some View {
        ZStack {
            // White background with better shadow
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .frame(width: 70, height: 70)
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
            
            // Gold border
            RoundedRectangle(cornerRadius: 15)
                .stroke(goldGradient, lineWidth: 2.5)
                .frame(width: 70, height: 70)
            
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(iconColor)
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(iconColor)
            }
        }
    }
    
    // Navigation buttons with filled icons
    var ruleButton: some View {
        NavigationLink(destination: WeekReviewView(weekNumber: getCurrentWeekNumber(from: appState.currentDayText), showSkipButton: false)
            .environmentObject(authViewModel)) {
            navButtonStyle(icon: "list.bullet.clipboard.fill", label: "Rule")
        }
    }
    
    var prayersButton: some View {
        NavigationLink(destination: PrayersView()) {
            navButtonStyle(icon: "hands.sparkles.fill", label: "Prayers")
        }
    }
    
    var navigateButton: some View {
        NavigationLink(destination: NavigationHubView()) {
            navButtonStyle(icon: "map.fill", label: "Navigate")
        }
    }
    
    var resourcesButton: some View {
        NavigationLink(destination: ResourceView()) {
            navButtonStyle(icon: "book.closed.fill", label: "Resources")
        }
    }
    
    // Enhanced play button with gold accent
    var playButton: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 70, height: 70)
                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            Circle()
                .stroke(goldGradient, lineWidth: 2)
                .frame(width: 70, height: 70)
            
            Image(systemName: "play.fill")
                .font(.system(size: 28))
                .foregroundColor(Color(hexString: "#132A47"))
                .offset(x: 2)
        }
    }
    
    // Weekly review button content with play button
    @ViewBuilder
    var weeklyReviewButtonContent: some View {
        VStack(spacing: 20) {
            logoView
                .frame(height: 100)
            playButton
        }
    }
    
    // Daily reading button content with play button
    @ViewBuilder
    var dailyReadingButtonContent: some View {
        VStack(spacing: 20) {
            logoView
                .frame(height: 100)
            playButton
        }
    }
    
    // Hidden navigation link for weekly review
    @ViewBuilder
    var hiddenWeeklyReviewNavigationLink: some View {
        NavigationLink(
            destination: WeekReviewView(weekNumber: weekNumberForNavigation, showSkipButton: true)
                .environmentObject(authViewModel),
            isActive: $shouldNavigateToWeekReview
        ) {
            EmptyView()
        }
        .hidden()
    }
    
    // Helper function to check if Day 0 should be shown
    private func shouldShowDay0() -> Bool {
        return appState.curriculumOrder == "0"
    }
    
    // Content section with navigation
    @ViewBuilder
    var contentSection: some View {
        // Check for Day 0 conditions (curriculum_order == "0")
        if shouldShowDay0() {
            NavigationLink(
                destination: Day0View()
                    .environmentObject(authViewModel)
                    .environmentObject(appState)
            ) {
                dailyReadingButtonContent
            }
            .buttonStyle(PlainButtonStyle())
        } else if appState.curriculumOrder == "-1" {
            Button(action: handleWeeklyReviewTap) {
                weeklyReviewButtonContent
            }
            .buttonStyle(PlainButtonStyle())
            .background(hiddenWeeklyReviewNavigationLink)
        } else if isWeeklyReview {
            Button(action: handleWeeklyReviewTap) {
                weeklyReviewButtonContent
            }
            .buttonStyle(PlainButtonStyle())
            .background(hiddenWeeklyReviewNavigationLink)
        } else {
            NavigationLink(
                destination: DailyReadingView(day: appState.curriculumOrder, useCurrentDay: false, showSkipButton: true)
                    .environmentObject(authViewModel)
                    .environmentObject(appState)  // Pass appState to DailyReadingView
            ) {
                dailyReadingButtonContent
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    // Action handler for weekly review tap
    func handleWeeklyReviewTap() {
        Task {
            await MainActor.run {
                isNavigatingToWeeklyReview = true
            }
            
            await incrementCurriculumOrderInDatabase(email: authViewModel.userEmail)
            
            await MainActor.run {
                shouldNavigateToWeekReview = true
            }
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                isNavigatingToWeeklyReview = false
            }
        }
    }
    
    // Function to fetch completed days
    private func fetchCompletedDays() async {
        do {
            let response = try await SupabaseManager.shared.client
                .from("users")
                .select("completed_days")
                .eq("email", value: authViewModel.userEmail)
                .execute()

            if let dataArray = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
               let userData = dataArray.first {
                await MainActor.run {
                    self.completedDays = userData["completed_days"] as? [Int]
                }
            }
        } catch {
            print("Error fetching completed days: \(error)")
        }
    }

    // Function to fetch homepage excerpt from database
    private func fetchHomepageExcerpt() async {
        // Get the current day as an integer
        let currentDay = Int(appState.currentDayText) ?? 1

        // Try to fetch excerpt from database
        if let excerptText = try? await SupabaseManager.shared.fetchHomepageExcerpt(forDay: currentDay) {
            await MainActor.run {
                self.homepageExcerptText = excerptText
            }
            print("✅ Fetched homepage excerpt for day \(currentDay)")
        } else {
            print("📖 No excerpt found for day \(currentDay), using default Romans 12:2")
            // homepageExcerptText remains nil, so the default Romans 12:2 will be shown
        }
    }

    // Function to fetch content based on curriculum_order
    func fetchContentFromCurriculumOrder() async {
        // Check if we should show Day 0 first
        if shouldShowDay0() {
            // Don't fetch or set any titles for Day 0
            return
        }
        
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
                        self.isWeeklyReview = true
                        self.weeklyReviewTitle = firstEntry.title
                        self.weeklyReviewDayText = firstEntry.day_text
                        if let weekNum = Int(firstEntry.day_text) {
                            self.weekNumberForNavigation = weekNum
                        }
                        self.dailyReadingTitle = ""
                        self.dailyReadingSubtitle = ""
                    } else {
                        self.isWeeklyReview = false
                        self.dailyReadingTitle = firstEntry.title
                        self.dailyReadingSubtitle = firstEntry.subtitle ?? ""
                        self.currentDayText = String(firstEntry.day)
                        appState.currentDayText = String(firstEntry.day)
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
            if !authViewModel.isAuthenticated {
                LoginView()
                    .environmentObject(authViewModel)
                    .environmentObject(appState)
            } else {
                VStack(spacing: 0) {
                    // Enhanced Blue header section with gradient
                    ZStack {
                        // Gradient background
                        darkBlueGradient
                        
                        // Subtle texture overlay
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.clear,
                                Color.black.opacity(0.1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        
                        VStack(spacing: 0) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 2) {
                                    // Smaller date font
                                    Text(todayDate)
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.white.opacity(0.9))

                                }
                                .padding(.leading, 20)
                                .padding(.top, 70)

                                Spacer()

                                NavigationLink(destination: UserProfileView()
                                    .environmentObject(authViewModel)) {
                                    ZStack {
                                        Circle()
                                            .stroke(goldGradient.opacity(0.6), lineWidth: 2)
                                            .frame(width: 42, height: 42)
                                        
                                        Image(systemName: "line.horizontal.3")
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.trailing, 20)
                                    .padding(.top, 70)
                                }
                            }
                            
                            Spacer()
                            
                            // Center section with logo and play button
                            contentSection
                                .frame(maxHeight: .infinity)
                                .onAppear {
                                    let email = authViewModel.userEmail
                                    Task {
                                        print("📱 HomePageView contentSection onAppear")
                                        print("   - email: \(email)")
                                        print("   - curriculumOrder: '\(appState.curriculumOrder)'")
                                        print("   - hasJustUpdatedCurriculum: \(hasJustUpdatedCurriculum)")
                                        
                                        // Only fetch from database if curriculumOrder is empty or if we need to reset from weekly review
                                        if appState.curriculumOrder.isEmpty {
                                            print("   📊 curriculumOrder is empty, fetching from database...")
                                            await appState.fetchCurrentDay(for: email)
                                            await fetchCompletedDays()
                                            await fetchContentFromCurriculumOrder()
                                        } else if hasJustUpdatedCurriculum {
                                            print("   ✅ Just updated curriculum, using local state")
                                            hasJustUpdatedCurriculum = false
                                            await fetchContentFromCurriculumOrder()
                                        } else {
                                            print("   ✅ Using existing curriculumOrder: \(appState.curriculumOrder)")
                                            await fetchContentFromCurriculumOrder()
                                            await fetchCompletedDays()
                                        }
                                        
                                        print("   Final curriculum_order: \(appState.curriculumOrder)")
                                    }
                                }
                                .onChange(of: appState.curriculumOrder) { newValue in
                                    print("📱 curriculumOrder changed to: \(newValue)")
                                    if !isNavigatingToWeeklyReview {
                                        Task {
                                            await fetchContentFromCurriculumOrder()
                                            await fetchCompletedDays()
                                        }
                                    } else {
                                        print("   Skipping fetch due to navigation in progress")
                                    }
                                }
                                .onChange(of: shouldNavigateToWeekReview) { isNavigating in
                                    if !isNavigating {
                                        Task {
                                            try? await Task.sleep(nanoseconds: 500_000_000)
                                            await MainActor.run {
                                                if !shouldNavigateToWeekReview {
                                                    isNavigatingToWeeklyReview = false
                                                }
                                            }
                                        }
                                    }
                                }
                            
                            Spacer()
                            
                            // Enhanced bottom section with gold accents
                            VStack(alignment: .leading, spacing: 8) {
                                if shouldShowDay0() {
                                    Text("DAY 0")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color(hexString: "#DAA520"))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            Capsule()
                                                .fill(Color.white.opacity(0.15))
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color(hexString: "#DAA520").opacity(0.5), lineWidth: 1)
                                                )
                                        )
                                    
                                    Text("Welcome to Discernment 180")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                        .truncationMode(.tail)
                                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                    
                                    Text("Begin your journey of discernment")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.85))
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                } else if appState.curriculumOrder == "-1" || isWeeklyReview {
                                    Text("WEEK \(weekNumberForNavigation)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(Color(hexString: "#DAA520"))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            Capsule()
                                                .fill(Color.white.opacity(0.15))
                                                .overlay(
                                                    Capsule()
                                                        .stroke(Color(hexString: "#DAA520").opacity(0.5), lineWidth: 1)
                                                )
                                        )
                                    
                                    Text(weeklyReviewTitle)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                        .truncationMode(.tail)
                                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                } else {
                                    if let dayNumber = Int(appState.currentDayText), dayNumber > 0 {
                                        Text("DAY \(appState.currentDayText)")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(Color(hexString: "#DAA520"))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(
                                                Capsule()
                                                    .fill(Color.white.opacity(0.15))
                                                    .overlay(
                                                        Capsule()
                                                            .stroke(Color(hexString: "#DAA520").opacity(0.5), lineWidth: 1)
                                                    )
                                            )
                                    }
                                    
                                    Text(dailyReadingTitle)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                        .truncationMode(.tail)
                                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                                    
                                    if !dailyReadingSubtitle.isEmpty {
                                        Text(dailyReadingSubtitle.count > 115 ?
                                             String(dailyReadingSubtitle.prefix(115)) + "..." :
                                             dailyReadingSubtitle)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.white.opacity(0.85))
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.60)
                    
                    // Enhanced gray section with better background
                    ScrollView {
                        VStack(spacing: 0) {
                            VStack(spacing: 20) {
                                // Four navigation buttons in a row
                                HStack(spacing: 18) {
                                    ruleButton
                                    prayersButton
                                    navigateButton
                                    resourcesButton
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 30)
                                
                                // Enhanced Bible quote card - now with dynamic content
                                if let excerptText = homepageExcerptText {
                                    // Show dynamic content from database
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)

                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(goldGradient.opacity(0.3), lineWidth: 1)

                                        VStack(spacing: 10) {
                                            Image(systemName: "book.fill")
                                                .font(.system(size: 30))
                                                .foregroundColor(Color(hexString: "#DAA520"))
                                                .padding(.bottom, 5)

                                            // Display HTML content as attributed string
                                            HTMLFormattedText(excerptText)
                                                .font(.system(size: 18))
                                                .foregroundColor(Color(hexString: "#132A47").opacity(0.9))
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 20)
                                        }
                                        .padding(.vertical, 20)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 20)
                                } else {
                                    // Show default Romans 12:2 verse as fallback
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 3)

                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(goldGradient.opacity(0.3), lineWidth: 1)

                                        VStack(spacing: 10) {
                                            Image(systemName: "book.fill")
                                                .font(.system(size: 30))
                                                .foregroundColor(Color(hexString: "#DAA520"))
                                                .padding(.bottom, 5)

                                            Text("Romans 12:2")
                                                .font(.system(size: 20))
                                                .fontWeight(.bold)
                                                .foregroundColor(Color(hexString: "#132A47"))

                                            Text("\"Be transformed by the renewal of your mind, so you may discern what is good, pleasing, and perfect: the will of God.\"")
                                                .font(.system(size: 18))
                                                .fontWeight(.regular)
                                                .foregroundColor(Color(hexString: "#132A47").opacity(0.9))
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal, 20)
                                        }
                                        .padding(.vertical, 20)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 20)
                                }
                            }
                            
                            Spacer(minLength: 20)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(height: UIScreen.main.bounds.height * 0.40)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(.systemGray6),
                                Color(.systemGray5).opacity(0.5)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .ignoresSafeArea()
                .onAppear {
                    Task {
                        let email = authViewModel.userEmail
                        print("🏠 HomePageView main onAppear")
                        print("   - curriculumOrder: '\(appState.curriculumOrder)'")

                        // Only fetch from database if curriculumOrder is completely empty (first load)
                        if appState.curriculumOrder.isEmpty {
                            print("   📊 Initial load - fetching from database")
                            await appState.fetchCurrentDay(for: email)
                            await fetchCompletedDays()
                        } else {
                            print("   ✅ Already have curriculumOrder: \(appState.curriculumOrder)")
                        }

                        // Fetch homepage excerpt based on current day
                        await fetchHomepageExcerpt()
                    }
                }
            }
        }
    }
    
    // Updated increment function to use authenticated user's email
    private func incrementCurriculumOrderInDatabase(email: String) async {
        do {
            print("Starting increment for email: \(email)")
            print("Current appState.curriculumOrder before increment: \(appState.curriculumOrder)")
            
            let response = try await SupabaseManager.shared.client
                .from("users")
                .select("curriculum_order")
                .eq("email", value: email)
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
                
                _ = try await SupabaseManager.shared.client
                    .from("users")
                    .update(["curriculum_order": newOrderString])
                    .eq("email", value: email)
                    .execute()
                
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

// Helper function remains the same
func getCurrentWeekNumber(from currentDayText: String) -> Int {
    guard let currentDay = Int(currentDayText), currentDay > 0 else {
        return 1
    }
    
    let weekNumber = ((currentDay - 1) / 7) + 1
    return weekNumber
}

// Helper view to display HTML formatted text
struct HTMLFormattedText: View {
    let htmlString: String
    @State private var attributedString = AttributedString()

    init(_ htmlString: String) {
        self.htmlString = htmlString
    }

    var body: some View {
        Text(attributedString)
            .onAppear {
                loadHTML()
            }
            .onChange(of: htmlString) { _ in
                loadHTML()
            }
    }

    private func loadHTML() {
        // First try to parse as HTML
        if let data = htmlString.data(using: .utf8) {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]

            do {
                let nsAttributedString = try NSAttributedString(
                    data: data,
                    options: options,
                    documentAttributes: nil
                )

                // Convert to SwiftUI AttributedString
                if let converted = try? AttributedString(nsAttributedString) {
                    self.attributedString = converted
                } else {
                    // Fallback to plain text
                    self.attributedString = AttributedString(htmlString)
                }
            } catch {
                // If HTML parsing fails, strip HTML tags and display as plain text
                let plainText = htmlString.stripHTMLTags()
                self.attributedString = AttributedString(plainText)
            }
        } else {
            // Fallback to plain text
            self.attributedString = AttributedString(htmlString)
        }
    }
}

// Extension to strip HTML tags
extension String {
    func stripHTMLTags() -> String {
        // Simple regex to remove HTML tags
        let pattern = "<[^>]+>"
        let stripped = self.replacingOccurrences(of: pattern, with: "", options: .regularExpression, range: nil)
        // Replace common HTML entities
        return stripped
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&rsquo;", with: "'")
            .replacingOccurrences(of: "&lsquo;", with: "'")
            .replacingOccurrences(of: "&rdquo;", with: "\u{201D}")
            .replacingOccurrences(of: "&ldquo;", with: "\u{201C}")
            .replacingOccurrences(of: "&mdash;", with: "\u{2014}")
            .replacingOccurrences(of: "&ndash;", with: "\u{2013}")
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
            .environmentObject(AppState())
            .environmentObject(AuthViewModel())
    }
}
