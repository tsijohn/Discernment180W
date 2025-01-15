//import SwiftUI
//
//struct MultiQuestionInputView: View {
//    @StateObject private var viewModel = QuestionsViewModel()
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            ForEach($viewModel.questions) { $question in
//                VStack(alignment: .leading) {
//                    Text(question.questionText)
//                        .font(.headline)
//                        .padding(.bottom, 5)
//
//                    HStack {
//                        TextField("Enter minutes", value: $question.answer, formatter: NumberFormatter())
//                            .keyboardType(.numberPad)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .padding()
//
//                        Spacer()
//                    }
//                }
//                .padding(.bottom, 20)
//            }
//
//            Button(action: {
//                viewModel.saveResponses()
//            }) {
//                Text("Submit")
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//            }
//            .padding()
//
//            Spacer()
//        }
//        .padding()
//        .onAppear {
//            viewModel.loadResponses()
//        }
//    }
//}
