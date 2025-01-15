import SwiftUI

struct FraternityChatView: View {
    // Sample messages for the group chat
    @State private var messages = [
        "John: Hey guys, how's everyone doing?",
        "Mike: Doing well! Just finished my readings for today.",
        "Steve: Same here, looking forward to the retreat this weekend."
    ]
    
    @State private var newMessage = ""

    var body: some View {
        VStack {
            // Chat messages list
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(messages, id: \.self) { message in
                        Text(message)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            
            // Input field and send button
            HStack {
                TextField("Type a message...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: {
                    // Add the new message to the chat
                    if !newMessage.isEmpty {
                        messages.append("You: \(newMessage)")
                        newMessage = ""
                    }
                }) {
                    Text("Send")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle("Fraternity Chat")
    }
}

struct FraternityChatView_Previews: PreviewProvider {
    static var previews: some View {
        FraternityChatView()
    }
}
