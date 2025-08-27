import SwiftUI
import Supabase

struct RuleOfLifeFormView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Create a Codable struct for the data
    struct RuleOfLifeData: Codable {
        let user_id: String
        // Prayer
        let prayer_minutes: String
        let prayer_time_from: String
        let prayer_time_to: String
        let wake_up_time: String
        let bed_time: String
        let additional_hours: String
        let prayer_notes1: String
        let prayer_notes2: String
        // Sacraments
        let mass_times_per_week: String
        let additional_mass_days: String
        let confession_times_per_month: String
        let sacraments_notes1: String
        let sacraments_notes2: String
        // Virtue
        let digital_fast: String
        let bodily_fast: String
        let chastity_practices: String
        let virtue_notes1: String
        let virtue_notes2: String
        // Service
        let altar_server_parish: String
        let spiritual_work_of_mercy: String
        let corporal_work_of_mercy: String
        let service_notes1: String
        let service_notes2: String
        // Study
        let reading_minutes_per_day: String
        let reading_days_per_week: String
        let study_notes1: String
        let study_notes2: String
        // Specific Discernment
        let dating_fast_commitment: Bool
        let dismiss_romantic_interests: Bool
        let avoid_one_on_one: Bool
        let spiritual_director_name: String
        let seminary_name: String
        let seminary_visit_date: String
        let retreat_name: String
        let retreat_date: String
        let created_at: String?
    }
    
    // Prayer Section
    @State private var prayerMinutes = ""
    @State private var prayerTimeFrom = ""
    @State private var prayerTimeTo = ""
    @State private var wakeUpTime = ""
    @State private var bedTime = ""
    @State private var additionalHours = ""
    @State private var prayerNotes1 = ""
    @State private var prayerNotes2 = ""
    
    // Sacraments Section
    @State private var massTimesPerWeek = ""
    @State private var additionalMassDays = ""
    @State private var confessionTimesPerMonth = ""
    @State private var sacramentsNotes1 = ""
    @State private var sacramentsNotes2 = ""
    
    // Virtue Section
    @State private var digitalFast = ""
    @State private var bodilyFast = ""
    @State private var chastityPractices = ""
    @State private var virtueNotes1 = ""
    @State private var virtueNotes2 = ""
    
    // Service Section
    @State private var altarServerParish = ""
    @State private var spiritualWorkOfMercy = ""
    @State private var corporalWorkOfMercy = ""
    @State private var serviceNotes1 = ""
    @State private var serviceNotes2 = ""
    
    // Study Section
    @State private var readingMinutesPerDay = ""
    @State private var readingDaysPerWeek = ""
    @State private var studyNotes1 = ""
    @State private var studyNotes2 = ""
    
    // Specific Discernment Actions
    @State private var datingFastCommitment = false
    @State private var dismissRomanticInterests = false
    @State private var avoidOneOnOne = false
    @State private var spiritualDirectorName = ""
    @State private var seminaryName = ""
    @State private var seminaryVisitDate = ""
    @State private var retreatName = ""
    @State private var retreatDate = ""
    
    @State private var isSaving = false
    @State private var showingSaveConfirmation = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingErrorAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed header with back button
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                        Text("Back")
                            .font(.system(size: 17, weight: .medium))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                    )
                }
                
                Spacer()
                
                Text("Rule of Life")
                    .font(.custom("Georgia", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                // Empty space for symmetry
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(.clear)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGroupedBackground))
            
            // Scrollable content
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 15) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            prayerSection()
                            sacramentsSection()
                            virtueSection()
                            serviceSection()
                            studySection()
                            specificDiscernmentSection()
                        }
                        .padding(.top, 8)
                    }
                    
                    // Save button
                    Button(action: {
                        guard !isSaving else { return }
                        saveRuleOfLife()
                    }) {
                        HStack {
                            if isSaving {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundColor(.white)
                            }
                            Text(isSaving ? "Saving..." : "Save Rule of Life")
                                .font(.custom("Georgia", size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(isSaving ? Color.gray : Color.blue)
                        .cornerRadius(10)
                    }
                    .disabled(isSaving)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    
                    Spacer()
                }
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .frame(width: 50, height: 50)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task {
                await loadExistingRule()
            }
        }
        .alert("Success", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Your Rule of Life has been saved successfully.")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Section Views
    
    func prayerSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Prayer")
                .font(.custom("Georgia", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.leading, 16)
            
            VStack(alignment: .leading, spacing: 15) {
                // Prayer minutes
                HStack {
                    Text("I will pray for")
                        .font(.custom("Georgia", size: 16))
                    TextField("60", text: $prayerMinutes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 60)
                        .keyboardType(.numberPad)
                    Text("minutes every day")
                        .font(.custom("Georgia", size: 16))
                }
                .padding(.horizontal, 16)
                
                // Prayer time
                HStack {
                    Text("My prayer time will be from")
                        .font(.custom("Georgia", size: 16))
                    TextField("6:00 AM", text: $prayerTimeFrom)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                    Text("to")
                        .font(.custom("Georgia", size: 16))
                    TextField("7:00 AM", text: $prayerTimeTo)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
                .padding(.horizontal, 16)
                
                // Wake up and bedtime
                HStack {
                    Text("I will wake up at")
                        .font(.custom("Georgia", size: 16))
                    TextField("5:30 AM", text: $wakeUpTime)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                    Text("Bedtime")
                        .font(.custom("Georgia", size: 16))
                    TextField("10:30 PM", text: $bedTime)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
                .padding(.horizontal, 16)
                
                Text("(Allow for 7 hours of sleep)")
                    .font(.custom("Georgia", size: 14))
                    .italic()
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                
                Text("✓ I will pray Night Prayer every night")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("I will also pray these hours every day:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                    
                    TextEditor(text: $additionalHours)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 60)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Additional notes:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                    
                    TextEditor(text: $prayerNotes1)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 80)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
            }
        }
    }
    
    func sacramentsSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sacraments")
                .font(.custom("Georgia", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.leading, 16)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("I will go to Mass")
                        .font(.custom("Georgia", size: 16))
                    TextField("3", text: $massTimesPerWeek)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                        .keyboardType(.numberPad)
                    Text("times a week")
                        .font(.custom("Georgia", size: 16))
                }
                .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Aside from Sunday, I will go to Mass on:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                    
                    TextEditor(text: $additionalMassDays)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 60)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                
                HStack {
                    Text("I will go to Confession")
                        .font(.custom("Georgia", size: 16))
                    TextField("2", text: $confessionTimesPerMonth)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                        .keyboardType(.numberPad)
                    Text("times a month")
                        .font(.custom("Georgia", size: 16))
                }
                .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Additional notes:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                    
                    TextEditor(text: $sacramentsNotes1)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 80)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
            }
        }
    }
    
    func virtueSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Virtue")
                .font(.custom("Georgia", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.leading, 16)
            
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("I will engage in this digital fast:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                    
                    TextEditor(text: $digitalFast)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 80)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("I will engage in this bodily fast:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                    
                    TextEditor(text: $bodilyFast)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 80)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("I will fulfill these practices from hismercyendures.org:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                    
                    TextEditor(text: $chastityPractices)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 80)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Additional notes:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                    
                    TextEditor(text: $virtueNotes1)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 80)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
            }
        }
    }
    
    func serviceSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Service")
                .font(.custom("Georgia", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.leading, 16)
            
            VStack(alignment: .leading, spacing: 15) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("I will be an altar server at this parish:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                    
                    TextEditor(text: $altarServerParish)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 60)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("I will do this spiritual work of mercy:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                    
                    TextEditor(text: $spiritualWorkOfMercy)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 80)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("I will do this corporal work of mercy:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                    
                    TextEditor(text: $corporalWorkOfMercy)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 80)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Additional notes:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                    
                    TextEditor(text: $serviceNotes1)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 80)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
            }
        }
    }
    
    func studySection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Study")
                .font(.custom("Georgia", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.leading, 16)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("I will do spiritual reading for")
                        .font(.custom("Georgia", size: 16))
                    TextField("30", text: $readingMinutesPerDay)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                        .keyboardType(.numberPad)
                    Text("minutes a day")
                        .font(.custom("Georgia", size: 16))
                    TextField("7", text: $readingDaysPerWeek)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                        .keyboardType(.numberPad)
                    Text("times a week")
                        .font(.custom("Georgia", size: 16))
                }
                .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Additional notes:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                    
                    TextEditor(text: $studyNotes1)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 80)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
            }
        }
    }
    
    func specificDiscernmentSection() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Specific Discernment Actions")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.leading, 16)
                .padding(.top, 10)
            
            // Dating Fast
            VStack(alignment: .leading, spacing: 10) {
                Text("Dating Fast")
                    .font(.custom("Georgia", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                
                VStack(alignment: .leading, spacing: 15) {
                    Button(action: { datingFastCommitment.toggle() }) {
                        HStack {
                            Image(systemName: datingFastCommitment ? "checkmark.square.fill" : "square")
                                .foregroundColor(datingFastCommitment ? .blue : .gray)
                                .font(.system(size: 20))
                            Text("I will relate to women in the way that a priest relates to women for 180 days")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Button(action: { dismissRomanticInterests.toggle() }) {
                        HStack {
                            Image(systemName: dismissRomanticInterests ? "checkmark.square.fill" : "square")
                                .foregroundColor(dismissRomanticInterests ? .blue : .gray)
                                .font(.system(size: 20))
                            Text("I will dismiss any romantic interests that arise for 180 days")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Button(action: { avoidOneOnOne.toggle() }) {
                        HStack {
                            Image(systemName: avoidOneOnOne ? "checkmark.square.fill" : "square")
                                .foregroundColor(avoidOneOnOne ? .blue : .gray)
                                .font(.system(size: 20))
                            Text("I will avoid one-on-one settings with women for 180 days")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            
            // Spiritual Direction
            VStack(alignment: .leading, spacing: 10) {
                Text("Spiritual Direction")
                    .font(.custom("Georgia", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                
                Text("✓ I will go to spiritual direction once a month")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("My spiritual director is:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                    
                    TextEditor(text: $spiritualDirectorName)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 60)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
            }
            
            // Visit a Seminary
            VStack(alignment: .leading, spacing: 10) {
                Text("Visit a Seminary")
                    .font(.custom("Georgia", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                
                HStack {
                    Text("I will visit")
                        .font(.custom("Georgia", size: 16))
                    TextField("St. John's", text: $seminaryName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 120)
                    Text("Seminary")
                        .font(.custom("Georgia", size: 16))
                }
                .padding(.horizontal, 16)
                
                HStack {
                    Text("on this date:")
                        .font(.custom("Georgia", size: 16))
                    TextField("March 15, 2025", text: $seminaryVisitDate)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 150)
                }
                .padding(.horizontal, 16)
                
                Text("(Start Discernment 180 even if you do not know when you will be able to visit a seminary.)")
                    .font(.custom("Georgia", size: 14))
                    .italic()
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
            }
            
            // Discernment Retreat
            VStack(alignment: .leading, spacing: 10) {
                Text("Discernment Retreat")
                    .font(.custom("Georgia", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("I will go on this retreat:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                    
                    TextEditor(text: $retreatName)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 60)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("It takes place on this date:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                    
                    TextEditor(text: $retreatDate)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 60)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }
                
                Text("(Start Discernment 180 even if you do not know when you will be able to make a retreat.)")
                    .font(.custom("Georgia", size: 14))
                    .italic()
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
            }
            
            // Add bottom padding
            Spacer().frame(height: 20)
        }
    }
    
    // MARK: - Save and Load Functions (remain the same)
    
    private func saveRuleOfLife() {
        Task {
            await MainActor.run {
                isSaving = true
                isLoading = true
            }
            
            do {
                let ruleData = RuleOfLifeData(
                    user_id: authViewModel.userId,
                    prayer_minutes: prayerMinutes,
                    prayer_time_from: prayerTimeFrom,
                    prayer_time_to: prayerTimeTo,
                    wake_up_time: wakeUpTime,
                    bed_time: bedTime,
                    additional_hours: additionalHours,
                    prayer_notes1: prayerNotes1,
                    prayer_notes2: prayerNotes2,
                    mass_times_per_week: massTimesPerWeek,
                    additional_mass_days: additionalMassDays,
                    confession_times_per_month: confessionTimesPerMonth,
                    sacraments_notes1: sacramentsNotes1,
                    sacraments_notes2: sacramentsNotes2,
                    digital_fast: digitalFast,
                    bodily_fast: bodilyFast,
                    chastity_practices: chastityPractices,
                    virtue_notes1: virtueNotes1,
                    virtue_notes2: virtueNotes2,
                    altar_server_parish: altarServerParish,
                    spiritual_work_of_mercy: spiritualWorkOfMercy,
                    corporal_work_of_mercy: corporalWorkOfMercy,
                    service_notes1: serviceNotes1,
                    service_notes2: serviceNotes2,
                    reading_minutes_per_day: readingMinutesPerDay,
                    reading_days_per_week: readingDaysPerWeek,
                    study_notes1: studyNotes1,
                    study_notes2: studyNotes2,
                    dating_fast_commitment: datingFastCommitment,
                    dismiss_romantic_interests: dismissRomanticInterests,
                    avoid_one_on_one: avoidOneOnOne,
                    spiritual_director_name: spiritualDirectorName,
                    seminary_name: seminaryName,
                    seminary_visit_date: seminaryVisitDate,
                    retreat_name: retreatName,
                    retreat_date: retreatDate,
                    created_at: ISO8601DateFormatter().string(from: Date())
                )
                
                // Check if record exists
                let response = try await SupabaseManager.shared.client
                    .from("rule_of_life")
                    .select("id")
                    .eq("user_id", value: authViewModel.userId)
                    .execute()
                
                if let dataArray = try JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
                   !dataArray.isEmpty {
                    // Update existing record
                    try await SupabaseManager.shared.client
                        .from("rule_of_life")
                        .update(ruleData)
                        .eq("user_id", value: authViewModel.userId)
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
                    isLoading = false
                    showingSaveConfirmation = true
                }
            } catch {
                print("Error saving Rule of Life: \(error)")
                await MainActor.run {
                    isSaving = false
                    isLoading = false
                    errorMessage = "Error saving Rule of Life: \(error.localizedDescription)"
                    showingErrorAlert = true
                }
            }
        }
    }
    
    private func loadExistingRule() async {
        await MainActor.run {
            isLoading = true
        }
        
        do {
            let response = try await SupabaseManager.shared.client
                .from("rule_of_life")
                .select("*")
                .eq("user_id", value: authViewModel.userId)
                .execute()
            
            if let dataArray = try JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
               let ruleData = dataArray.first {
                await MainActor.run {
                    // Prayer
                    prayerMinutes = ruleData["prayer_minutes"] as? String ?? ""
                    prayerTimeFrom = ruleData["prayer_time_from"] as? String ?? ""
                    prayerTimeTo = ruleData["prayer_time_to"] as? String ?? ""
                    wakeUpTime = ruleData["wake_up_time"] as? String ?? ""
                    bedTime = ruleData["bed_time"] as? String ?? ""
                    additionalHours = ruleData["additional_hours"] as? String ?? ""
                    prayerNotes1 = ruleData["prayer_notes1"] as? String ?? ""
                    prayerNotes2 = ruleData["prayer_notes2"] as? String ?? ""
                    // Sacraments
                    massTimesPerWeek = ruleData["mass_times_per_week"] as? String ?? ""
                    additionalMassDays = ruleData["additional_mass_days"] as? String ?? ""
                    confessionTimesPerMonth = ruleData["confession_times_per_month"] as? String ?? ""
                    sacramentsNotes1 = ruleData["sacraments_notes1"] as? String ?? ""
                    sacramentsNotes2 = ruleData["sacraments_notes2"] as? String ?? ""
                    // Virtue
                    digitalFast = ruleData["digital_fast"] as? String ?? ""
                    bodilyFast = ruleData["bodily_fast"] as? String ?? ""
                    chastityPractices = ruleData["chastity_practices"] as? String ?? ""
                    virtueNotes1 = ruleData["virtue_notes1"] as? String ?? ""
                    virtueNotes2 = ruleData["virtue_notes2"] as? String ?? ""
                    // Service
                    altarServerParish = ruleData["altar_server_parish"] as? String ?? ""
                    spiritualWorkOfMercy = ruleData["spiritual_work_of_mercy"] as? String ?? ""
                    corporalWorkOfMercy = ruleData["corporal_work_of_mercy"] as? String ?? ""
                    serviceNotes1 = ruleData["service_notes1"] as? String ?? ""
                    serviceNotes2 = ruleData["service_notes2"] as? String ?? ""
                    // Study
                    readingMinutesPerDay = ruleData["reading_minutes_per_day"] as? String ?? ""
                    readingDaysPerWeek = ruleData["reading_days_per_week"] as? String ?? ""
                    studyNotes1 = ruleData["study_notes1"] as? String ?? ""
                    studyNotes2 = ruleData["study_notes2"] as? String ?? ""
                    // Specific Discernment
                    datingFastCommitment = ruleData["dating_fast_commitment"] as? Bool ?? false
                    dismissRomanticInterests = ruleData["dismiss_romantic_interests"] as? Bool ?? false
                    avoidOneOnOne = ruleData["avoid_one_on_one"] as? Bool ?? false
                    spiritualDirectorName = ruleData["spiritual_director_name"] as? String ?? ""
                    seminaryName = ruleData["seminary_name"] as? String ?? ""
                    seminaryVisitDate = ruleData["seminary_visit_date"] as? String ?? ""
                    retreatName = ruleData["retreat_name"] as? String ?? ""
                    retreatDate = ruleData["retreat_date"] as? String ?? ""
                    
                    isLoading = false
                }
            } else {
                await MainActor.run {
                    isLoading = false
                }
            }
        } catch {
            print("Error loading Rule of Life: \(error)")
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

