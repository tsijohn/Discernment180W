import SwiftUI

struct Before180DaysView: View {
    // State to track completion status for each button
    @State private var completedButtons: [Bool] = [false, false, false, false]
    @State private var showSignUpPage = false // State to control navigation to sign-up
    @State private var showDailyReadingPage = false // State to control navigation to Daily Reading
    @Environment(\.presentationMode) var presentationMode // For navigating back to calendar

    // Button Titles (Removed "Before you sign up")
    let buttonTitles = [
        "Will you sign up?",
        "Welcome to Discernment 180!",
        "Day 0: Getting Started with D180",
        "Create a Rule for Life"
    ]

    var body: some View {
        ZStack {
            // Blue background
            Color(hex: "#132A47")
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer().frame(height: 40) // Top margin

                // Buttons with completion indicators
                ForEach(0..<buttonTitles.count, id: \.self) { index in
                    HStack {
                        // Button Label
                        Button(action: {
                            if index == 0 {
                                showSignUpPage = true // Navigate to the sign-up page
                            } else if index == 2 {
                                showDailyReadingPage = true // Navigate to DailyReadingView
                            } else {
                                completedButtons[index].toggle() // Toggle completion status
                            }
                        }) {
                            Text(buttonTitles[index]) // Custom titles for each button
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading) // Align text to the left
                                .background(Color.gray) // Grey button background
                                .foregroundColor(Color(hex: "#132A47")) // Blue text
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 40)

                        // Completion Indicator
                        Circle()
                            .stroke(Color(hex: "#d89e63"), lineWidth: 2) // Yellow outlined circle
                            .frame(width: 24, height: 24) // Size of the circle
                            .overlay(
                                completedButtons[index] ? Circle().fill(Color(hex: "#d89e63")) : nil
                            ) // Filled circle if completed
                            .padding(.trailing, 20) // Extra padding on the right
                    }
                }

                Spacer() // Push buttons to the center

                // Yellow Link to Calendar Page
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Navigate back to calendar
                }) {
                    Text("Back to Calendar")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#d89e63")) // Yellow background
                        .foregroundColor(.white) // White text
                        .cornerRadius(8)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 20) // Spacing from the bottom
            }
        }
        .fullScreenCover(isPresented: $showSignUpPage) {
            SignUpPageView() // Navigate to SignUpPageView
        }
        .fullScreenCover(isPresented: $showDailyReadingPage) {
            DailyReadingView() // Navigate to DailyReadingView
        }
    }
}

struct Before180DaysView_Previews: PreviewProvider {
    static var previews: some View {
        Before180DaysView()
    }
}

