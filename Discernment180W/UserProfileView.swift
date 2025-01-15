import SwiftUI

struct UserProfileView: View {
    @State private var isEditing: Bool = false // Toggle for edit mode
    
    var body: some View {
        VStack {
            // Profile Image
            Image(systemName: "person.circle")
                .font(.system(size: 100))
                .padding()
                .onTapGesture {
                    // Action for changing profile image
                    print("Change profile picture")
                }
                .accessibilityLabel("Profile Image")

            // User Info
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Name:")
                        .font(.headline)
                    if isEditing {
                        TextField("Name", text: .constant("Greg Gerhart"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text("Greg Gerhart")
                            .font(.body)
                    }
                }

                HStack {
                    Text("Email:")
                        .font(.headline)
                    if isEditing {
                        TextField("Email", text: .constant("fr.greg.gerhart@austindiocese.org"))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text("fr.greg.gerhart@austindiocese.org")
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
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
