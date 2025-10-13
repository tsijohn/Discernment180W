import SwiftUI

// MARK: - Feedback Model
struct AppFeedback: Codable {
    let user_id: String
    let user_name: String
    let user_email: String
    let feedback_type: String
    let feedback_text: String
    let created_at: String
    let app_version: String
}

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isEditing: Bool = false
    @State private var editedName: String = ""
    @State private var editedEmail: String = ""
    @State private var showingLogoutConfirmation = false
    @State private var showingDeleteConfirmation = false
    @State private var isDeletingAccount = false
    @State private var isSaving = false
    @State private var showingFeedbackForm = false
    @State private var feedbackText = ""
    @State private var feedbackType = "General"
    @State private var isSubmittingFeedback = false
    @State private var showingFeedbackSuccess = false

    var body: some View {
        VStack {
            // Add top spacing - approximately 10% of screen height
            Spacer()
                .frame(height: UIScreen.main.bounds.height * 0.1)

            // User Info
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Name")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    if isEditing {
                        TextField("Name", text: $editedName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16))
                    } else {
                        Text(authViewModel.userName.isEmpty ? "Not set" : authViewModel.userName)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                    }
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Email")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    if isEditing {
                        TextField("Email", text: $editedEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16))
                            .disabled(true) // Usually don't allow email changes
                            .opacity(0.6)
                    } else {
                        Text(authViewModel.userEmail)
                            .font(.system(size: 16))
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
                        .font(.system(size: 16))
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
            
            // Feedback Button
            Button(action: {
                showingFeedbackForm = true
            }) {
                HStack {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 16))
                    Text("Submit Feedback")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hexString: "#132A47").opacity(0.1))
                .foregroundColor(Color(hexString: "#132A47"))
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Logout Button
            Button(action: {
                showingLogoutConfirmation = true
            }) {
                Text("Sign Out")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Delete Account Button
            Button(action: {
                showingDeleteConfirmation = true
            }) {
                HStack {
                    if isDeletingAccount {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    Text(isDeletingAccount ? "Deleting Account..." : "Delete Account")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isDeletingAccount)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Settings")
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
        .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete Account", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This action cannot be undone. Your account and all associated data will be permanently deleted.")
        }
        .sheet(isPresented: $showingFeedbackForm) {
            NavigationView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("We'd love to hear from you!")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // Feedback Type Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Feedback Type")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Picker("Feedback Type", selection: $feedbackType) {
                            Text("General").tag("General")
                            Text("Bug Report").tag("Bug Report")
                            Text("Feature Request").tag("Feature Request")
                            Text("Prayer Request").tag("Prayer Request")
                            Text("Testimonial").tag("Testimonial")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Feedback Text Area
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Feedback")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        TextEditor(text: $feedbackText)
                            .font(.system(size: 16))
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .frame(minHeight: 150)
                    }
                    
                    Spacer()
                    
                    // Submit Button
                    Button(action: {
                        submitFeedback()
                    }) {
                        HStack {
                            if isSubmittingFeedback {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text("Submit Feedback")
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(feedbackText.isEmpty ? Color.gray : Color(hexString: "#132A47"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(feedbackText.isEmpty || isSubmittingFeedback)
                }
                .padding()
                .navigationTitle("Feedback")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    trailing: Button("Cancel") {
                        showingFeedbackForm = false
                        feedbackText = ""
                        feedbackType = "General"
                    }
                )
            }
        }
        .alert("Thank You!", isPresented: $showingFeedbackSuccess) {
            Button("OK") {
                showingFeedbackForm = false
                feedbackText = ""
                feedbackType = "General"
            }
        } message: {
            Text("Your feedback has been submitted successfully. We appreciate your input!")
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
    
    private func submitFeedback() {
        isSubmittingFeedback = true
        
        Task {
            do {
                // Create feedback data structure
                let feedbackData = AppFeedback(
                    user_id: authViewModel.userId,
                    user_name: authViewModel.userName.isEmpty ? "Anonymous" : authViewModel.userName,
                    user_email: authViewModel.userEmail,
                    feedback_type: feedbackType,
                    feedback_text: feedbackText,
                    created_at: ISO8601DateFormatter().string(from: Date()),
                    app_version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
                )
                
                // Insert feedback into database
                _ = try await SupabaseManager.shared.client
                    .from("app_feedback")
                    .insert(feedbackData)
                    .execute()
                
                await MainActor.run {
                    isSubmittingFeedback = false
                    showingFeedbackSuccess = true
                }
                
                print("Feedback submitted successfully")
            } catch {
                print("Error submitting feedback: \(error)")
                await MainActor.run {
                    isSubmittingFeedback = false
                    // You might want to show an error alert here
                }
            }
        }
    }
    
    private func deleteAccount() {
        isDeletingAccount = true
        
        Task {
            defer {
                // Ensure we always log out and navigate to login, regardless of what happens
                Task { @MainActor in
                    isDeletingAccount = false
                    // Log out the user (this will trigger navigation to login)
                    authViewModel.logout()
                    print("🚪 User logged out and navigated to login page")
                }
            }
            
            // Track deletion results but don't stop if one fails
            var deletionErrors: [String] = []
            
            // Delete from users table
            do {
                try await SupabaseManager.shared.client
                    .from("users")
                    .delete()
                    .eq("email", value: authViewModel.userEmail)
                    .execute()
                print("✓ Deleted from users table")
            } catch {
                print("Failed to delete from users table: \(error)")
                deletionErrors.append("users")
            }
            
            // Delete from app_feedback table (if exists)
            do {
                try await SupabaseManager.shared.client
                    .from("app_feedback")
                    .delete()
                    .eq("user_email", value: authViewModel.userEmail)
                    .execute()
                print("✓ Deleted from app_feedback table")
            } catch {
                print("Failed to delete from app_feedback table: \(error)")
            }
            
            // Delete from rule_of_life table (if exists)
            do {
                try await SupabaseManager.shared.client
                    .from("rule_of_life")
                    .delete()
                    .eq("user_id", value: authViewModel.userId)
                    .execute()
                print("✓ Deleted from rule_of_life table")
            } catch {
                print("Failed to delete from rule_of_life table: \(error)")
            }
            
            // Delete from planning_ahead table (if exists)
            do {
                try await SupabaseManager.shared.client
                    .from("planning_ahead")
                    .delete()
                    .eq("user_id", value: authViewModel.userId)
                    .execute()
                print("✓ Deleted from planning_ahead table")
            } catch {
                print("Failed to delete from planning_ahead table: \(error)")
            }
            
            // Try to delete from week_reviews table (if exists)
            do {
                try await SupabaseManager.shared.client
                    .from("week_reviews")
                    .delete()
                    .eq("user_id", value: authViewModel.userId)
                    .execute()
                print("✓ Deleted from week_reviews table")
            } catch {
                print("Failed to delete from week_reviews table: \(error)")
                // This is the table that was causing the original error
            }
            
            print("Account deletion process completed")
            
            if !deletionErrors.isEmpty {
                print("Some tables couldn't be deleted: \(deletionErrors.joined(separator: ", "))")
            } else {
                print("All user data successfully deleted")
            }
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
