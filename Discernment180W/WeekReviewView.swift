import SwiftUI
import CoreData
import Supabase

struct WeekReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var authViewModel: AuthViewModel
    @State var weekNumber: Int
    @State private var showingWeekPicker = false
    @State private var selectedWeek: Int = 1
    
    // Add state for planning ahead data
    @State private var showingPlanningAhead = false
    @State private var planningAheadData: PlanningAheadData?
    @State private var showingMyRule = false
    @State private var ruleOfLifeData: RuleOfLifeDisplayData?
    
    // Add parameter to track if opened from home page action
    let showSkipButton: Bool

    private let totalWeeks = 13
    
    @State private var prayerDays: Int = 3
    @State private var liturgyOfTheHoursDays: Int = 1
    @State private var sleptHoursDays: Int = 1
    @State private var isMassCommitted: Bool = false
    @State private var isConfessionCommitted: Bool = false
    @State var prayerNotes: String = ""
    @State var prayerAdjustmentsNotes: String = ""
    @State var sacramentNotes: String = ""
    @State var virtueNotes: String = ""
    @State var virtueAdjustmentsNotes: String = ""
    @State var studyNotes: String = ""
    @State var studyAdjustmentsNotes: String = ""
    @State var serviceNotes: String = ""
    @State var serviceAdjustmentsNotes: String = ""
    @State private var meditationReadingDate = Date()
    
    @State var sacramentAdjustmentsNotes: String = ""
    @State private var isLoading: Bool = false
    @State var bodilyFastDays: [Bool] = Array(repeating: false, count: 7)
    @State var digitalFastDays: [Bool] = Array(repeating: false, count: 7)
    @State private var isdatingFastCommitted: Bool? = nil

    @State var hmeCommitment: Bool? = nil
    @State private var worksMercy: Bool? = nil
    @State private var corporalMercy: Bool? = nil
    @State private var spiritualReading: Bool? = nil
    
    @State var massDays: [Bool] = Array(repeating: false, count: 7)
    @State var lotrDays: [Bool] = Array(repeating: false, count: 7)
    @State var sleepDays: [Bool] = Array(repeating: false, count: 7)
    
    @State private var confessionDay: Int? = nil
    @State private var isAltarServiceScheduled: Bool? = nil
    @State var altarServingCommitment: Bool? = nil
    @State var spiritualMercyCommitment: Bool? = nil
    @State var corporalMercyCommitment: Bool? = nil
    @State var spiritualReadingCommitment: Bool? = nil

    @State var dailyMassCommitment: Bool? = nil
    @State var datingFastCommitment: Bool? = nil

    @State var regularConfession: Bool? = nil
    
    @State private var isSpiritualMercyScheduled: Bool? = nil
    @State private var isCorporalMercyScheduled: Bool? = nil
    @State private var scheduleNotes: String = ""
    @State private var isSpiritualDirectionScheduled: Bool? = nil
    @State private var isSeminaryVisitScheduled: Bool? = nil
    @State private var isDiscernmentRetreatScheduled: Bool? = nil
    @State private var notGoingToConfession: Bool? = nil
    @State private var weeklyHighlight = ""
    @State private var weeklyChallenge = ""
    @State private var weeklyLesson = ""
    @State private var showingSaveConfirmation = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var massScheduledDays: [Bool] = Array(repeating: false, count: 7)
    @State private var confessionScheduledDays: [Bool] = Array(repeating: false, count: 7)
    @State private var currentWeek: Int = 0
    @State private var isReviewSaved = false
    @State private var isSaving = false
    @State private var isSkipping = false
    
    init(weekNumber: Int, showSkipButton: Bool = false) {
        self.weekNumber = weekNumber
        self.showSkipButton = showSkipButton
        self._selectedWeek = State(initialValue: weekNumber)
    }

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
                
                Text("Rule")
                    .font(.custom("Georgia", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                // Invisible placeholder to balance the back button
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                    Text("Back")
                        .font(.system(size: 17, weight: .medium))
                }
                .opacity(0)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGroupedBackground))
            
            // Progress Bar and Week Navigation
            VStack(spacing: 12) {
                // Progress Bar with inline completion badge
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .center) {
                        Text("Progress")
                            .font(.custom("Georgia", size: 15))
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(weekNumber) of \(totalWeeks) weeks")
                            .font(.custom("Georgia", size: 15))
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    HStack(alignment: .center, spacing: 8) {
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 10)
                                
                                // Progress fill
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue, Color.blue.opacity(0.9)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * CGFloat(weekNumber) / CGFloat(totalWeeks), height: 10)
                                    .shadow(color: Color.blue.opacity(0.3), radius: 2, x: 0, y: 1)
                                    .animation(.easeInOut(duration: 0.3), value: weekNumber)
                            }
                        }
                        .frame(height: 10)
                        
                        // Completion badge inline with progress bar
                        HStack(spacing: 3) {
                            Image(systemName: isReviewSaved ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(isReviewSaved ? .green : .gray)
                                .font(.system(size: 14))
                            Text(isReviewSaved ? "Done" : "")
                                .font(.custom("Georgia", size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(isReviewSaved ? .green : .gray)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isReviewSaved ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 2)
                
                // My Rule Section (moved above)
                if ruleOfLifeData != nil {
                    Button(action: {
                        withAnimation {
                            showingMyRule.toggle()
                        }
                    }) {
                        HStack {
                            Text("My Rule")
                                .font(.custom("Georgia", size: 15))
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: showingMyRule ? "chevron.up" : "chevron.down")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                    }
                    .padding(.horizontal, 16)
                }
                
                // My Rule content (shown when expanded) - RIGHT AFTER MY RULE BUTTON
                if showingMyRule, let ruleData = ruleOfLifeData {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("My Personal Rule of Life")
                                .font(.custom("Georgia", size: 18))
                                .fontWeight(.bold)
                            
                            // Prayer Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Prayer")
                                    .font(.custom("Georgia", size: 16))
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                if !ruleData.prayerMinutes.isEmpty {
                                    Text("• I will pray for \(ruleData.prayerMinutes) minutes every day")
                                        .font(.custom("Georgia", size: 14))
                                }
                                
                                if !ruleData.prayerTimeFrom.isEmpty && !ruleData.prayerTimeTo.isEmpty {
                                    Text("• Prayer time: \(ruleData.prayerTimeFrom) to \(ruleData.prayerTimeTo)")
                                        .font(.custom("Georgia", size: 14))
                                }
                                
                                if !ruleData.wakeUpTime.isEmpty && !ruleData.bedTime.isEmpty {
                                    Text("• Wake up: \(ruleData.wakeUpTime), Bedtime: \(ruleData.bedTime)")
                                        .font(.custom("Georgia", size: 14))
                                }
                                
                                if !ruleData.additionalHours.isEmpty {
                                    Text("• Additional prayers: \(ruleData.additionalHours)")
                                        .font(.custom("Georgia", size: 14))
                                }
                                
                                Text("• I will pray Night Prayer every night")
                                    .font(.custom("Georgia", size: 14))
                            }
                            .padding(.bottom, 8)
                            
                            // Sacraments Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Sacraments")
                                    .font(.custom("Georgia", size: 16))
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                if !ruleData.massTimesPerWeek.isEmpty {
                                    Text("• Mass \(ruleData.massTimesPerWeek) times per week")
                                        .font(.custom("Georgia", size: 14))
                                }
                                
                                if !ruleData.additionalMassDays.isEmpty {
                                    Text("• Additional Mass days: \(ruleData.additionalMassDays)")
                                        .font(.custom("Georgia", size: 14))
                                }
                                
                                if !ruleData.confessionTimesPerMonth.isEmpty {
                                    Text("• Confession \(ruleData.confessionTimesPerMonth) times per month")
                                        .font(.custom("Georgia", size: 14))
                                }
                            }
                            .padding(.bottom, 8)
                            
                            // Virtue Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Virtue")
                                    .font(.custom("Georgia", size: 16))
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                if !ruleData.digitalFast.isEmpty {
                                    Text("• Digital fast: \(ruleData.digitalFast)")
                                        .font(.custom("Georgia", size: 14))
                                }
                                
                                if !ruleData.bodilyFast.isEmpty {
                                    Text("• Bodily fast: \(ruleData.bodilyFast)")
                                        .font(.custom("Georgia", size: 14))
                                }
                                
                                if !ruleData.chastityPractices.isEmpty {
                                    Text("• Chastity practices: \(ruleData.chastityPractices)")
                                        .font(.custom("Georgia", size: 14))
                                }
                            }
                            .padding(.bottom, 8)
                            
                            // Service Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Service")
                                    .font(.custom("Georgia", size: 16))
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                if !ruleData.altarServerParish.isEmpty {
                                    Text("• Altar server at: \(ruleData.altarServerParish)")
                                        .font(.custom("Georgia", size: 14))
                                }
                                
                                if !ruleData.spiritualWorkOfMercy.isEmpty {
                                    Text("• Spiritual work of mercy: \(ruleData.spiritualWorkOfMercy)")
                                        .font(.custom("Georgia", size: 14))
                                }
                                
                                if !ruleData.corporalWorkOfMercy.isEmpty {
                                    Text("• Corporal work of mercy: \(ruleData.corporalWorkOfMercy)")
                                        .font(.custom("Georgia", size: 14))
                                }
                            }
                            .padding(.bottom, 8)
                            
                            // Study Section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Study")
                                    .font(.custom("Georgia", size: 16))
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                if !ruleData.readingMinutesPerDay.isEmpty && !ruleData.readingDaysPerWeek.isEmpty {
                                    Text("• Spiritual reading: \(ruleData.readingMinutesPerDay) minutes/day, \(ruleData.readingDaysPerWeek) days/week")
                                        .font(.custom("Georgia", size: 14))
                                }
                            }
                            .padding(.bottom, 8)
                            
                            // Specific Discernment Actions
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Specific Discernment Actions")
                                    .font(.custom("Georgia", size: 16))
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                // Dating Fast
                                if ruleData.datingFastCommitment || ruleData.dismissRomanticInterests || ruleData.avoidOneOnOne {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Dating Fast (180 days):")
                                            .font(.custom("Georgia", size: 14))
                                            .fontWeight(.medium)
                                        
                                        if ruleData.datingFastCommitment {
                                            HStack {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                    .font(.system(size: 12))
                                                Text("Relate to women as a priest would")
                                                    .font(.custom("Georgia", size: 13))
                                            }
                                        }
                                        
                                        if ruleData.dismissRomanticInterests {
                                            HStack {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                    .font(.system(size: 12))
                                                Text("Dismiss romantic interests")
                                                    .font(.custom("Georgia", size: 13))
                                            }
                                        }
                                        
                                        if ruleData.avoidOneOnOne {
                                            HStack {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                    .font(.system(size: 12))
                                                Text("Avoid one-on-one settings with women")
                                                    .font(.custom("Georgia", size: 13))
                                            }
                                        }
                                    }
                                }
                                
                                // Spiritual Direction
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("• Monthly spiritual direction")
                                        .font(.custom("Georgia", size: 14))
                                    
                                    if !ruleData.spiritualDirectorName.isEmpty {
                                        Text("  Director: \(ruleData.spiritualDirectorName)")
                                            .font(.custom("Georgia", size: 13))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                // Seminary Visit
                                if !ruleData.seminaryName.isEmpty || !ruleData.seminaryVisitDate.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        if !ruleData.seminaryName.isEmpty {
                                            Text("• Seminary visit: \(ruleData.seminaryName)")
                                                .font(.custom("Georgia", size: 14))
                                        }
                                        if !ruleData.seminaryVisitDate.isEmpty {
                                            Text("  Date: \(ruleData.seminaryVisitDate)")
                                                .font(.custom("Georgia", size: 13))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                
                                // Retreat
                                if !ruleData.retreatName.isEmpty || !ruleData.retreatDate.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        if !ruleData.retreatName.isEmpty {
                                            Text("• Retreat: \(ruleData.retreatName)")
                                                .font(.custom("Georgia", size: 14))
                                        }
                                        if !ruleData.retreatDate.isEmpty {
                                            Text("  Date: \(ruleData.retreatDate)")
                                                .font(.custom("Georgia", size: 13))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 400)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.horizontal, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // Week Review Text (between My Rule and Navigate to Week)
                Text("Week \(weekNumber) Review")
                    .font(.custom("Georgia", size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                
                // Week Navigation Dropdown
                Button(action: {
                    withAnimation {
                        showingWeekPicker.toggle()
                    }
                }) {
                    HStack {
                        Text("Navigate to Week")
                            .font(.custom("Georgia", size: 15))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("Week \(weekNumber)")
                                .font(.custom("Georgia", size: 15))
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                            
                            Image(systemName: showingWeekPicker ? "chevron.up" : "chevron.down")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    )
                }
                .padding(.horizontal, 16)
                
                // Week Picker (shown when dropdown is tapped)
                if showingWeekPicker {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(1...totalWeeks, id: \.self) { week in
                                Button(action: {
                                    saveCurrentDataBeforeNavigating {
                                        clearAllFormData()
                                        weekNumber = week
                                        selectedWeek = week
                                        showingWeekPicker = false
                                        isReviewSaved = false
                                        
                                        Task {
                                            await fetchPrayerDays()
                                            await fetchPlanningAheadData()
                                            await fetchRuleOfLife()
                                        }
                                    }
                                }) {
                                    HStack {
                                        Text("Week \(week)")
                                            .font(.custom("Georgia", size: 15))
                                            .foregroundColor(week == weekNumber ? .white : .primary)
                                        
                                        Spacer()
                                        
                                        if week == weekNumber {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 13, weight: .medium))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(week == weekNumber ? Color.blue : Color.clear)
                                }
                                
                                if week < totalWeeks {
                                    Divider()
                                        .padding(.leading, 14)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                    }
                    .frame(maxHeight: 180)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // Planning Ahead Section (standalone)
                if planningAheadData != nil {
                    Button(action: {
                        withAnimation {
                            showingPlanningAhead.toggle()
                        }
                    }) {
                        HStack {
                            Text("Planning Ahead")
                                .font(.custom("Georgia", size: 15))
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: showingPlanningAhead ? "chevron.up" : "chevron.down")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                    }
                    .padding(.horizontal, 16)
                }
                
                // Planning Ahead content (shown when expanded)
                if showingPlanningAhead, let planData = planningAheadData {
                    VStack(alignment: .leading, spacing: 16) {
                        // Mass Scheduled Days
                        if planData.massScheduledDays.contains(true) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Mass Scheduled Days:")
                                    .font(.custom("Georgia", size: 16))
                                    .fontWeight(.semibold)
                                
                                HStack {
                                    ForEach(0..<7) { index in
                                        if planData.massScheduledDays[index] {
                                            Text(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][index])
                                                .font(.custom("Georgia", size: 14))
                                                .foregroundColor(.white)
                                                .padding(.vertical, 4)
                                                .padding(.horizontal, 8)
                                                .background(Color.blue)
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Confession Scheduled Days
                        if planData.confessionScheduledDays.contains(true) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confession Scheduled Days:")
                                    .font(.custom("Georgia", size: 16))
                                    .fontWeight(.semibold)
                                
                                HStack {
                                    ForEach(0..<7) { index in
                                        if planData.confessionScheduledDays[index] {
                                            Text(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][index])
                                                .font(.custom("Georgia", size: 14))
                                                .foregroundColor(.white)
                                                .padding(.vertical, 4)
                                                .padding(.horizontal, 8)
                                                .background(Color.purple)
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Other scheduled items
                        VStack(alignment: .leading, spacing: 6) {
                            if planData.altarServiceScheduled == true {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                    Text("Altar Service Scheduled")
                                        .font(.custom("Georgia", size: 14))
                                }
                            }
                            
                            if planData.spiritualMercyScheduled == true {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                    Text("Spiritual Works of Mercy Scheduled")
                                        .font(.custom("Georgia", size: 14))
                                }
                            }
                            
                            if planData.corporalMercyScheduled == true {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                    Text("Corporal Works of Mercy Scheduled")
                                        .font(.custom("Georgia", size: 14))
                                }
                            }
                            
                            if planData.spiritualDirectionScheduled == true {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                    Text("Spiritual Direction Scheduled")
                                        .font(.custom("Georgia", size: 14))
                                }
                            }
                            
                            if planData.seminaryVisitScheduled == true {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                    Text("Seminary Visit Scheduled")
                                        .font(.custom("Georgia", size: 14))
                                }
                            }
                            
                            if planData.discernmentRetreatScheduled == true {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                    Text("Discernment Retreat Scheduled")
                                        .font(.custom("Georgia", size: 14))
                                }
                            }
                        }
                        
                        // Schedule Notes
                        if !planData.scheduleNotes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Schedule Notes:")
                                    .font(.custom("Georgia", size: 16))
                                    .fontWeight(.semibold)
                                
                                Text(planData.scheduleNotes)
                                    .font(.custom("Georgia", size: 14))
                                    .foregroundColor(.secondary)
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.horizontal, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.vertical, 12)
            .background(Color(.systemGroupedBackground))
            
            // Scrollable content
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 15) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            sectionView(title: "Prayer")
                            sectionView(title: "Sacraments", isMassSection: true)
                            sectionView(title: "Virtue", isVirtueSection: true)
                            sectionView(title: "Service", isServiceSection: true)
                            sectionView(title: "Study", isStudySection: true)
                        }
                        .padding(.top, 8)
                    }
                    
                    // Updated button section with consistent heights
                    HStack(spacing: 12) {
                        // Skip button - only show when opened from home page
                        if showSkipButton {
                            Button(action: {
                                guard !isSkipping else { return }
                                skipWeeklyReview()
                            }) {
                                HStack {
                                    if isSkipping {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .foregroundColor(.primary)
                                    }
                                    Text(isSkipping ? "Skipping..." : "Skip")
                                        .font(.custom("Georgia", size: 18))
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(.systemGray5))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color(.systemGray3), lineWidth: 1)
                                )
                            }
                            .disabled(isSkipping || isSaving)
                        }
                        
                        // Save button
                        Button(action: {
                            guard !isSaving else { return }
                            saveWeeklyReview()
                        }) {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                }
                                Text(isSaving ? "Saving..." : "Save Weekly Review")
                                    .font(.custom("Georgia", size: 18))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(isSaving || isSkipping ? Color.gray : Color.blue)
                            .cornerRadius(10)
                        }
                        .disabled(isSaving || isSkipping)
                    }
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
            selectedWeek = weekNumber
            Task {
                await fetchPrayerDays()
                await fetchPlanningAheadData()
                await fetchRuleOfLife()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Success", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) {
                navigateToHome()
            }
        } message: {
            Text("Your weekly review has been saved.")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // NEW: Function to fetch Rule of Life data
    private func fetchRuleOfLife() async {
        guard !authViewModel.userId.isEmpty else {
            print("❌ No user ID available for fetching Rule of Life")
            return
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
                    self.ruleOfLifeData = RuleOfLifeDisplayData(
                        prayerMinutes: ruleData["prayer_minutes"] as? String ?? "",
                        prayerTimeFrom: ruleData["prayer_time_from"] as? String ?? "",
                        prayerTimeTo: ruleData["prayer_time_to"] as? String ?? "",
                        wakeUpTime: ruleData["wake_up_time"] as? String ?? "",
                        bedTime: ruleData["bed_time"] as? String ?? "",
                        additionalHours: ruleData["additional_hours"] as? String ?? "",
                        massTimesPerWeek: ruleData["mass_times_per_week"] as? String ?? "",
                        additionalMassDays: ruleData["additional_mass_days"] as? String ?? "",
                        confessionTimesPerMonth: ruleData["confession_times_per_month"] as? String ?? "",
                        digitalFast: ruleData["digital_fast"] as? String ?? "",
                        bodilyFast: ruleData["bodily_fast"] as? String ?? "",
                        chastityPractices: ruleData["chastity_practices"] as? String ?? "",
                        altarServerParish: ruleData["altar_server_parish"] as? String ?? "",
                        spiritualWorkOfMercy: ruleData["spiritual_work_of_mercy"] as? String ?? "",
                        corporalWorkOfMercy: ruleData["corporal_work_of_mercy"] as? String ?? "",
                        readingMinutesPerDay: ruleData["reading_minutes_per_day"] as? String ?? "",
                        readingDaysPerWeek: ruleData["reading_days_per_week"] as? String ?? "",
                        datingFastCommitment: ruleData["dating_fast_commitment"] as? Bool ?? false,
                        dismissRomanticInterests: ruleData["dismiss_romantic_interests"] as? Bool ?? false,
                        avoidOneOnOne: ruleData["avoid_one_on_one"] as? Bool ?? false,
                        spiritualDirectorName: ruleData["spiritual_director_name"] as? String ?? "",
                        seminaryName: ruleData["seminary_name"] as? String ?? "",
                        seminaryVisitDate: ruleData["seminary_visit_date"] as? String ?? "",
                        retreatName: ruleData["retreat_name"] as? String ?? "",
                        retreatDate: ruleData["retreat_date"] as? String ?? ""
                    )
                }
            } else {
                await MainActor.run {
                    self.ruleOfLifeData = nil
                }
            }
        } catch {
            print("Error fetching Rule of Life: \(error)")
            await MainActor.run {
                self.ruleOfLifeData = nil
            }
        }
    }
    
    // Function to fetch planning ahead data
    private func fetchPlanningAheadData() async {
        guard !authViewModel.userId.isEmpty else {
            print("❌ No user ID available for fetching planning data")
            return
        }
        
        do {
            let response = try await SupabaseManager.shared.client
                .from("planning_ahead")
                .select("mass_scheduled_days, confession_scheduled_days, altar_service_scheduled, spiritual_mercy_scheduled, corporal_mercy_scheduled, spiritual_direction_scheduled, seminary_visit_scheduled, discernment_retreat_scheduled, schedule_notes")
                .eq("user_id", value: authViewModel.userId)
                .eq("week_number", value: String(weekNumber))
                .order("created_at", ascending: false)
                .limit(1)
                .execute()
            
            let jsonData = response.data
            
            if let dataArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
               !dataArray.isEmpty {
                let latestPlanning = dataArray[0]
                
                await MainActor.run {
                    // Parse mass scheduled days
                    var massScheduled = Array(repeating: false, count: 7)
                    if let massScheduledString = latestPlanning["mass_scheduled_days"] as? String,
                       let massScheduledData = massScheduledString.data(using: .utf8),
                       let massScheduledArray = try? JSONSerialization.jsonObject(with: massScheduledData) as? [String] {
                        let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                        for (index, dayName) in dayNames.enumerated() {
                            if massScheduledArray.contains(dayName) {
                                massScheduled[index] = true
                            }
                        }
                    }
                    
                    // Parse confession scheduled days
                    var confessionScheduled = Array(repeating: false, count: 7)
                    if let confessionScheduledString = latestPlanning["confession_scheduled_days"] as? String,
                       let confessionScheduledData = confessionScheduledString.data(using: .utf8),
                       let confessionScheduledArray = try? JSONSerialization.jsonObject(with: confessionScheduledData) as? [String] {
                        let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                        for (index, dayName) in dayNames.enumerated() {
                            if confessionScheduledArray.contains(dayName) {
                                confessionScheduled[index] = true
                            }
                        }
                    }
                    
                    // Parse boolean values
                    func parseBool(_ value: Any?) -> Bool? {
                        if let stringValue = value as? String {
                            return stringValue.lowercased() == "true"
                        }
                        return nil
                    }
                    
                    planningAheadData = PlanningAheadData(
                        massScheduledDays: massScheduled,
                        confessionScheduledDays: confessionScheduled,
                        altarServiceScheduled: parseBool(latestPlanning["altar_service_scheduled"]),
                        spiritualMercyScheduled: parseBool(latestPlanning["spiritual_mercy_scheduled"]),
                        corporalMercyScheduled: parseBool(latestPlanning["corporal_mercy_scheduled"]),
                        spiritualDirectionScheduled: parseBool(latestPlanning["spiritual_direction_scheduled"]),
                        seminaryVisitScheduled: parseBool(latestPlanning["seminary_visit_scheduled"]),
                        discernmentRetreatScheduled: parseBool(latestPlanning["discernment_retreat_scheduled"]),
                        scheduleNotes: latestPlanning["schedule_notes"] as? String ?? ""
                    )
                }
            } else {
                await MainActor.run {
                    planningAheadData = nil
                    showingPlanningAhead = false
                }
            }
        } catch {
            print("Error fetching planning ahead data: \(error)")
            await MainActor.run {
                planningAheadData = nil
                showingPlanningAhead = false
            }
        }
    }
    
    // Skip function that increments curriculum order without saving form
    private func skipWeeklyReview() {
        Task { @MainActor in
            isSkipping = true
            isLoading = true
        }
        
        Task {
            await incrementCurriculumOrderInDatabase(email: authViewModel.userEmail)
            await MainActor.run {
                isSkipping = false
                isLoading = false
                navigateToHome()
            }
        }
    }
    
    // Function to increment curriculum order
    private func incrementCurriculumOrderInDatabase(email: String) async {
        guard !email.isEmpty else {
            print("❌ No email provided for incrementing curriculum order")
            return
        }
        do {
            print("Starting increment for email: \(email)")
            
            let response = try await SupabaseManager.shared.client
                .from("users")
                .select("curriculum_order")
                .eq("email", value: email)
                .execute()
            
            if let dataArray = try? JSONSerialization.jsonObject(with: response.data) as? [[String: Any]],
               !dataArray.isEmpty,
               let userData = dataArray.first,
               let currentOrderString = userData["curriculum_order"] as? String,
               let currentOrderInt = Int(currentOrderString) {
                
                let newOrder = currentOrderInt + 1
                let newOrderString = String(newOrder)
                
                let updateResponse = try await SupabaseManager.shared.client
                    .from("users")
                    .update(["curriculum_order": newOrderString])
                    .eq("email", value: email)
                    .execute()
                
                print("✅ Successfully incremented curriculum_order from \(currentOrderString) to \(newOrderString)")
            }
        } catch {
            print("❌ Error incrementing curriculum_order: \(error)")
            await MainActor.run {
                errorMessage = "Error updating curriculum: \(error.localizedDescription)"
                showingErrorAlert = true
            }
        }
    }
    
    // Helper function to clear all form data
    private func clearAllFormData() {
        // Clear all boolean arrays
        massDays = Array(repeating: false, count: 7)
        lotrDays = Array(repeating: false, count: 7)
        sleepDays = Array(repeating: false, count: 7)
        bodilyFastDays = Array(repeating: false, count: 7)
        digitalFastDays = Array(repeating: false, count: 7)
        massScheduledDays = Array(repeating: false, count: 7)
        confessionScheduledDays = Array(repeating: false, count: 7)
        
        // Clear all text fields
        prayerNotes = ""
        prayerAdjustmentsNotes = ""
        sacramentNotes = ""
        sacramentAdjustmentsNotes = ""
        virtueNotes = ""
        virtueAdjustmentsNotes = ""
        serviceNotes = ""
        serviceAdjustmentsNotes = ""
        studyNotes = ""
        studyAdjustmentsNotes = ""
        scheduleNotes = ""
        weeklyHighlight = ""
        weeklyChallenge = ""
        weeklyLesson = ""
        
        // Clear all boolean commitments
        dailyMassCommitment = nil
        regularConfession = nil
        altarServingCommitment = nil
        spiritualMercyCommitment = nil
        corporalMercyCommitment = nil
        spiritualReadingCommitment = nil
        datingFastCommitment = nil
        hmeCommitment = nil
        isMassCommitted = false
        isConfessionCommitted = false
        isdatingFastCommitted = nil
        worksMercy = nil
        corporalMercy = nil
        spiritualReading = nil
        isAltarServiceScheduled = nil
        isSpiritualMercyScheduled = nil
        isCorporalMercyScheduled = nil
        isSpiritualDirectionScheduled = nil
        isSeminaryVisitScheduled = nil
        isDiscernmentRetreatScheduled = nil
        notGoingToConfession = nil
        
        // Clear numeric values
        prayerDays = 3
        liturgyOfTheHoursDays = 1
        sleptHoursDays = 1
        confessionDay = nil
        currentWeek = 0
        
        // Reset date
        meditationReadingDate = Date()
        
        // Clear planning ahead data
        planningAheadData = nil
        showingPlanningAhead = false
    }
    
    // Helper function to save current data before navigating
    private func saveCurrentDataBeforeNavigating(completion: @escaping () -> Void) {
        completion()
    }
    
    private func navigateToHome() {
        dismiss()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                
                var currentVC = window.rootViewController
                
                while currentVC != nil {
                    if let navController = currentVC as? UINavigationController {
                        navController.popToRootViewController(animated: true)
                        return
                    } else if let tabController = currentVC as? UITabBarController {
                        if let selectedNav = tabController.selectedViewController as? UINavigationController {
                            selectedNav.popToRootViewController(animated: true)
                            return
                        }
                    } else if let presented = currentVC?.presentedViewController {
                        currentVC = presented
                    } else if let children = currentVC?.children, !children.isEmpty {
                        currentVC = children.first
                    } else {
                        break
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootNav = window.rootViewController as? UINavigationController {
                    rootNav.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    // The sectionView and loremIpsumText functions are now in WeekReviewSections.swift extension
    
    private func saveWeeklyReview() {
        guard !isSaving else { return }
        guard !authViewModel.userId.isEmpty else {
            print("❌ No user ID available for saving review")
            return
        }
        Task { @MainActor in
            isSaving = true
            isLoading = true
        }
        
        Task {
            do {
                let dateFormatter = ISO8601DateFormatter()
                let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                
                // Convert boolean arrays to arrays of day names
                let massDaysNames = massDays.enumerated()
                    .filter { $0.element }
                    .map { dayNames[$0.offset] }
                
                let lotrDaysNames = lotrDays.enumerated()
                    .filter { $0.element }
                    .map { dayNames[$0.offset] }
                
                let sleepDaysNames = sleepDays.enumerated()
                    .filter { $0.element }
                    .map { dayNames[$0.offset] }
                
                let bodilyFastDaysNames = bodilyFastDays.enumerated()
                    .filter { $0.element }
                    .map { dayNames[$0.offset] }
                
                let digitalFastDaysNames = digitalFastDays.enumerated()
                    .filter { $0.element }
                    .map { dayNames[$0.offset] }
                
                // Convert arrays to JSON strings for Supabase storage
                let massDaysJSON = try JSONSerialization.data(withJSONObject: massDaysNames)
                let massDaysString = String(data: massDaysJSON, encoding: .utf8) ?? "[]"
                
                let lotrDaysJSON = try JSONSerialization.data(withJSONObject: lotrDaysNames)
                let lotrDaysString = String(data: lotrDaysJSON, encoding: .utf8) ?? "[]"
                
                let sleepDaysJSON = try JSONSerialization.data(withJSONObject: sleepDaysNames)
                let sleepDaysString = String(data: sleepDaysJSON, encoding: .utf8) ?? "[]"
                
                let bodilyFastDaysJSON = try JSONSerialization.data(withJSONObject: bodilyFastDaysNames)
                let bodilyFastDaysString = String(data: bodilyFastDaysJSON, encoding: .utf8) ?? "[]"
                
                let digitalFastDaysJSON = try JSONSerialization.data(withJSONObject: digitalFastDaysNames)
                let digitalFastDaysString = String(data: digitalFastDaysJSON, encoding: .utf8) ?? "[]"
                
                // Build the payload
                var payload: [String: String] = [
                    "created_at": dateFormatter.string(from: Date()),
                    "user_id": authViewModel.userId,
                    "prayer_days": massDaysString,
                    "week_number": String(weekNumber),
                    "liturgy_of_the_hours_days": lotrDaysString,
                    "slept_hours_days": sleepDaysString,
                    "prayer_notes": prayerNotes,
                    "prayer_adjustments_notes": prayerAdjustmentsNotes,
                    "sacrament_notes": sacramentNotes,
                    "sacrament_adjustments_notes": sacramentAdjustmentsNotes,
                    "virtue_notes": virtueNotes,
                    "virtue_adjustments_notes": virtueAdjustmentsNotes,
                    "service_notes": serviceNotes,
                    "service_adjustments_notes": serviceAdjustmentsNotes,
                    "study_notes": studyNotes,
                    "study_adjustments_notes": studyAdjustmentsNotes,
                    "bodily_fast_days": bodilyFastDaysString,
                    "digital_fast_days": digitalFastDaysString
                ]
                
                // Add optional booleans
                if let value = dailyMassCommitment {
                    payload["daily_mass_commitment"] = value ? "true" : "false"
                }
                
                if let value = regularConfession {
                    payload["regular_confession"] = value ? "true" : "false"
                }
                
                if let value = altarServingCommitment {
                    payload["altar_serving_commitment"] = value ? "true" : "false"
                }
                
                if let value = spiritualMercyCommitment {
                    payload["spiritual_mercy_commitment"] = value ? "true" : "false"
                }
                
                if let value = corporalMercyCommitment {
                    payload["corporal_mercy_commitment"] = value ? "true" : "false"
                }
                
                if let value = spiritualReadingCommitment {
                    payload["spiritual_reading_commitment"] = value ? "true" : "false"
                }
                
                if let value = datingFastCommitment {
                    payload["dating_fast_commitment"] = value ? "true" : "false"
                }
                
                if let value = hmeCommitment {
                    payload["hme_commitment"] = value ? "true" : "false"
                }
                
                // Check if record exists
                let response = try await SupabaseManager.shared.client
                    .from("WeekReview")
                    .select("id")
                    .eq("user_id", value: authViewModel.userId)
                    .eq("week_number", value: String(weekNumber))
                    .execute()
                
                let jsonData = response.data
                
                if let dataArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
                   !dataArray.isEmpty,
                   let existingId = dataArray[0]["id"] as? Int {
                    
                    // Update existing record
                    try await SupabaseManager.shared.client
                        .from("WeekReview")
                        .update(payload)
                        .eq("id", value: String(existingId))
                        .execute()
                } else {
                    // Insert new record
                    try await SupabaseManager.shared.client
                        .from("WeekReview")
                        .insert(payload)
                        .execute()
                }
                
                await MainActor.run {
                    isSaving = false
                    isLoading = false
                    showingSaveConfirmation = true
                    isReviewSaved = true
                }
                
            } catch {
                await MainActor.run {
                    isSaving = false
                    isLoading = false
                    errorMessage = "Error saving review: \(error.localizedDescription)"
                    showingErrorAlert = true
                }
            }
        }
    }
    
    func fetchPrayerDays() async {
        guard !authViewModel.userId.isEmpty else {
            print("❌ No user ID available for fetching prayer days")
            return
        }
        do {
            await MainActor.run {
                isLoading = true
            }
            
            let response = try await SupabaseManager.shared.client
                .from("WeekReview")
                .select("prayer_days, liturgy_of_the_hours_days, slept_hours_days, prayer_notes, prayer_adjustments_notes, sacrament_notes, sacrament_adjustments_notes, virtue_notes, virtue_adjustments_notes, service_notes, service_adjustments_notes, study_notes, study_adjustments_notes, daily_mass_commitment, regular_confession, bodily_fast_days, digital_fast_days, dating_fast_commitment, hme_commitment, altar_serving_commitment, spiritual_mercy_commitment, corporal_mercy_commitment, spiritual_reading_commitment")
                .eq("user_id", value: authViewModel.userId)
                .eq("week_number", value: String(weekNumber))
                .order("created_at", ascending: false)
                .limit(1)
                .execute()
            
            let jsonData = response.data
            
            if let dataArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
               !dataArray.isEmpty {
                let latestReview = dataArray[0]
                await processPrayerAndLiturgyData(latestReview)
                
                // Check if review has been saved (has all required fields)
                await MainActor.run {
                    // Consider it saved if we have any notes or commitments
                    if !prayerNotes.isEmpty || !prayerAdjustmentsNotes.isEmpty ||
                       !sacramentNotes.isEmpty || !sacramentAdjustmentsNotes.isEmpty ||
                       !virtueNotes.isEmpty || !virtueAdjustmentsNotes.isEmpty ||
                       !serviceNotes.isEmpty || !serviceAdjustmentsNotes.isEmpty ||
                       !studyNotes.isEmpty || !studyAdjustmentsNotes.isEmpty ||
                       massDays.contains(true) || lotrDays.contains(true) ||
                       sleepDays.contains(true) || bodilyFastDays.contains(true) ||
                       digitalFastDays.contains(true) {
                        isReviewSaved = true
                    } else {
                        isReviewSaved = false
                    }
                }
            } else {
                // NO DATA FOUND - Initialize empty state
                await MainActor.run {
                    clearAllFormData()
                    isReviewSaved = false
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                clearAllFormData()
                isReviewSaved = false
                isLoading = false
            }
            print("Error fetching prayer days: \(error)")
        }
    }
    
    @MainActor
    private func processPrayerAndLiturgyData(_ reviewData: [String: Any]) {
        func parseDaysArray(_ jsonString: String?) -> [Bool] {
            let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            var boolArray = Array(repeating: false, count: 7)
            
            guard let jsonString = jsonString,
                  let jsonData = jsonString.data(using: .utf8),
                  let dayArray = try? JSONSerialization.jsonObject(with: jsonData) as? [String] else {
                return Array(repeating: false, count: 7)
            }
            
            for (index, dayName) in dayNames.enumerated() {
                if dayArray.contains(dayName) {
                    boolArray[index] = true
                }
            }
            
            return boolArray
        }
        
        // Process day arrays
        if let prayerDaysString = reviewData["prayer_days"] as? String {
            massDays = parseDaysArray(prayerDaysString)
        }
        
        if let lotrDaysString = reviewData["liturgy_of_the_hours_days"] as? String {
            lotrDays = parseDaysArray(lotrDaysString)
        }
        
        if let sleepDaysString = reviewData["slept_hours_days"] as? String {
            sleepDays = parseDaysArray(sleepDaysString)
        }
        
        if let bodilyFastDaysString = reviewData["bodily_fast_days"] as? String {
            bodilyFastDays = parseDaysArray(bodilyFastDaysString)
        }
        
        if let digitalFastDaysString = reviewData["digital_fast_days"] as? String {
            digitalFastDays = parseDaysArray(digitalFastDaysString)
        }
        
        // Process notes
        if let notes = reviewData["prayer_notes"] as? String {
            prayerNotes = notes
        }
        
        if let notes = reviewData["prayer_adjustments_notes"] as? String {
            prayerAdjustmentsNotes = notes
        }
        
        if let notes = reviewData["sacrament_notes"] as? String {
            sacramentNotes = notes
        }
        
        if let notes = reviewData["sacrament_adjustments_notes"] as? String {
            sacramentAdjustmentsNotes = notes
        }
        
        if let notes = reviewData["virtue_notes"] as? String {
            virtueNotes = notes
        }
        
        if let notes = reviewData["virtue_adjustments_notes"] as? String {
            virtueAdjustmentsNotes = notes
        }
        
        if let notes = reviewData["service_notes"] as? String {
            serviceNotes = notes
        }
        
        if let notes = reviewData["service_adjustments_notes"] as? String {
            serviceAdjustmentsNotes = notes
        }
        
        if let notes = reviewData["study_notes"] as? String {
            studyNotes = notes
        }
        
        if let notes = reviewData["study_adjustments_notes"] as? String {
            studyAdjustmentsNotes = notes
        }
        
        // Process boolean commitments
        if let commitmentString = reviewData["daily_mass_commitment"] as? String {
            dailyMassCommitment = commitmentString.lowercased() == "true" ? true : (commitmentString.lowercased() == "false" ? false : nil)
        }
        
        if let commitmentString = reviewData["regular_confession"] as? String {
            regularConfession = commitmentString.lowercased() == "true" ? true : (commitmentString.lowercased() == "false" ? false : nil)
        }
        
        if let commitmentString = reviewData["altar_serving_commitment"] as? String {
            altarServingCommitment = commitmentString.lowercased() == "true" ? true : (commitmentString.lowercased() == "false" ? false : nil)
        }
        
        if let commitmentString = reviewData["spiritual_mercy_commitment"] as? String {
            spiritualMercyCommitment = commitmentString.lowercased() == "true" ? true : (commitmentString.lowercased() == "false" ? false : nil)
        }
        
        if let commitmentString = reviewData["corporal_mercy_commitment"] as? String {
            corporalMercyCommitment = commitmentString.lowercased() == "true" ? true : (commitmentString.lowercased() == "false" ? false : nil)
        }
        
        if let commitmentString = reviewData["spiritual_reading_commitment"] as? String {
            spiritualReadingCommitment = commitmentString.lowercased() == "true" ? true : (commitmentString.lowercased() == "false" ? false : nil)
        }
        
        if let commitmentString = reviewData["dating_fast_commitment"] as? String {
            datingFastCommitment = commitmentString.lowercased() == "true" ? true : (commitmentString.lowercased() == "false" ? false : nil)
        }
        
        if let commitmentString = reviewData["hme_commitment"] as? String {
            hmeCommitment = commitmentString.lowercased() == "true" ? true : (commitmentString.lowercased() == "false" ? false : nil)
        }
        
        isLoading = false
    }
    
}

struct WeekReviewView_Previews: PreviewProvider {
    static var previews: some View {
        WeekReviewView(weekNumber: 1)
    }
}
