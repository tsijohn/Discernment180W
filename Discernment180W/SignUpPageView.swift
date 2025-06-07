import SwiftUI

struct SignUpPageView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel  // Inject AuthViewModel

    // State variables for the form fields
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var age: String = ""
    @State private var diocese: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToHome = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background Color
                Color(hex: "#132A47").ignoresSafeArea()

                VStack(spacing: 4) {
                    // Back Button
                    HStack {
                        Button(action: {
                            // Handle back button if needed
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    Spacer()

                    // Sign-Up Form
                    VStack(spacing: 20) {
                        Text("D180")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        VStack(spacing: 15) {
                            CustomTextField(placeholder: "First Name", text: $firstName)
                            CustomTextField(placeholder: "Last Name", text: $lastName)
                            CustomTextField(placeholder: "Email", text: $email)
                            CustomTextField(placeholder: "Age (Optional)", text: $age, keyboardType: .numberPad)
                            CustomTextField(placeholder: "Diocese (Optional)", text: $diocese)
                        }
                    }

                    Spacer()

                    // Sign Up Button
                    Button(action: {
                        handleSignUp()
                    }) {
                        Text("Sign Up")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#d89e63"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.horizontal, 40)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Sign Up"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }

                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(destination: HomePageView(), isActive: $navigateToHome) {
                    EmptyView()
                }
            )
        }
        .navigationBarHidden(true)
        .onAppear {
            navigateToHome = false
        }
    }

    private func handleSignUp() {
        SupabaseManager.shared.signUpUser(
            firstName: firstName,
            lastName: lastName,
            email: email,
            age: age.isEmpty ? nil : age,
            diocese: diocese.isEmpty ? nil : diocese
        ) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    let fullName = "\(firstName) \(lastName)"
                    authViewModel.logIn(name: fullName, email: email, current_day: "0")  // Corrected call
                    navigateToHome = true
                }
            case .failure(let error):
                alertMessage = "Error signing up: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}

// Custom TextField Component
struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        if isSecure {
            SecureField(placeholder, text: $text)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 40)
        } else {
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .padding(.horizontal, 40)
        }
    }
}

// Preview
struct SignUpPageView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPageView().environmentObject(AuthViewModel()) // Ensure environment object is included
    }
}

