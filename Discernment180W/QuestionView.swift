//import SwiftUI
//
//struct QuestionView: View {
//    let question: Question
//    @Binding var selectedOption: String?
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(question.text)
//                .font(.headline)
//                .padding(.bottom, 5)
//
//            ForEach(question.options, id: \.self) { option in
//                HStack {
//                    Button(action: {
//                        selectedOption = option
//                    }) {
//                        HStack {
//                            Text(option)
//                            Spacer()
//                            if selectedOption == option {
//                                Image(systemName: "checkmark")
//                            }
//                        }
//                        .padding()
//                        .background(selectedOption == option ? Color.blue.opacity(0.2) : Color.clear)
//                        .cornerRadius(8)
//                    }
//                }
//                .padding(.bottom, 2)
//            }
//        }
//        .padding()
//    }
//}
