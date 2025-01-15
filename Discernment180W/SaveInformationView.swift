//import SwiftUI
//
//struct SavedInformationView: View {
//    @ObservedObject var viewModel: ChecklistViewModel
//
//    var body: some View {
//        VStack {
//            Text("Saved Information")
//                .font(.largeTitle)
//                .padding()
//
//            List {
//                ForEach(viewModel.checklist) { item in
//                    HStack {
//                        Text(item.text)
//                        Spacer()
//                        if item.isChecked {
//                            Image(systemName: "checkmark")
//                        }
//                    }
//                }
//            }
//        }
//        .navigationTitle("Saved Checklist")
//        .onAppear {
//            viewModel.loadChecklist() // Load checklist when the view appears
//        }
//    }
//}
