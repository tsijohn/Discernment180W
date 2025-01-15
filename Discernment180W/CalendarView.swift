import SwiftUI

struct CalendarView: View {
    @State private var selectedDate: Date = Date()

    var body: some View {
        VStack {
            Text("Select a Date")
                .font(.largeTitle)
                .padding()

            // Calendar-style date picker
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding()

            Spacer()
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
    }
}
