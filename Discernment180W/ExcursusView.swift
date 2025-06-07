import SwiftUI
import Supabase

struct D180excursusmens: Codable, Identifiable {
    let id: Int
    let week: Int
    let reading: String
    let title: String
    let Complete: String?
    
    // Computed property to handle null values
    var isComplete: Bool {
        return Complete?.lowercased() == "yes"
    }
}

// MARK: - Table of Contents View
struct ExcursusView: View {
    @Environment(\.dismiss) var dismiss
    @State private var excursusReadings: [D180excursusmens] = []
    @State private var isLoading = true
    @State private var currentDay: Int = 1
    @State private var completedDays: [Int] = []
    
    private let accentColor = Color.blue
    private let backgroundColor = Color(.systemBackground)
    
    // Calculate current week from current day
    private var currentWeek: Int {
        return ((currentDay - 1) / 7) + 1
    }
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            if isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading excursus readings...")
                        .padding(.top, 16)
                        .foregroundColor(.secondary)
                }
            } else if excursusReadings.isEmpty {
                VStack(spacing: 20) {
                    // Current Day Header even when empty
                    CurrentDayHeader(currentDay: currentDay, currentWeek: currentWeek, accentColor: accentColor)
                        .padding(.top, 16)
                    
                    Image(systemName: "book.closed")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No excursus available")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Check back later for more readings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Retry Loading") {
                        Task {
                            isLoading = true
                            await loadAllData()
                            isLoading = false
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding()
            } else {
                VStack(spacing: 0) {
                    // Current Day Header at the top
                    CurrentDayHeader(currentDay: currentDay, currentWeek: currentWeek, accentColor: accentColor)
                        .padding(.top, 16)
                        .padding(.bottom, 16)
                    
                    // Excursus List
                    List {
                        ForEach(excursusReadings.sorted(by: { $0.week < $1.week })) { excursus in
                            NavigationLink(destination: ExcursusDetailView(excursus: excursus)) {
                                ExcursusRowView(excursus: excursus, accentColor: accentColor)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await loadAllData()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image("D180Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                    Text("Excursus Readings")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
        }
        .task {
            await loadAllData()
        }
    }
    
    // Load all data including current day, completed days, and excursus readings
    func loadAllData() async {
        isLoading = true
        
        // Fetch current day and completed days first, then readings
        await fetchCurrentDay()
        await fetchAllReadings()
        
        isLoading = false
    }
    
    // Fetch current day and completed days from Supabase (copied from NavigationHubView)
    func fetchCurrentDay() async {
        do {
            // Fetch current day
            let result: [[String: String]] = try await SupabaseManager.shared.client
                .from("users")
                .select("current_day")
                .eq("email", value: "Utjohnkkim@gmail.com")
                .execute()
                .value
            
            if let firstResult = result.first,
               let currentDayString = firstResult["current_day"],
               let day = Int(currentDayString) {
                await MainActor.run {
                    self.currentDay = day
                    print("✅ Current day set to: \(day)")
                }
            }
            
            // Fetch completed days
            struct Response: Decodable {
                let completed_days: [Int]?
            }
            
            let completedResponse = try await SupabaseManager.shared.client
                .from("users")
                .select("completed_days")
                .eq("email", value: "Utjohnkkim@gmail.com")
                .execute()
            
            let data = completedResponse.data
            do {
                let decoded = try JSONDecoder().decode([Response].self, from: data)
                if let firstUser = decoded.first, let completed = firstUser.completed_days {
                    await MainActor.run {
                        self.completedDays = completed
                        print("✅ Completed days: \(completed)")
                    }
                }
            } catch {
                print("❌ Error decoding completed days: \(error)")
            }
        } catch {
            print("❌ Error fetching data: \(error)")
        }
    }
    
    func fetchAllReadings() async {
        do {
            print("Attempting to fetch excursus readings...")
            excursusReadings = try await SupabaseManager.shared.client
                .from("d180excursusmens")
                .select("*")
                .order("week", ascending: true)
                .execute()
                .value
            
            print("Successfully fetched \(excursusReadings.count) excursus readings")
            
            // Debug: Print first few readings
            for (index, reading) in excursusReadings.prefix(3).enumerated() {
                print("Reading \(index + 1): Week \(reading.week), Title: \(reading.title)")
            }
            
        } catch {
            print("Error fetching excursus readings: \(error)")
            print("Error details: \(error.localizedDescription)")
            
            // Try the old query as fallback to see if data exists
            do {
                print("Trying fallback query...")
                excursusReadings = try await SupabaseManager.shared.client
                    .from("d180excursusmens")
                    .select("*")
                    .execute()
                    .value
                
                print("Fallback query returned \(excursusReadings.count) readings")
                
            } catch {
                print("Fallback query also failed: \(error)")
            }
        }
    }
}

// MARK: - Current Day Header Component (simplified)
struct CurrentDayHeader: View {
    let currentDay: Int
    let currentWeek: Int
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Currently on:")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Day \(currentDay), Week \(currentWeek)")
                    .font(.headline)
                    .foregroundColor(Color(hexString: "#19223b"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(hexString: "#19223b").opacity(0.2))
                    )
                
                Spacer()
            }
            
            // Progress indicator
            ProgressIndicator(currentDay: currentDay, currentWeek: currentWeek, accentColor: accentColor)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hexString: "#19223b").opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

// MARK: - Progress Indicator
struct ProgressIndicator: View {
    let currentDay: Int
    let currentWeek: Int
    let accentColor: Color
    
    private var progressPercentage: Double {
        return min(Double(currentDay) / 180.0, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Week \(currentWeek) of 26")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(progressPercentage * 100))% Complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }
            
            ProgressView(value: progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(hexString: "#19223b")))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
        }
    }
}

// MARK: - Row View for Table of Contents
struct ExcursusRowView: View {
    let excursus: D180excursusmens
    let accentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Week \(excursus.week)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    Text(excursus.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                VStack {
                    if excursus.isComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(accentColor)
                            .font(.title2)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.secondary)
                            .font(.title2)
                    }
                    
                    Text(excursus.isComplete ? "Complete" : "Incomplete")
                        .font(.caption2)
                        .foregroundColor(excursus.isComplete ? accentColor : .secondary)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
        .overlay(
            excursus.isComplete ?
            RoundedRectangle(cornerRadius: 12)
                .stroke(accentColor, lineWidth: 1.5)
            : nil
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

// MARK: - Detail View for Individual Excursus
struct ExcursusDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State var excursus: D180excursusmens
    @State private var isReadingComplete = false
    
    private let accentColor = Color.blue
    private let backgroundColor = Color(.systemBackground)
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 16) {
                    ExcursusDetailCard(
                        excursus: excursus,
                        isComplete: $isReadingComplete,
                        accentColor: accentColor,
                        onCompletionChange: { newValue in
                            Task {
                                await updateCompletionStatus(isComplete: newValue)
                            }
                        }
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Week \(excursus.week)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Excursus")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
        .onAppear {
            isReadingComplete = excursus.isComplete
        }
    }
    
    func updateCompletionStatus(isComplete: Bool) async {
        let newStatus = isComplete ? "Yes" : "No"
        
        do {
            try await SupabaseManager.shared.client
                .from("d180excursusmens")
                .update(["Complete": newStatus])
                .eq("id", value: excursus.id)
                .execute()
            
            // Update local state
            excursus = D180excursusmens(
                id: excursus.id,
                week: excursus.week,
                reading: excursus.reading,
                title: excursus.title,
                Complete: newStatus
            )
            
            print("Completion status updated to \(newStatus)")
        } catch {
            print("Error updating completion status: \(error)")
        }
    }
}

// MARK: - Detail Card Component
struct ExcursusDetailCard: View {
    let excursus: D180excursusmens
    @Binding var isComplete: Bool
    let accentColor: Color
    let onCompletionChange: (Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Week \(excursus.week)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
                
                Text(excursus.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Divider()
            
            if let attributedString = try? AttributedString(markdown: excursus.reading) {
                Text(attributedString)
                    .font(.body)
                    .lineSpacing(6)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Error rendering Markdown")
                    .foregroundColor(.red)
            }
            
            HStack {
                Text("Mark as Complete")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Toggle("", isOn: $isComplete)
                    .toggleStyle(SwitchToggleStyle(tint: accentColor))
                    .onChange(of: isComplete) { newValue in
                        onCompletionChange(newValue)
                    }
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .overlay(
            isComplete ?
            RoundedRectangle(cornerRadius: 16)
                .stroke(accentColor, lineWidth: 2)
            : nil
        )
        .animation(.easeInOut(duration: 0.2), value: isComplete)
    }
}

// MARK: - Color Extension (copied from NavigationHubView)
