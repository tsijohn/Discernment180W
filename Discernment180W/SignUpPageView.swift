import SwiftUI
import CryptoKit

struct SignUpPageView: View {
    @State private var isActive = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appState: AppState
    
    // State variables for the form fields
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var age: String = ""
    @State private var diocese: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToHome = false
    @State private var isProcessing = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background Colorg
                Color(hex: "#132A47").ignoresSafeArea()

                VStack(spacing: 4) {
                    // Back Button
                    HStack {
                        Button(action: {
                            // Dismiss the view
                            presentationMode.wrappedValue.dismiss()
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
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Create Account")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)

                            VStack(spacing: 15) {
                                CustomTextField(placeholder: "First Name", text: $firstName)
                                CustomTextField(placeholder: "Last Name", text: $lastName)
                                CustomTextField(placeholder: "Email", text: $email, keyboardType: .emailAddress)
                                CustomTextField(placeholder: "Password", text: $password, isSecure: true)
                                CustomTextField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                                CustomTextField(placeholder: "Age (Optional)", text: $age, keyboardType: .numberPad)
                                CustomTextField(placeholder: "Diocese (Optional)", text: $diocese)
                            }
                            
                            // Password requirements text
                            Text("Password must be at least 6 characters")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 40)
                        }
                        .padding(.vertical, 20)
                    }

                    Spacer()

                    // Sign Up Button
                    Button(action: {
                        handleSignUp()
                    }) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Sign Up")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .background(Color(hex: "#d89e63"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 40)
                    .disabled(isProcessing || !isFormValid)
                    .opacity((isProcessing || !isFormValid) ? 0.6 : 1.0)
                    
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Sign Up"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }

                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(destination: HomePageView()
                    .environmentObject(authViewModel)
                    .environmentObject(appState),
                    isActive: $navigateToHome) {
                    EmptyView()
                }
            )
        }
        .navigationBarHidden(true)
        .onAppear {
            navigateToHome = false
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    // Form validation
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        password.count >= 6 &&
        password == confirmPassword
    }

    private func handleSignUp() {
        // Validate form
        guard isFormValid else {
            if password != confirmPassword {
                alertMessage = "Passwords do not match"
            } else if password.count < 6 {
                alertMessage = "Password must be at least 6 characters"
            } else {
                alertMessage = "Please fill in all required fields"
            }
            showAlert = true
            return
        }
        
        isProcessing = true
        
        // Hash the password before sending to database
        let passwordHash = hashPassword(password)
        
        SupabaseManager.shared.signUpUser(
            firstName: firstName,
            lastName: lastName,
            email: email,
            passwordHash: passwordHash,
            age: age.isEmpty ? nil : age,
            diocese: diocese.isEmpty ? nil : diocese
        ) { result in
            switch result {
            case .success:
                // After successful signup, log the user in
                Task {
                    let fullName = "\(firstName) \(lastName)"
                    
                    // Use the actual password for login
                    await authViewModel.login(email: email, password: password)
                    
                    // Update the user's name if login was successful
                    if authViewModel.isAuthenticated {
                        authViewModel.userName = fullName
                        UserDefaults.standard.set(fullName, forKey: "userName")
                    }
                    
                    await MainActor.run {
                        isProcessing = false
                        if authViewModel.isAuthenticated {
                            navigateToHome = true
                        } else {
                            alertMessage = "Account created! Please log in with your credentials."
                            showAlert = true
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    isProcessing = false
                    alertMessage = "Error signing up: \(error.localizedDescription)"
                    showAlert = true
                }
            }
        }
    }
    
    // Simple password hashing function
    private func hashPassword(_ password: String) -> String {
        // In production, use proper bcrypt or similar
        // This is a simple SHA256 hash for demonstration
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
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
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
        }
    }
}

// Preview
struct SignUpPageView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPageView()
            .environmentObject(AuthViewModel())
            .environmentObject(AppState())
    }
}
