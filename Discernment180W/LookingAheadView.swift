import SwiftUI

struct LookingAheadView: View {
    // Use UserDefaults keys to store selections
    private let massDaysKey = "massSelectedDays"
    private let confessionDaysKey = "confessionSelectedDays"
    
    @State private var massSelectedDays: [Bool] = Array(repeating: false, count: 7)
    @State private var confessionSelectedDays: [Bool] = Array(repeating: false, count: 7)
    
    // Days of the week
    private let days = ["S", "M", "T", "W", "Th", "F", "S"]
    
    init() {
        loadSelectedDays()
        // Set navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 19/255, green: 42/255, blue: 71/255, alpha: 1.0) // Updated to blue color
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // Set title color to white
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack {
            // Set a dark grey background color
            Color(.darkGray)
                .ignoresSafeArea() // Extend color to the safe area edges
            
            VStack(alignment: .center, spacing: 20) { // Adjusted spacing
                // Header with blue background below the status bar
                VStack {
                    Text("Looking Ahead")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 10) // Reduced top and bottom padding
                        .frame(maxWidth: .infinity, minHeight: 50, alignment: .center) // Reduced minHeight
                        .background(Color(red: 19/255, green: 42/255, blue: 71/255)) // Updated to blue
                }

                // Mass Days Question
                VStack {
                    Text("What day(s) will I go to Mass this week?")
                        .font(.system(size: 18, weight: .semibold)) // Increased font size
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center) // Center the text
                        .padding(.horizontal)

                    // Display days as buttons
                    HStack(spacing: 8) {
                        ForEach(0..<days.count, id: \.self) { index in
                            Button(action: {
                                massSelectedDays[index].toggle()
                                saveSelectedDays() // Save selections when toggled
                            }) {
                                Text(days[index])
                                    .font(.system(size: 14))
                                    .frame(width: 30, height: 30)
                                    .background(massSelectedDays[index] ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                            }
                        }
                    }
                }
                
                // Confession Days Question
                VStack {
                    Text("What day will I go to Confession this week?")
                        .font(.system(size: 18, weight: .semibold)) // Increased font size
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center) // Center the text
                        .padding(.horizontal)

                    // Display days as buttons
                    HStack(spacing: 8) {
                        ForEach(0..<days.count, id: \.self) { index in
                            Button(action: {
                                confessionSelectedDays[index].toggle()
                                saveSelectedDays() // Save selections when toggled
                            }) {
                                Text(days[index])
                                    .font(.system(size: 14))
                                    .frame(width: 30, height: 30)
                                    .background(confessionSelectedDays[index] ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(.top, 10) // Slight padding for alignment
        }
        .navigationBarTitle("", displayMode: .inline) // Set navigation title to be empty
        .onAppear {
            loadSelectedDays() // Refresh the state on view appearance
        }
    }

    // Function to save selected days to UserDefaults
    private func saveSelectedDays() {
        UserDefaults.standard.set(massSelectedDays, forKey: massDaysKey)
        UserDefaults.standard.set(confessionSelectedDays, forKey: confessionDaysKey)
        print("Saved selections: Mass - \(massSelectedDays), Confession - \(confessionSelectedDays)") // Debug print to verify saving
    }

    // Function to load selected days from UserDefaults
    private func loadSelectedDays() {
        if let savedMassSelections = UserDefaults.standard.array(forKey: massDaysKey) as? [Bool] {
            massSelectedDays = savedMassSelections
        }
        if let savedConfessionSelections = UserDefaults.standard.array(forKey: confessionDaysKey) as? [Bool] {
            confessionSelectedDays = savedConfessionSelections
        }
    }
}

struct LookingAheadView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LookingAheadView()
                .previewDevice("iPod touch (7th generation)")
        }
    }
}

