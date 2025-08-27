import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isEditing: Bool = false
    @State private var editedName: String = ""
    @State private var editedEmail: String = ""
    @State private var showingLogoutConfirmation = false
    @State private var isSaving = false

    var body: some View {
        VStack {
            // Profile Image
            Image(systemName: "person.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(Color(hexString: "#132A47"))
                .padding()
                .onTapGesture {
                    print("Change profile picture")
                }
                .accessibilityLabel("Profile Image")

            // User Info
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Name")
                        .font(.custom("Georgia", size: 14))
                        .foregroundColor(.gray)
                    
                    if isEditing {
                        TextField("Name", text: $editedName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.custom("Georgia", size: 16))
                    } else {
                        Text(authViewModel.userName.isEmpty ? "Not set" : authViewModel.userName)
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(.primary)
                    }
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Email")
                        .font(.custom("Georgia", size: 14))
                        .foregroundColor(.gray)
                    
                    if isEditing {
                        TextField("Email", text: $editedEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.custom("Georgia", size: 16))
                            .disabled(true) // Usually don't allow email changes
                            .opacity(0.6)
                    } else {
                        Text(authViewModel.userEmail)
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(.primary)
                    }
                }
                
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .shadow(radius: 2)
            )
            .padding()

            Spacer()

            // Edit/Save Button
            Button(action: {
                if isEditing {
                    saveChanges()
                } else {
                    withAnimation {
                        editedName = authViewModel.userName
                        editedEmail = authViewModel.userEmail
                        isEditing = true
                    }
                }
            }) {
                HStack {
                    if isSaving {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    Text(isEditing ? "Save Changes" : "Edit Profile")
                        .font(.custom("Georgia", size: 16))
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isEditing ? Color.green : Color(hexString: "#132A47"))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isSaving)
            .padding(.horizontal)
            
            // Logout Button
            Button(action: {
                showingLogoutConfirmation = true
            }) {
                Text("Sign Out")
                    .font(.custom("Georgia", size: 16))
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            editedName = authViewModel.userName
            editedEmail = authViewModel.userEmail
        }
        .alert("Sign Out", isPresented: $showingLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authViewModel.logout()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    private func saveChanges() {
        isSaving = true
        
        // Update local state
        authViewModel.userName = editedName
        UserDefaults.standard.set(editedName, forKey: "userName")
        
        // Update in database
        Task {
            await updateUserNameInDatabase()
            
            await MainActor.run {
                withAnimation {
                    isSaving = false
                    isEditing = false
                }
            }
        }
    }
    
    private func updateUserNameInDatabase() async {
        do {
            _ = try await SupabaseManager.shared.client
                .from("users")
                .update(["name": editedName])
                .eq("user_id", value: authViewModel.userId)
                .execute()
            
            print("Successfully updated user name in database")
        } catch {
            print("Error updating user name: \(error)")
            // You might want to show an error alert here
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserProfileView()
                .environmentObject(AuthViewModel())
        }
    }
}
