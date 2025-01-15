import SwiftUI

struct PostVideoScreen: View {
    @State private var showNextPage = false // Controls navigation to the next screen

    var body: some View {
        ZStack {
            // Dark blue background
            Color(hex: "#132A47")
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer() // Push content down

                VStack(spacing: 10) {
                    Text("180 DAYS")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text("SIX-MONTH DISCERNMENT PLAN")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                }

                // Large block of text
                Text("""
                Ready to get serious about discerning the priesthood? Discernment 180 is a six-month plan to open your heart to God’s call, whatever it may be. It’s available for free via our online platform that sends you a text a day for 180 days, each with short readings and spiritual practices. It’s also available as a book that you can purchase and take with you to the chapel or wherever you pray. The goal is to grow in holiness, prayerfully consider the priesthood, and peacefully accept the life God has prepared for you.
                """)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading) // Align text on the left
                    .lineSpacing(5) // Increase line spacing for readability
                    .padding(.horizontal, 30)
                    .background(Color(hex: "#132A47").opacity(0.9)) // Slightly darker background for rectangle effect
                    .cornerRadius(10) // Rounded corners for rectangle
                    .padding(.top, 10) // Add space between heading and text

                Spacer()

                // Next button
                Button(action: {
                    showNextPage = true
                }) {
                    Text("Start Program")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#d89e63")) // Button with specified color
                        .foregroundColor(.white) // White text
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                }
            }
        }
        .fullScreenCover(isPresented: $showNextPage) {
            CalendarPageView() // Navigate to the Calendar page view
        }
    }
}

