import SwiftUI
import Supabase

struct Day0View: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) private var openURL
    
    @State private var dayZeroReading: D180mens?
    @State private var isLoading = true
    @State private var showMyRuleSheet = false
    @State private var hasRuleOfLife = false
    @State private var isAuthorsNoteExpanded = false // State for dropdown
    @State private var showSignUpPage = false
    
    // User session state
    @State private var currentUserEmail: String = ""
    @State private var currentUserId: String = ""
    @State private var hasUserError = false
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appState: AppState
    
    // Color constants
    private let accentColor = Color.blue
    private let backgroundColor: Color = Color(.systemBackground)
    private let cardColor: Color = Color(.secondarySystemBackground)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                // Center content
                HStack(spacing: 10) {
                    Image("D180Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                    Text("Day 0")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                // Back button aligned to leading edge
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
                        )
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGroupedBackground))
            
            // Content
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                if !authViewModel.isAuthenticated {
                    // Preview mode for unauthenticated users
                    ScrollView {
                        VStack(spacing: 16) {
                            // Author's Note Dropdown (always show this)
                            AuthorsNoteDropdown(
                                isExpanded: $isAuthorsNoteExpanded,
                                accentColor: accentColor,
                                openURL: openURL
                            )
                            .padding(.horizontal, 16)
                            
                            // Show Day 0 content if available, otherwise show preview text
                            if let reading = dayZeroReading {
                                Day0Content(
                                    reading: reading,
                                    accentColor: accentColor,
                                    openURL: openURL
                                )
                                .padding(.horizontal, 16)
                            } else {
                                // Preview content when reading is not available
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Day 0 Preview")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text("Welcome to Discernment 180! This is a 6-month guided discernment program to help you discern whether God is calling you to the priesthood.")
                                        .font(.body)
                                        .lineSpacing(6)
                                    
                                    Text("To access the full Day 0 content and begin your discernment journey, please sign up for an account.")
                                        .font(.body)
                                        .lineSpacing(6)
                                        .foregroundColor(.secondary)
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.secondarySystemBackground))
                                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                                )
                                .padding(.horizontal, 16)
                            }
                            
                            // Start Program button for unauthenticated users
                            Button(action: {
                                showSignUpPage = true
                            }) {
                                HStack {
                                    Text("Start Program")
                                        .font(.system(size: 18))
                                        .fontWeight(.bold)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 216 / 255, green: 158 / 255, blue: 99 / 255))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 16)
                    }
                } else if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading Day 0...")
                            .padding(.top, 16)
                            .foregroundColor(.secondary)
                    }
                } else if let reading = dayZeroReading {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Author's Note Dropdown
                            AuthorsNoteDropdown(
                                isExpanded: $isAuthorsNoteExpanded,
                                accentColor: accentColor,
                                openURL: openURL
                            )
                            .padding(.horizontal, 16)
                            
                            // Display the cleaned content directly without card wrapper
                            Day0Content(
                                reading: reading,
                                accentColor: accentColor,
                                openURL: openURL
                            )
                            .padding(.horizontal, 16)
                            
                            // Day 0 buttons
                            VStack(spacing: 12) {
                                if hasRuleOfLife {
                                    // Edit Rule of Life Button
                                    Button(action: { showMyRuleSheet = true }) {
                                        HStack {
                                            Image(systemName: "doc.text.fill")
                                            Text("Edit My Rule of Life")
                                                .font(.system(size: 18))
                                                .fontWeight(.bold)
                                        }
                                        .foregroundColor(.blue)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.blue, lineWidth: 2)
                                        )
                                    }
                                    
                                    // Begin Button
                                    Button(action: handleBegin) {
                                        HStack {
                                            Text("Begin")
                                                .font(.system(size: 18))
                                                .fontWeight(.bold)
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 16, weight: .bold))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                    }
                                } else {
                                    // Complete Rule of Life Button
                                    Button(action: { showMyRuleSheet = true }) {
                                        HStack {
                                            Image(systemName: "doc.text.fill")
                                            Text("Complete Rule of Life")
                                                .font(.system(size: 18))
                                                .fontWeight(.bold)
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 16)
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No content available")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Day 0 content is not available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarHidden(true)
        .task {
            if authViewModel.isAuthenticated {
                await loadUserSession()
                if !hasUserError {
                    await loadDay0Content()
                    await checkRuleOfLife()
                }
            } else {
                // For unauthenticated users, just load the Day 0 content for preview
                await loadDay0Content()
            }
        }
        .sheet(isPresented: $showMyRuleSheet) {
            NavigationView {
                RuleOfLifeFormView()
                    .environmentObject(authViewModel)
            }
            .onDisappear {
                Task {
                    await checkRuleOfLife()
                }
            }
        }
        .fullScreenCover(isPresented: $showSignUpPage) {
            SignUpPageView()
                .environmentObject(authViewModel)
                .environmentObject(appState)
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadUserSession() async {
        do {
            let (email, userId) = try await UserSessionManager.shared.getCurrentUser()
            await MainActor.run {
                self.currentUserEmail = email
                self.currentUserId = userId
                self.hasUserError = false
            }
        } catch {
            print("Error loading user session: \(error)")
            await MainActor.run {
                self.hasUserError = true
            }
        }
    }
    
    private func loadDay0Content() async {
        do {
            // Day 0 is now curriculum_order 0
            let curriculumOrder = 0
            
            let readings: [D180mens] = try await SupabaseManager.shared.client
                .from("d180mens")
                .select("*")
                .eq("curriculum_order", value: curriculumOrder)
                .execute()
                .value
            
            if let reading = readings.first {
                await MainActor.run {
                    self.dayZeroReading = reading
                    self.isLoading = false
                }
            } else {
                print("No record found for curriculum_order \(curriculumOrder)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        } catch {
            print("Error loading content: \(error)")
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    private func checkRuleOfLife() async {
        guard !currentUserId.isEmpty else { return }
        
        do {
            let response = try await SupabaseManager.shared.client
                .from("rule_of_life")
                .select("id")
                .eq("user_id", value: currentUserId)
                .execute()
            
            if let dataArray = try JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
               !dataArray.isEmpty {
                await MainActor.run {
                    self.hasRuleOfLife = true
                }
                print("User has Rule of Life")
            } else {
                await MainActor.run {
                    self.hasRuleOfLife = false
                }
                print("User has not completed Rule of Life")
            }
        } catch {
            print("Error checking Rule of Life: \(error)")
            await MainActor.run {
                self.hasRuleOfLife = false
            }
        }
    }
    
    private func handleBegin() {
        Task {
            // Reset the user progress and wait for it to complete
            await resetUserProgress()
            
            // Add a delay to ensure DB write completes and to prevent HomePageView from fetching old data
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // Navigate home
            await MainActor.run {
                navigateToHome()
            }
        }
    }
    
    private func resetUserProgress() async {
        // Use the email from authViewModel
        let email = authViewModel.userEmail
        print("🔍 resetUserProgress called with email: '\(email)'")
        
        guard !email.isEmpty else {
            print("❌ No email available for resetUserProgress")
            return
        }
        
        do {
            // First, check current values
            let checkResponse = try await SupabaseManager.shared.client
                .from("users")
                .select("curriculum_order, current_day, email")
                .eq("email", value: email)
                .execute()
            
            print("📊 Current user data BEFORE update: \(String(data: checkResponse.data, encoding: .utf8) ?? "nil")")
            
            // Perform the update - removing completed_days from update to simplify
            let response = try await SupabaseManager.shared.client
                .from("users")
                .update([
                    "curriculum_order": "1",
                    "current_day": "1"
                ])
                .eq("email", value: email)
                .execute()
            
            print("✅ Update response: \(String(data: response.data, encoding: .utf8) ?? "nil")")
            
            // Verify the update worked
            let verifyResponse = try await SupabaseManager.shared.client
                .from("users")
                .select("curriculum_order, current_day")
                .eq("email", value: email)
                .execute()
            
            print("📊 User data AFTER update: \(String(data: verifyResponse.data, encoding: .utf8) ?? "nil")")
            
            // Update the appState BEFORE navigating back
            await MainActor.run {
                appState.curriculumOrder = "1"
                appState.currentDayText = "1"
                print("📱 Updated appState - curriculumOrder: \(appState.curriculumOrder), currentDayText: \(appState.currentDayText)")
            }
            
        } catch {
            print("❌ Error in resetUserProgress: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
        }
    }
    
    private func navigateToHome() {
        NotificationCenter.default.post(name: Notification.Name("NavigateToHomeFromDay0"), object: nil)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Author's Note Dropdown View
struct AuthorsNoteDropdown: View {
    @Binding var isExpanded: Bool
    let accentColor: Color
    var openURL: OpenURLAction
    
    // The full preface text from Fr. Greg Gerhart
    private let prefaceText = """
    "Thy kingdom come; thy will be done" - Matthew 6:10

    Every time we recite the Lord's prayer, we ask that the Father's will be done. Imagine the amount of times you have prayed for that intention! Keep that in mind as you read these words of our Lord:

    "Ask and it will be given to you; seek and you will find; knock and the door will be opened to you. For everyone who asks, receives; and the one who seeks, finds; and to the one who knocks, the door will be opened. Which one of you would hand his son a stone when he asks for a loaf of bread, or a snake when he asks for a fish? If you then, who are wicked, know how to give good gifts to your children, how much more will your heavenly Father give good things to those who ask him."
    Matthew 7:7-11

    You have asked that the Lord's will be done; you are seeking to know your vocation, and with this book, you are knocking. God is prepared to open a door for you, and this book will help you to know if it is the door leading to the priesthood.

    In my roles as the associate pastor of a university parish and the vocation director of a diocese, I have been grateful to recommend the many excellent discernment materials that are already available to men discerning the priesthood. With this book, I will not offer any new principles or information missing from such guides as To Save a Thousand Souls by Fr. Brett Brannen or Discernment Do's and Don'ts by Fr. George Elliott. What I am offering is a way to implement the tried and true principles of discernment described in those books and a framework to let the information they provide become actual seeds that take root in your heart and bear fruit in your life.

    One of the recommendations that I have read in a popular discernment resource is to dedicate a six-month period of time to discerning your vocation. That recommendation is the inspiration for this book. Discernment 180 is a step-by-step guide to consecrating six months of your life to discerning whether God is calling you to the priesthood. On each of the 180 days you will have a short reflection to bring to prayer. At various points in the six months, you will take specific actions, including going on a retreat and visiting a seminary. All throughout this time you will follow a rule of life that will help you to hear God's voice and follow where He leads.

    Of course, we cannot "force" God to act on our timeline or to answer our prayers in the way we expect - nor would it be good to do so. He is our providential Father who is laboring to love us, who wants our holiness even more than we do. He knows the time and place to give us each grace necessary to draw us more deeply in communion with Him, and He will wait accordingly. It was in the "fullness of time" that Jesus took flesh in the womb of the Virgin - not a moment before or after (Galatians 4:4). The Lord also has a "fullness of time" for each grace He will give us, including the grace of knowing our vocation, and discernment means waiting accordingly.

    But even in the waiting, God is at work. He is not content to merely inform you; He wants to transform you. It would be easy for God to send you a text message, but that would not lead to holiness. The time of waiting serves to stretch your heart so that when the hour comes to inform you, there will be so much more of you to inform. By waiting and longing, God purifies and strengthens you. He knows what He is about. He does not waste any time.

    These 180 days are not a means to strong-arm God to fulfill our will; they are a means to dispose our hearts to receive His. Should the "fullness of time" for you to receive the grace of knowing your vocation be now, this book will help you to receive it. The prayer, pursuit of virtue, and rule of life that you will take up will help to remove the noise that often prevents us from hearing God's voice. Hearing God's voice through the guided reflections and deliberate actions that you will take will help you to listen specifically for whether His voice is leading you to the priesthood. Prayer and action - the tried and true principles of discernment - are as simple as that.

    Thus, the principles of discernment are simple; however, the choice to discern is serious. It is not a small thing to consecrate six months of your life to God in this way. I know firsthand the risk and, at times, the agony of discerning a priestly vocation. As a fellow brother in Christ and on behalf of the Church, then, please receive my sincere thanks. Thank you for your faith and courage to give God this time. I am grateful for your willingness to follow where Christ leads you.

    In addition to my gratitude, let me also share a bit of excitement and a personal encouragement from an older brother who has been where you are, preparing to take this step. The agony and risk were real, but the thrill of holiness has been more than worth it. I have found Jesus' words to be completely trustworthy: "I have told you this so that my joy might be in you and your joy might be complete" (John 15:11). I can't imagine settling for anything less.

    Take heart, my brother. No matter what your vocation is, God has planned from all eternity to give you some grace, to bless you in some way during these days. The adventure of receiving that grace and blessing awaits you, and my prayers accompany you. May St. Joseph protect you, may our Blessed Mother intercede for you, and may God bless and reward you.

    Peace in Christ,

    Fr. Greg Gerhart
    """
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "note.text")
                        .font(.system(size: 16))
                        .foregroundColor(accentColor)
                    
                    Text("Author's Note")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(accentColor)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: isExpanded ? 16 : 16, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expandable Content
            if isExpanded {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(prefaceText)
                            .font(.system(size: 15))
                            .lineSpacing(6)
                            .foregroundColor(.primary.opacity(0.9))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                    }
                }
                .frame(maxHeight: 400)
                .background(Color(.secondarySystemBackground))
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .move(edge: .top))
                ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Day 0 Content View
struct Day0Content: View {
    let reading: D180mens
    let accentColor: Color
    var openURL: OpenURLAction
    
    private func aggressivelyCleanHTML(_ html: String) -> String {
        var cleaned = html
        
        // First, find where real content starts by looking for substantial text
        if let match = cleaned.range(of: #"[A-Za-z]{20,}"#, options: .regularExpression) {
            let startIndex = cleaned.distance(from: cleaned.startIndex, to: match.lowerBound)
            
            // If there's a lot of junk before real content, skip it
            if startIndex > 50 {
                // Try to preserve any opening tags right before the content
                let searchStart = max(0, startIndex - 20)
                let searchRange = cleaned.index(cleaned.startIndex, offsetBy: searchStart)..<match.lowerBound
                
                if let tagStart = cleaned.range(of: "<p", options: .backwards, range: searchRange) {
                    cleaned = String(cleaned[tagStart.lowerBound...])
                } else {
                    cleaned = String(cleaned[match.lowerBound...])
                }
            }
        }
        
        // Clean up empty tags and excessive whitespace
        let cleanupPatterns = [
            (#"<p>\s*(&nbsp;|\s)*\s*</p>"#, ""),
            (#"<br\s*/?>\s*<br\s*/?>\s*<br\s*/?>"#, "<br>"),
            (#"(&nbsp;){3,}"#, " "),
            (#"^\s*<br\s*/?>\s*"#, ""),
            (#"<div>\s*</div>"#, "")
        ]
        
        for (pattern, replacement) in cleanupPatterns {
            cleaned = cleaned.replacingOccurrences(
                of: pattern,
                with: replacement,
                options: .regularExpression
            )
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        let cleanedHTML = aggressivelyCleanHTML(reading.day_text)
        
        VStack(alignment: .leading, spacing: 16) {
            // Title and subtitle if meaningful
            if !reading.title.isEmpty &&
               !reading.title.lowercased().contains("day 0") &&
               !reading.title.lowercased().contains("d180") {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reading.title)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    if let subtitle = reading.subtitle,
                       !subtitle.isEmpty,
                       subtitle != reading.title {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.primary.opacity(0.7))
                    }
                }
                Divider()
            }
            
            // Display the aggressively cleaned content
            Text(cleanedHTML.htmlToAttributedString())
                .lineSpacing(6)
                .tint(accentColor)
                .environment(\.openURL, openURL)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}
