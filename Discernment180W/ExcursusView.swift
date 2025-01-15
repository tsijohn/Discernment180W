import SwiftUI
import Supabase

struct D180excursusmens: Codable, Identifiable {
    let id: Int
    let week: Int
    let reading: String
    let title: String
}

struct ExcursusView: View {
    @Environment(\.dismiss) var dismiss
    @State private var reading: D180excursusmens?
    @State private var isReadingComplete = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    if let reading = reading {
                        // Render Markdown here
                        if let attributedString = try? AttributedString(markdown: reading.reading) {
                            Text(attributedString)
                                .padding()
                        } else {
                            Text("Error rendering Markdown") // Handle Markdown parsing errors
                        }

                        HStack {
                            Text("Mark Reading as Complete")
                            Spacer()
                            Toggle("", isOn: $isReadingComplete)
                        }
                        .padding(.top, 8)
                    } else {
                        ProgressView()
                    }
                }
                .padding()
            }
            .navigationTitle(reading?.title ?? "Loading...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .task {
                do {
                    reading = try await SupabaseManager.shared.client
                        .from("d180excursusmens")
                        .select("*")
                        .eq("id", value: 1)
                        .single()
                        .execute()
                        .value
                } catch {
                    print("Error fetching data: \(error)")
                }
            }
        }
    }
}

struct ExcursusView_Previews: PreviewProvider {
    static var previews: some View {
        ExcursusView()
    }
}
