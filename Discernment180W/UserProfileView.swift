import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel // Use the AuthViewModel
    @State private var isEditing: Bool = false
    @State private var editedName: String = ""
    @State private var editedEmail: String = ""

    var body: some View {
        VStack {
            // Profile Image
            Image(systemName: "person.circle")
                .font(.system(size: 100))
                .padding()
                .onTapGesture {
                    print("Change profile picture")
                }
                .accessibilityLabel("Profile Image")

            // User Info
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Name:")
                        .font(.headline)
                    if isEditing {
                        TextField("Name", text: $editedName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(authViewModel.userName)
                            .font(.body)
                    }
                }

                HStack {
                    Text("Email:")
                        .font(.headline)
                    if isEditing {
                        TextField("Email", text: $editedEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(authViewModel.userEmail)
                            .font(.body)
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

            // Edit Button
            Button(action: {
                withAnimation {
                    if isEditing {
                        authViewModel.userName = editedName
                        authViewModel.userEmail = editedEmail
                        UserDefaults.standard.set(editedName, forKey: "userName")
                        UserDefaults.standard.set(editedEmail, forKey: "userEmail")
                    } else {
                        editedName = authViewModel.userName
                        editedEmail = authViewModel.userEmail
                    }
                    isEditing.toggle()
                }
            }) {
                Text(isEditing ? "Save Changes" : "Edit Profile")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isEditing ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            editedName = authViewModel.userName
            editedEmail = authViewModel.userEmail
        }
    }
}

