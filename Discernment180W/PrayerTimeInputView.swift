import SwiftUI

struct PrayerTimeInputView: View {
    @State private var prayerMinutes: String = ""
    @AppStorage("prayerMinutes") private var savedPrayerMinutes: Int = 0  // Using @AppStorage for simplicity

    var body: some View {
        VStack(alignment: .leading) {
            Text("I will pray for ___ minutes every day.")
                .font(.headline)
                .padding(.bottom, 10)

            HStack {
                TextField("Enter minutes", text: $prayerMinutes)
                    .keyboardType(.numberPad)  // Ensure the keyboard is numeric
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    savePrayerMinutes()
                }) {
                    Text("Save")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.leading, 10)
            }

            Text("Saved prayer time: \(savedPrayerMinutes) minutes per day")
                .padding(.top, 10)
        }
        .padding()
    }

    private func savePrayerMinutes() {
        if let minutes = Int(prayerMinutes) {
            savedPrayerMinutes = minutes
        }
    }
}
