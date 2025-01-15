import SwiftUI

struct HomePageView: View {
    @State private var currentDayText: String = "" // Optional day description if needed
    @EnvironmentObject var appState: AppState

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
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()

                VStack(spacing: 0) { // No spacing between HStack and content
                    HStack(alignment: .top) { // Align HStack items to top
                        VStack(alignment: .leading) { // Align greeting and date to left
                            Text(greeting)
                                .font(.custom("Georgia", size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.black)

                            Text(todayDate)
                                .font(.custom("Georgia", size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.leading, 20)
                        .padding(.top, 50)
                        .padding(.bottom, 10) // Add padding to the bottom of the HStack


                        Spacer()

                        NavigationLink(destination: UserProfileView()) {
                            Image(systemName: "person.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.blue)
                                .padding(.trailing, 20)
                                .padding(.top, 50)
                        }
                    }
                    .background(Color.white) // White background for the header

                    ScrollView {
                        VStack(spacing: 10) {
                            // Card for Day 1 with link to DailyReadingView
                            NavigationLink(destination: DailyReadingView()) {
                                ZStack(alignment: .bottom) {
                                    Image("TiepoloOurLady")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity, maxHeight: 322)
                                        .clipped()
                                        .cornerRadius(12)

                                    // Card overlay text with border
                                    HStack {
                                        Text("Current Day: \(appState.currentDayText)")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)


                                        Image(systemName: "eyeglasses")
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(hexString: "#132A47"), lineWidth: 4)
                                            .background(Color.black.opacity(0.6).cornerRadius(12))
                                    )
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 10)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 422)
                                .shadow(radius: 5)
                            }

                            // Week 2 options
                            VStack(alignment: .center, spacing: 15) {
                                Text("Part 1 | Week 2")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 20)

                                // Seminary visit button with countdown
                                Button(action: {}) {
                                    HStack {
                                        Text("Seminary visit")
                                            .font(.system(size: 16, weight: .bold))
                                            .padding()
                                            .foregroundColor(.black)

                                        // Countdown text styled in blue
                                        Text(seminaryVisitCountdown)
                                            .font(.system(size: 14, weight: .regular))
                                            .padding(.leading)
                                            .foregroundColor(.blue)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 100)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                                    .padding(.horizontal, 20)
                                }
                            }

                            // Week 2 buttons with links
                            VStack(alignment: .center, spacing: 15) {
                                ForEach(["Excursus Reading", "Week 1 Review", "Week 2 Preview"], id: \.self) { title in
                                    if title == "Excursus Reading" {
                                        NavigationLink(destination: ExcursusView()) {
                                            buttonContent(title: title)
                                        }
                                    } else if title == "Week 1 Review" {
                                        NavigationLink(destination: WeekReviewView()) {
                                            buttonContent(title: title)
                                        }
                                    } else if title == "Week 2 Preview" {
                                        NavigationLink(destination: WeekPreviewView()) {
                                            buttonContent(title: title)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Spacer()

                    // Bottom navigation buttons
                    HStack(spacing: 0) {
                        Button(action: {}) {
                            Text("Home")
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hexString: "#132A47"))
                                .foregroundColor(.white)
                        }

                        Button(action: {}) {
                            NavigationLink(destination: DailyChecklistView()) {
                                Text("Rule")
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hexString: "#132A47"))
                                    .foregroundColor(.white)
                            }
                        }

                        Button(action: {}) {
                            Text("Fraternity")
                                .font(.system(size: 16, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hexString: "#132A47"))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(height: 50)
                }
            }
            .navigationBarHidden(true)
        }
        .task {
        }
        .onAppear {
            Task {
                await appState.fetchCurrentDay() // Run fetch on app load
            }
            Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                updateCountdown()
                updateSeminaryVisitCountdown()
            }
        }
    }
    
    private func buttonContent(title: String) -> some View {
        HStack {
            Circle()
                .fill(Color.green)
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemName: "hand.thumbsup.fill")
                        .foregroundColor(.white)
                )

            Text(title)
                .font(.system(size: 16, weight: .bold))
                .padding()
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color(hexString: "#132A47"))
        .cornerRadius(8)
        .padding(.horizontal, 20)
    }
}


struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}

extension Color {
    init(hexString: String) {
        let scanner = Scanner(string: hexString)
        scanner.currentIndex = scanner.string.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let red = Double((rgbValue >> 16) & 0xFF) / 255.0
        let green = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }
}
