import SwiftUI

struct WeekReviewView: View {
    @Environment(\.presentationMode) var presentationMode // For navigating back
    @State private var prayerDays: Int = 1 // State for tracking the selected number of prayer days
    @State private var isMassCommitted: Bool = false // State for tracking the checkbox
    @State private var prayerNotes: String = "" // State for tracking the user's input for prayer/spiritual direction

    var body: some View {
        ZStack {
            Color(.systemGray6) // Light grey background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Spacer()

                    // Header with title
                    Text("Week 1 Review")
                        .font(.custom("Georgia", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 10)

                    Spacer()
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Prayer Section
                        sectionView(title: "Prayer")

                        // Sacraments Section
                        sectionView(title: "Sacraments", isMassSection: true)

                        // Virtue Section
                        sectionView(title: "Virtue", isVirtueSection: true)

                        // Service Section
                        sectionView(title: "Service")

                        // Study Section
                        sectionView(title: "Study")

                        // Planning Ahead Section
                        sectionView(title: "Planning Ahead")
                    }
                    .padding(.bottom, 20)
                }

                Spacer()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Reusable view for each section
    func sectionView(title: String, isMassSection: Bool = false, isVirtueSection: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.custom("Georgia", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.leading, 16) // Left padding for title

            if title == "Prayer" {
                HStack {
                    // Unbolded Daily, Personal Prayer text
                    Text("Daily, Personal Prayer")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)

                    Spacer()

                    // Dropdown to the right with border
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1) // Border
                            .frame(width: 120, height: 40) // Set the size of the dropdown box
                            .padding(.trailing, 16)

                        Picker("Select number of days", selection: $prayerDays) {
                            ForEach(1..<8) { day in
                                Text("\(day) day\(day > 1 ? "s" : "")")
                            }
                        }
                        .pickerStyle(MenuPickerStyle()) // Use a menu style for dropdown
                        .padding(.horizontal, 10) // Padding inside the dropdown box
                    }
                }
            } else if isMassSection {
                // Daily Mass Commitment checkbox
                HStack {
                    Text("Daily Mass Commitment")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)

                    Spacer()

                    // Checkbox
                    Button(action: {
                        isMassCommitted.toggle()
                    }) {
                        Image(systemName: isMassCommitted ? "checkmark.square.fill" : "square")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                    .padding(.trailing, 16)
                }
            } else if isVirtueSection {
                // Text and input box for Virtue section
                VStack(alignment: .leading, spacing: 10) {
                    Text("I need to bring to prayer and/or spiritual direction")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)

                    TextEditor(text: $prayerNotes)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.leading, 16)
                }
            } else {
                Text(loremIpsumText())
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .lineSpacing(5)
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
            }
        }
    }

    // Sample lorem ipsum text
    func loremIpsumText() -> String {
        return """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
        """
    }
}

struct WeekReviewView_Previews: PreviewProvider {
    static var previews: some View {
        WeekReviewView()
    }
}

