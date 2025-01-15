import SwiftUI

struct LetterView: View {
    // State to control navigation to DailyReadingView
    @State private var navigateToDailyReading = false
    
    var body: some View {
        NavigationView {
            VStack {
                // The content of the letter from Bishop Vazquez
                ScrollView {
                    Text("""
                    Dear Beloved in Christ,

                    [Insert your letter content here.]

                    Sincerely,
                    Bishop Vazquez
                    """)
                    .padding() // Add padding for better appearance
                    .multilineTextAlignment(.leading) // Align text to the leading edge
                }
                
                // Navigation Button
                NavigationLink(destination: DailyReadingView(), isActive: $navigateToDailyReading) {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.top, 0) // Add some space above the button
            }
            .navigationTitle("Letter from Bishop Vazquez") // Title for the letter page
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Use Stack style for better compatibility
    }
}

struct LetterView_Previews: PreviewProvider {
    static var previews: some View {
        LetterView()
    }
}
