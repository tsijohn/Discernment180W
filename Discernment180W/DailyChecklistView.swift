import SwiftUI

struct DailyChecklistView: View {
    @StateObject private var viewModel = DailyChecklistViewModel() // Reference ViewModel
    @State private var markAllCompleted: Bool = false // State for toggle

    let checklistLabels = [
        "30 min prayer",
        "20 min spiritual reading",
        "Attended Mass",
        "Night prayer"
    ] // Text labels for each button

    var body: some View {
        VStack(spacing: 0) { // Reduce vertical spacing further
            // Row for "Mark all as completed" toggle
            HStack {
                Text("Mark all as completed")
                    .font(.footnote)
                    .foregroundColor(.gray)

                Spacer()

                Toggle("", isOn: $markAllCompleted)
                    .labelsHidden()
                    .onChange(of: markAllCompleted) { newValue in
                        // Update all checklist items based on toggle
                        viewModel.checklistItems.indices.forEach { index in
                            viewModel.checklistItems[index].isCompleted = newValue
                        }
                    }
            }
            .padding() // Add padding for better alignment

            // Checklist buttons with labels
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) { // Two columns with spacing
                ForEach(viewModel.checklistItems.indices, id: \.self) { index in
                    VStack {
                        Button(action: {
                            viewModel.toggleCompletion(for: index)
                        }) {
                            Image(systemName: viewModel.checklistItems[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.largeTitle)
                                .foregroundColor(viewModel.checklistItems[index].isCompleted ? .green : .gray)
                        }
                        Text(checklistLabels[index]) // Add label below button
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 5) // Add spacing between button and label
                    }
                }
            }
            .padding(.horizontal, 20) // Add horizontal padding for the grid

            Spacer() // Pushes the content to the top
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Align VStack content to top
    }
}

struct DailyChecklistView_Previews: PreviewProvider {
    static var previews: some View {
        DailyChecklistView()
    }
}

