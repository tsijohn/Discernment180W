//import SwiftUI
//import FirebaseAuth

//struct AuthView: View {
//    @EnvironmentObject var authViewModel: AuthViewModel
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var errorMessage: String?
//
//    var body: some View {
//        VStack {
//            TextField("Email", text: $email)
//                .autocapitalization(.none)
//                .keyboardType(.emailAddress)
//                .padding()
//                .background(Color.gray.opacity(0.2))
//                .cornerRadius(5)
//                .padding(.bottom, 20)
//
//            SecureField("Password", text: $password)
//                .padding()
//                .background(Color.gray.opacity(0.2))
//                .cornerRadius(5)
//                .padding(.bottom, 20)
//
//            if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .padding()
//            }
//
//            Button(action: login) {
//                Text("Login")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(5)
//            }
//            .padding(.bottom, 10)
//
//            Button(action: signUp) {
//                Text("Sign Up")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.green)
//                    .foregroundColor(.white)
//                    .cornerRadius(5)
//            }
//        }
//        .padding()
//    }
//
//    func login() {
//        Auth.auth().signIn(withEmail: email, password: password) { result, error in
//            if let error = error {
//                errorMessage = error.localizedDescription
//            } else {
//                authViewModel.isLoggedIn = true
//            }
//        }
//    }
//
//    func signUp() {
//        Auth.auth().createUser(withEmail: email, password: password) { result, error in
//            if let error = error {
//                errorMessage = error.localizedDescription
//            } else {
//                authViewModel.isLoggedIn = true
//            }
//        }
//    }
//}
