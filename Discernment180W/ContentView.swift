import SwiftUI

struct ContentView: View {
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        let currentDate = dateFormatter.string(from: Date())

        return NavigationView {
            ZStack {
                Color.green.frame(height: 20) // Debugging top padding

                // Set a dark grey background color
                
                VStack(spacing: 8) {
                    // Smaller header with "Day 0" and today's date
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Day 0") // Display day number in bold
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(currentDate) // Dynamic date next to "Day 0"
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading) // Reduced minHeight
                    .padding(.leading, 10) // Reduced left padding
                    .padding(.vertical, 0) // Further reduced vertical padding
                    .background(Color(red: 19/255, green: 42/255, blue: 71/255)) // Updated to #132A47
                    Color.green.frame(height: 20) // Debugging top padding

                    // Discernment180 logo and title
                    Text("Discernment 180")
                        .font(.system(size: 28)) // Reduced font size
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 5) // Reduced top padding
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 1) // Reduced shadow intensity
                        .multilineTextAlignment(.center) // Center the logo and title
                    


                    // Daily Checklist Button
                    NavigationLink(destination: DailyChecklistView()) {
                        Text("Daily Review")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 19/255, green: 42/255, blue: 71/255)) // Updated to #132A47
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                    }

                    // Looking Ahead Button
                    NavigationLink(destination: LookingAheadView()) {
                        Text("Looking Ahead")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 19/255, green: 42/255, blue: 71/255)) // Updated to #132A47
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                    }

                    // Fraternity Button
                    NavigationLink(destination: FraternityChatView()) {
                        Text("Fraternity")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 19/255, green: 42/255, blue: 71/255)) // Updated to #132A47
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                    }

                    // Rule of Life Button
                    NavigationLink(destination: RuleOfLifeView()) {
                        Text("Rule of Life")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 19/255, green: 42/255, blue: 71/255)) // Updated to #132A47
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal, 40)
                    }

                    Spacer()
                }
                .padding(.bottom, 20)
            }
            .navigationBarTitle("", displayMode: .inline) // Inline to reduce height
            .onAppear {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.titleTextAttributes = [.font: UIFont(name: "Georgia", size: 18) ?? UIFont.systemFont(ofSize: 18)]
                
                // Change the back button text
                UINavigationBar.appearance().topItem?.backBarButtonItem = UIBarButtonItem(
                    title: "Return", style: .plain, target: nil, action: nil)

                // Apply appearance
                UINavigationBar.appearance().standardAppearance = appearance
                UINavigationBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPod touch (7th generation)")
    }
}

struct RuleOfLifeView: View {
    @State private var prayerMinutes: String = ""
    @State private var prayerStart: Date = Date()
    @State private var prayerEnd: Date = Date()

    var body: some View {
        Form {
            Section(header: Text("Prayer Time")) {
                TextField("How many minutes will I pray a day?", text: $prayerMinutes)
                    .keyboardType(.numberPad) // Numeric keyboard for minutes
                
                DatePicker("Prayer Start Time", selection: $prayerStart, displayedComponents: .hourAndMinute)
                DatePicker("Prayer End Time", selection: $prayerEnd, displayedComponents: .hourAndMinute)
            }

            Section {
                Button(action: {
                    // Handle saving or submitting the prayer times
                    print("Prayer Minutes: \(prayerMinutes), Start: \(prayerStart), End: \(prayerEnd)")
                }) {
                    Text("Submit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .navigationTitle("Rule of Life")
    }
}

struct RuleOfLifeView_Previews: PreviewProvider {
    static var previews: some View {
        RuleOfLifeView()
    }
}

