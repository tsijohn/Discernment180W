import SwiftUI

struct HomePageView: View {
    @State private var currentDayText: String = "" // Optional day description if needed
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authViewModel: AuthViewModel

    // Computed property for greeting
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Good morning"
        case 12..<18: return "Good afternoon"
        default: return "Good evening"
        }
    }

    // Computed property for today's date
    var todayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d yyyy"
        return formatter.string(from: Date())
    }

    // Countdown to Jan 31
    @State private var countdown: String = ""
    private let targetDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 31))!

    // Timer to update countdown every minute
    func updateCountdown() {
        let now = Date()
        let diff = targetDate.timeIntervalSince(now)

        let days = Int(diff) / (3600 * 24)
        let hours = (Int(diff) % (3600 * 24)) / 3600
        let minutes = (Int(diff) % 3600) / 60

        countdown = String(format: "%02d days %02d hours %02d min", days, hours, minutes)
    }

    // Countdown for Seminary Visit button
    @State private var seminaryVisitCountdown: String = ""
    func updateSeminaryVisitCountdown() {
        let now = Date()
        let diff = targetDate.timeIntervalSince(now)

        let days = Int(diff) / (3600 * 24)
        let hours = (Int(diff) % (3600 * 24)) / 3600
        let minutes = (Int(diff) % 3600) / 60

        seminaryVisitCountdown = String(format: "%02d d: %02d h: %02d m", days, hours, minutes)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Blue header section (top half of screen)
                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(greeting)
                                .font(.custom("Georgia", size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(todayDate)
                                .font(.custom("Georgia", size: 14))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.leading, 20)
                        .padding(.top, 70) // Increased from 50 to 70

                        Spacer()

                        NavigationLink(destination: UserProfileView()) {
                            Image(systemName: "person.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding(.trailing, 20)
                                .padding(.top, 70) // Increased from 50 to 70
                        }
                    }
                    
                    Spacer()
                    
                    // Unified rectangular card with logo and day info
                    NavigationLink(destination: DailyReadingView()) {
                        ZStack {
                            // Card background - blue background for white text
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(hexString: "#132A47"))
                                .frame(width: UIScreen.main.bounds.width - 40, height: 160)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            // Content inside the card - all centered
                            VStack(spacing: 16) {
                                // Logo in white - bigger
                                Image("D180Logo")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                                    .scaledToFit()
                                    .frame(height: 80)
                                
                                // Day text with title and arrow
                                VStack(spacing: 8) {
                                    Text("Day \(appState.currentDayText)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("A Devout Life")
                                        .font(.headline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    // Arrow positioned below title - twice as big
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                    }
                    .onAppear {
                        let email = authViewModel.userEmail
                        Task {
                            await appState.fetchCurrentDay(for: email)
                        }
                    }
                    .padding(.bottom, 30)
                }
                .frame(height: UIScreen.main.bounds.height * 0.5) // Half screen height
                .background(Color(hexString: "#132A47")) // Single consistent blue color
                
                // Gray section (bottom half of screen)
                VStack(spacing: 0) {
                    VStack(spacing: 20) {
                        // Enhanced navigation buttons with medium gold borders - now 4 buttons
                        HStack(spacing: 15) {
                            NavigationLink(destination: WeekReviewView(weekNumber: getCurrentWeekNumber(from: appState.currentDayText))) {
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hexString: "#DAA520"), // Medium gold
                                                    Color(hexString: "#CD853F"), // Peru gold
                                                    Color(hexString: "#DAA520")  // Medium gold
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: "list.bullet.clipboard")
                                                .font(.system(size: 24))
                                                .foregroundColor(Color(hexString: "#132A47"))
                                        )
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                                        )
                                    Text("Rule")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(Color(hexString: "#132A47"))
                                }
                            }
                            
                            NavigationLink(destination: PrayersView()) {
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hexString: "#DAA520"), // Medium gold
                                                    Color(hexString: "#CD853F"), // Peru gold
                                                    Color(hexString: "#DAA520")  // Medium gold
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: "hands.sparkles")
                                                .font(.system(size: 24))
                                                .foregroundColor(Color(hexString: "#19223b"))
                                        )
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                                        )
                                    Text("Prayers")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(Color(hexString: "#19223b"))
                                }
                            }
                            
                            NavigationLink(destination: NavigationHubView()) {
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hexString: "#DAA520"), // Medium gold
                                                    Color(hexString: "#CD853F"), // Peru gold
                                                    Color(hexString: "#DAA520")  // Medium gold
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: "map")
                                                .font(.system(size: 24))
                                                .foregroundColor(Color(hexString: "#19223b"))
                                        )
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                                        )
                                    Text("Navigate")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(Color(hexString: "#19223b"))
                                }
                            }
                            
                            NavigationLink(destination: ResourceView()) {
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(hexString: "#DAA520"), // Medium gold
                                                    Color(hexString: "#CD853F"), // Peru gold
                                                    Color(hexString: "#DAA520")  // Medium gold
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Image(systemName: "book.closed")
                                                .font(.system(size: 24))
                                                .foregroundColor(Color(hexString: "#19223b"))
                                        )
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                                        )
                                    Text("Resources")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(Color(hexString: "#19223b"))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 30)
                    }
                    
                    Spacer()
                    
                    // No bottom navigation buttons - removed
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill entire width and height
                .frame(height: UIScreen.main.bounds.height * 0.5) // Half screen height
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
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                updateCountdown()
                updateSeminaryVisitCountdown()
            }
        }
    }
}

func getCurrentWeekNumber(from currentDayText: String) -> Int {
    // Convert currentDayText to integer
    guard let currentDay = Int(currentDayText), currentDay > 0 else {
        return 1 // Default to week 1 if conversion fails
    }
    
    // Calculate week number based on day (assuming 7 days per week)
    // Day 1-7 = Week 1, Day 8-14 = Week 2, etc.
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
