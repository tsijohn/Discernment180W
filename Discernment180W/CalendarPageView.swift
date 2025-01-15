import SwiftUI

struct CalendarPageView: View {
    @State private var showBefore180DaysView = false // State to control navigation
    @State private var currentDay = 0 // State to track the current day

    var body: some View {
        ZStack {
            // Blue background
            Color(hex: "#132A47")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 30) {
                    // Progress Bar
                    VStack {
                        Text("Day \(currentDay) of 180")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom, 5)

                        // Progress bar representation
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(height: 20)
                                    .foregroundColor(Color(hex: "#d89e63").opacity(0.3)) // Light yellow background

                                Rectangle()
                                    .frame(width: (geometry.size.width / 180) * CGFloat(currentDay), height: 20)
                                    .foregroundColor(Color(hex: "#d89e63")) // Yellow progress
                            }
                            .cornerRadius(10) // Rounded corners for progress bar
                        }
                        .frame(height: 20) // Fixed height for progress bar
                        .padding(.horizontal, 40)
                    }
                    .padding(.top, 20)

                    // Buttons Row
                    HStack(spacing: 20) {
                        // Disciplines Button
                        Button(action: {
                            print("Disciplines tapped")
                        }) {
                            Text("Disciplines")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 140, height: 140) // Square button
                                .background(Color(hex: "#d89e63")) // Yellow background
                                .cornerRadius(8)
                        }

                        // Fraternity Button
                        Button(action: {
                            print("Fraternity tapped")
                        }) {
                            Text("Fraternity")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 140, height: 140) // Square button
                                .background(Color(hex: "#d89e63")) // Yellow background
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20) // Horizontal padding for the row
                    .padding(.top, 10) // Add spacing from the progress bar

                    Spacer().frame(height: 30) // Extra margin below the buttons

                    // First button: "Before the 180 Days"
                    Button(action: {
                        showBefore180DaysView = true // Navigate to Before180DaysView
                    }) {
                        Text("Before the 180 Days")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(10)
                            .frame(maxWidth: .infinity, minHeight: 35)
                            .background(Color.gray) // Grey button background
                            .foregroundColor(Color(hex: "#132A47")) // Blue text
                            .cornerRadius(8)
                            .padding(.horizontal, 40)
                    }
                    .fullScreenCover(isPresented: $showBefore180DaysView) {
                        Before180DaysView() // Navigate to the Before180DaysView
                    }

                    // Week buttons
                    ForEach(1...26, id: \.self) { week in
                        Button(action: {
                            print("Week \(week) tapped")
                        }) {
                            Text("Week \(week)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(10)
                                .frame(maxWidth: .infinity, minHeight: 35)
                                .background(Color.gray) // Grey button background
                                .foregroundColor(Color(hex: "#132A47")) // Blue text
                                .cornerRadius(8)
                                .padding(.horizontal, 40)
                        }
                    }
                }
                .padding(.vertical, 30)
            }
        }
    }
}

