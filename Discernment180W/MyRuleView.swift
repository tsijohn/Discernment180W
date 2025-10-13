import SwiftUI

struct MyRuleView: View {
    @Environment(\.dismiss) var dismiss
    @State private var shouldNavigateToDay0 = false

    // Prayer
    @State private var prayerMinutes: String = ""
    @State private var prayerTimeFrom: String = ""
    @State private var prayerTimeTo: String = ""
    @State private var wakeUpTime: String = ""
    @State private var bedTime: String = ""
    @State private var additionalHours: String = ""
    
    // Sacraments
    @State private var massTimesPerWeek: String = ""
    @State private var additionalMassDays: String = ""
    @State private var confessionTimesPerMonth: String = ""
    
    // Virtue
    @State private var digitalFast: String = ""
    @State private var bodilyFast: String = ""
    @State private var chastityPractices: String = ""
    
    // Service
    @State private var altarServerParish: String = ""
    @State private var spiritualWorkOfMercy: String = ""
    @State private var corporalWorkOfMercy: String = ""
    
    // Study
    @State private var readingMinutesPerDay: String = ""
    @State private var readingDaysPerWeek: String = ""
    
    // Dating Fast
    @State private var datingFastCommitment: Bool = false
    
    // Spiritual Direction
    @State private var spiritualDirectorName: String = ""
    
    // Seminary Visit
    @State private var seminaryName: String = ""
    @State private var seminaryVisitDate: String = ""
    
    // Discernment Retreat
    @State private var retreatName: String = ""
    @State private var retreatDate: String = ""
    
    @State private var isSaving = false
    @State private var showingSaveConfirmation = false
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Codable struct for database operations
    struct RuleOfLifeData: Codable {
        let user_id: String
        let prayer_minutes: String
        let prayer_time_from: String
        let prayer_time_to: String
        let wake_up_time: String
        let bed_time: String
        let additional_hours: String
        let mass_times_per_week: String
        let additional_mass_days: String
        let confession_times_per_month: String
        let digital_fast: String
        let bodily_fast: String
        let chastity_practices: String
        let altar_server_parish: String
        let spiritual_work_of_mercy: String
        let corporal_work_of_mercy: String
        let reading_minutes_per_day: String
        let reading_days_per_week: String
        let dating_fast_commitment: Bool
        let spiritual_director_name: String
        let seminary_name: String
        let seminary_visit_date: String
        let retreat_name: String
        let retreat_date: String
        let dismiss_romantic_interests: Bool
        let avoid_one_on_one: Bool
        let prayer_notes1: String
        let prayer_notes2: String
        let sacraments_notes1: String
        let sacraments_notes2: String
        let virtue_notes1: String
        let virtue_notes2: String
        let service_notes1: String
        let service_notes2: String
        let study_notes1: String
        let study_notes2: String
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("My Rule of Life")
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Prayer Section
                        RuleSectionView(title: "Prayer") {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text("I will pray for")
                                    TextField("60", text: $prayerMinutes)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 60)
                                        .keyboardType(.numberPad)
                                    Text("minutes every day")
                                }
                                
                                HStack {
                                    Text("Prayer time from")
                                    TextField("6:00 AM", text: $prayerTimeFrom)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 100)
                                    Text("to")
                                    TextField("7:00 AM", text: $prayerTimeTo)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 100)
                                }
                                
                                HStack {
                                    Text("Wake up at")
                                    TextField("5:30 AM", text: $wakeUpTime)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 100)
                                    Text("Bedtime")
                                    TextField("10:30 PM", text: $bedTime)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 100)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Additional hours to pray daily:")
                                    TextField("Morning Prayer, Evening Prayer", text: $additionalHours)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                        }
                        
                        // Sacraments Section
                        RuleSectionView(title: "Sacraments") {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text("Mass")
                                    TextField("2", text: $massTimesPerWeek)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 50)
                                        .keyboardType(.numberPad)
                                    Text("times per week")
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Additional Mass days (besides Sunday):")
                                    TextField("Wednesday, Friday", text: $additionalMassDays)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                HStack {
                                    Text("Confession")
                                    TextField("2", text: $confessionTimesPerMonth)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 50)
                                        .keyboardType(.numberPad)
                                    Text("times a month")
                                }
                            }
                        }
                        
                        // Virtue Section
                        RuleSectionView(title: "Virtue") {
                            VStack(alignment: .leading, spacing: 15) {
                                VStack(alignment: .leading) {
                                    Text("Digital fast:")
                                    TextField("No social media, limit internet to 30 min/day", text: $digitalFast)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Bodily fast:")
                                    TextField("No meat on Fridays, cold showers", text: $bodilyFast)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Chastity practices from hismercyendures.org:")
                                    TextField("Daily accountability, internet filter", text: $chastityPractices)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                        }
                        
                        // Service Section
                        RuleSectionView(title: "Service") {
                            VStack(alignment: .leading, spacing: 15) {
                                VStack(alignment: .leading) {
                                    Text("Altar server at parish:")
                                    TextField("St. Mary's Catholic Church", text: $altarServerParish)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Spiritual work of mercy:")
                                    TextField("Teaching CCD on Sundays", text: $spiritualWorkOfMercy)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                
                                VStack(alignment: .leading) {
                                    Text("Corporal work of mercy:")
                                    TextField("Soup kitchen on Saturdays", text: $corporalWorkOfMercy)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                        }
                        
                        // Study Section
                        RuleSectionView(title: "Study") {
                            HStack {
                                Text("Spiritual reading for")
                                TextField("30", text: $readingMinutesPerDay)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 50)
                                    .keyboardType(.numberPad)
                                Text("minutes/day,")
                                TextField("7", text: $readingDaysPerWeek)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 50)
                                    .keyboardType(.numberPad)
                                Text("days/week")
                            }
                        }
                        
                        // Specific Discernment Actions
                        RuleSectionView(title: "Dating Fast") {
                            Toggle("I commit to a dating fast for 180 days", isOn: $datingFastCommitment)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        
                        RuleSectionView(title: "Spiritual Direction") {
                            VStack(alignment: .leading) {
                                Text("Spiritual Director:")
                                TextField("Fr. John Smith", text: $spiritualDirectorName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                        
                        RuleSectionView(title: "Seminary Visit") {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Seminary to visit:")
                                TextField("St. John's Seminary", text: $seminaryName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Text("Visit date:")
                                TextField("March 15, 2025", text: $seminaryVisitDate)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                        
                        RuleSectionView(title: "Discernment Retreat") {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Retreat:")
                                TextField("Annual Discernment Retreat", text: $retreatName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Text("Retreat date:")
                                TextField("April 10-12, 2025", text: $retreatDate)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                        }
                        
                        // Save Button
                        Button(action: saveMyRule) {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                }
                                Text(isSaving ? "Saving..." : "Save My Rule")
                                    .font(.system(size: 18))
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isSaving ? Color.gray : Color.blue)
                            .cornerRadius(10)
                        }
                        .disabled(isSaving)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    .padding(.vertical)
                }
            }
            .background(Color(.systemGray6))
            .background(
                NavigationLink(
                    destination: Day0ViewForCurriculumZero()
                        .environmentObject(authViewModel)
                        .navigationBarBackButtonHidden(true),
                    isActive: $shouldNavigateToDay0
                ) {
                    EmptyView()
                }
            )
        }
        .onAppear {
            Task {
                await loadExistingRule()
            }
        }
        .alert("Success", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) {
                // Navigate to Day0 view after alert is dismissed
                shouldNavigateToDay0 = true
            }
        } message: {
            Text("Your Rule of Life has been saved.")
        }
    }
    
    private func saveMyRule() {
        Task {
            await MainActor.run {
                isSaving = true
            }
            
            do {
                // First, update the user's curriculum_order to 0
                try await SupabaseManager.shared.client
                    .from("users")
                    .update(["curriculum_order": "0"])
                    .eq("email", value: authViewModel.userEmail)
                    .execute()
                
                let ruleData = RuleOfLifeData(
                    user_id: authViewModel.userId,
                    prayer_minutes: prayerMinutes,
                    prayer_time_from: prayerTimeFrom,
                    prayer_time_to: prayerTimeTo,
                    wake_up_time: wakeUpTime,
                    bed_time: bedTime,
                    additional_hours: additionalHours,
                    mass_times_per_week: massTimesPerWeek,
                    additional_mass_days: additionalMassDays,
                    confession_times_per_month: confessionTimesPerMonth,
                    digital_fast: digitalFast,
                    bodily_fast: bodilyFast,
                    chastity_practices: chastityPractices,
                    altar_server_parish: altarServerParish,
                    spiritual_work_of_mercy: spiritualWorkOfMercy,
                    corporal_work_of_mercy: corporalWorkOfMercy,
                    reading_minutes_per_day: readingMinutesPerDay,
                    reading_days_per_week: readingDaysPerWeek,
                    dating_fast_commitment: datingFastCommitment,
                    spiritual_director_name: spiritualDirectorName,
                    seminary_name: seminaryName,
                    seminary_visit_date: seminaryVisitDate,
                    retreat_name: retreatName,
                    retreat_date: retreatDate,
                    dismiss_romantic_interests: false,
                    avoid_one_on_one: false,
                    prayer_notes1: "",
                    prayer_notes2: "",
                    sacraments_notes1: "",
                    sacraments_notes2: "",
                    virtue_notes1: "",
                    virtue_notes2: "",
                    service_notes1: "",
                    service_notes2: "",
                    study_notes1: "",
                    study_notes2: ""
                )
                
                // Check if record exists
                let response = try await SupabaseManager.shared.client
                    .from("rule_of_life")
                    .select("id")
                    .eq("user_id", value: authViewModel.userId)
                    .execute()
                
                if let dataArray = try JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
                   let existingId = dataArray.first?["id"] as? Int {
                    // Update existing record
                    try await SupabaseManager.shared.client
                        .from("rule_of_life")
                        .update(ruleData)
                        .eq("id", value: String(existingId))
                        .execute()
                } else {
                    // Insert new record
                    try await SupabaseManager.shared.client
                        .from("rule_of_life")
                        .insert(ruleData)
                        .execute()
                }
                
                await MainActor.run {
                    isSaving = false
                    showingSaveConfirmation = true
                }
            } catch {
                print("Error saving My Rule: \(error)")
                await MainActor.run {
                    isSaving = false
                }
            }
        }
    }
    
    private func loadExistingRule() async {
        do {
            let response = try await SupabaseManager.shared.client
                .from("rule_of_life")
                .select("*")
                .eq("user_id", value: authViewModel.userId)
                .execute()
            
            if let dataArray = try JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
               let ruleData = dataArray.first {
                await MainActor.run {
                    prayerMinutes = ruleData["prayer_minutes"] as? String ?? ""
                    prayerTimeFrom = ruleData["prayer_time_from"] as? String ?? ""
                    prayerTimeTo = ruleData["prayer_time_to"] as? String ?? ""
                    wakeUpTime = ruleData["wake_up_time"] as? String ?? ""
                    bedTime = ruleData["bed_time"] as? String ?? ""
                    additionalHours = ruleData["additional_hours"] as? String ?? ""
                    massTimesPerWeek = ruleData["mass_times_per_week"] as? String ?? ""
                    additionalMassDays = ruleData["additional_mass_days"] as? String ?? ""
                    confessionTimesPerMonth = ruleData["confession_times_per_month"] as? String ?? ""
                    digitalFast = ruleData["digital_fast"] as? String ?? ""
                    bodilyFast = ruleData["bodily_fast"] as? String ?? ""
                    chastityPractices = ruleData["chastity_practices"] as? String ?? ""
                    altarServerParish = ruleData["altar_server_parish"] as? String ?? ""
                    spiritualWorkOfMercy = ruleData["spiritual_work_of_mercy"] as? String ?? ""
                    corporalWorkOfMercy = ruleData["corporal_work_of_mercy"] as? String ?? ""
                    readingMinutesPerDay = ruleData["reading_minutes_per_day"] as? String ?? ""
                    readingDaysPerWeek = ruleData["reading_days_per_week"] as? String ?? ""
                    datingFastCommitment = ruleData["dating_fast_commitment"] as? Bool ?? false
                    spiritualDirectorName = ruleData["spiritual_director_name"] as? String ?? ""
                    seminaryName = ruleData["seminary_name"] as? String ?? ""
                    seminaryVisitDate = ruleData["seminary_visit_date"] as? String ?? ""
                    retreatName = ruleData["retreat_name"] as? String ?? ""
                    retreatDate = ruleData["retreat_date"] as? String ?? ""
                }
            }
        } catch {
            print("Error loading My Rule: \(error)")
        }
    }
}

// Create a special Day0 view that loads curriculum_order 0
struct Day0ViewForCurriculumZero: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        // This will be your existing Day0View but modified to load curriculum_order 0
        Day0View()  // Remove the showCurriculumZero parameter
            .environmentObject(authViewModel)
    }
}

// Helper view for sections
struct RuleSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            content
                .padding()
                .background(Color.white)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct MyRuleView_Previews: PreviewProvider {
    static var previews: some View {
        MyRuleView()
            .environmentObject(AuthViewModel())
    }
}
