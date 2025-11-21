import SwiftUI
import CoreData
import Supabase
import Combine

struct WeekReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authViewModel: AuthViewModel
    @State var weekNumber: Int
    @State private var showingWeekPicker = false
    @State private var selectedWeek: Int = 1
    @State private var keyboardHeight: CGFloat = 0
    
    // Add state for planning ahead data
    @State private var showingPlanningAhead = false
    @State private var planningAheadData: PlanningAheadData?
    @State private var showingMyRule = false
    @State private var ruleOfLifeData: RuleOfLifeDisplayData?
    
    // Add parameter to track if opened from home page action
    let showSkipButton: Bool

    private let totalWeeks = 26
    
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
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case prayerNotes
        case prayerAdjustments
        case sacramentNotes
        case sacramentAdjustments
        case virtueNotes
        case virtueAdjustments
        case studyNotes
        case studyAdjustments
        case serviceNotes
        case serviceAdjustments
        case weeklyHighlight
        case weeklyChallenge
        case weeklyLesson
    }
    
    init(weekNumber: Int, showSkipButton: Bool = false) {
        self.weekNumber = weekNumber
        self.showSkipButton = showSkipButton
        self._selectedWeek = State(initialValue: weekNumber)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Fixed header with back button
            HStack {
                // Back button
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                        Text("Home")
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
                .frame(minWidth: 80, alignment: .leading)
                
                Spacer()
                
                // Centered "Rule" text
                Text("Rule")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                // Completion badge aligned to the right
                HStack(spacing: 3) {
                    Image(systemName: isReviewSaved ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isReviewSaved ? .green : .gray)
                        .font(.system(size: 16))
                    Text(isReviewSaved ? "Done" : "")
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(isReviewSaved ? .green : .gray)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isReviewSaved ? Color.green.opacity(0.1) : Color.clear)
                )
                .frame(minWidth: 80, alignment: .trailing)
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
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("\(weekNumber) of \(totalWeeks) weeks")
                            .font(.system(size: 15))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
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
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 2)
                
                // My Rule Section (moved above) - Always visible now
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showingMyRule.toggle()
                    }
                }) {
                    HStack(spacing: 12) {
                        // Icon to indicate expandable content
                        Image(systemName: showingMyRule ? "doc.text.fill" : "doc.text")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("My Rule")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .lineLimit(1)

                            Text(showingMyRule ? "Tap to collapse" : "Tap to view your commitments")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        // Animated expand/collapse indicator
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(showingMyRule ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                .frame(width: 32, height: 32)

                            Image(systemName: showingMyRule ? "minus" : "plus")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(showingMyRule ? .blue : .gray)
                                .rotationEffect(.degrees(showingMyRule ? 0 : 0))
                                .animation(.easeInOut(duration: 0.2), value: showingMyRule)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(showingMyRule ? Color.blue.opacity(0.05) : Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(showingMyRule ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: showingMyRule ? Color.blue.opacity(0.1) : Color.black.opacity(0.05),
                                   radius: showingMyRule ? 4 : 2,
                                   x: 0,
                                   y: showingMyRule ? 2 : 1)
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, showingMyRule ? 70 : 0) // Add top padding only when expanded
                
                // My Rule content (shown when expanded) - EXTENDS TO 80% OF PAGE
                if showingMyRule && focusedField == nil {
                    // Form content that extends to 80% of screen height
                    GeometryReader { geometry in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                RuleOfLifeEmbeddedView()
                            }
                            .padding(.vertical, 16)
                        }
                        .frame(minHeight: geometry.size.height * 0.8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        )
                    }
                    .frame(minHeight: UIScreen.main.bounds.height * 0.8)
                    .padding(.horizontal, 16)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                    .zIndex(1) // Ensure it appears above other content
                }
                
                // Week Review Text (between My Rule and Navigate to Week)
                Text("Week \(weekNumber) Review")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
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
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("Week \(weekNumber)")
                                .font(.system(size: 15))
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
                if showingWeekPicker && focusedField == nil {
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
                                            .font(.system(size: 15))
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
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                                .foregroundColor(.black)
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
                if showingPlanningAhead && focusedField == nil, let planData = planningAheadData {
                    VStack(alignment: .leading, spacing: 16) {
                        // Mass Scheduled Days
                        if planData.massScheduledDays.contains(true) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Mass Scheduled Days:")
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                
                                HStack {
                                    ForEach(0..<7) { index in
                                        if planData.massScheduledDays[index] {
                                            Text(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][index])
                                                .font(.system(size: 14))
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
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                
                                HStack {
                                    ForEach(0..<7) { index in
                                        if planData.confessionScheduledDays[index] {
                                            Text(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][index])
                                                .font(.system(size: 14))
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
                                        .font(.system(size: 14))
                                }
                            }
                            
                            if planData.spiritualMercyScheduled == true {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                    Text("Spiritual Works of Mercy Scheduled")
                                        .font(.system(size: 14))
                                }
                            }
                            
                            if planData.corporalMercyScheduled == true {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                    Text("Corporal Works of Mercy Scheduled")
                                        .font(.system(size: 14))
                                }
                            }
                            
                            if planData.spiritualDirectionScheduled == true {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                    Text("Spiritual Direction Scheduled")
                                        .font(.system(size: 14))
                                }
                            }
                            
                            if planData.seminaryVisitScheduled == true {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                    Text("Seminary Visit Scheduled")
                                        .font(.system(size: 14))
                                }
                            }
                            
                            if planData.discernmentRetreatScheduled == true {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 14))
                                    Text("Discernment Retreat Scheduled")
                                        .font(.system(size: 14))
                                }
                            }
                        }
                        
                        // Schedule Notes
                        if !planData.scheduleNotes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Schedule Notes:")
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                
                                Text(planData.scheduleNotes)
                                    .font(.system(size: 14))
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
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                sectionView(title: "Prayer")
                                    .id("prayer")
                                sectionView(title: "Sacraments", isMassSection: true)
                                    .id("sacraments")
                                sectionView(title: "Virtue", isVirtueSection: true)
                                    .id("virtue")
                                sectionView(title: "Service", isServiceSection: true)
                                    .id("service")
                                sectionView(title: "Study", isStudySection: true)
                                    .id("study")
                                
                                // Dynamic padding at bottom based on keyboard height
                                Color.clear
                                    .frame(height: keyboardHeight > 0 ? keyboardHeight + 100 : 300)
                            }
                            .padding(.top, 8)
                        }
                        .onChange(of: focusedField) { newValue in
                            // Collapse dropdowns when keyboard appears
                            if newValue != nil {
                                showingMyRule = false
                                showingWeekPicker = false
                                showingPlanningAhead = false
                                
                                // Delay scrolling to allow keyboard to fully appear
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        // Scroll to the appropriate section with better positioning
                                        switch newValue {
                                        case .prayerNotes:
                                            scrollProxy.scrollTo("prayerNotesField", anchor: .top)
                                        case .prayerAdjustments:
                                            scrollProxy.scrollTo("prayerAdjustmentsField", anchor: .top)
                                        case .sacramentNotes:
                                            scrollProxy.scrollTo("sacramentNotesField", anchor: .top)
                                        case .sacramentAdjustments:
                                            scrollProxy.scrollTo("sacramentAdjustmentsField", anchor: .top)
                                        case .virtueNotes:
                                            scrollProxy.scrollTo("virtueNotesField", anchor: .top)
                                        case .virtueAdjustments:
                                            scrollProxy.scrollTo("virtueAdjustmentsField", anchor: .top)
                                        case .serviceNotes:
                                            scrollProxy.scrollTo("serviceNotesField", anchor: .top)
                                        case .serviceAdjustments:
                                            scrollProxy.scrollTo("serviceAdjustmentsField", anchor: .top)
                                        case .studyNotes:
                                            scrollProxy.scrollTo("studyNotesField", anchor: .top)
                                        case .studyAdjustments:
                                            scrollProxy.scrollTo("studyAdjustmentsField", anchor: .top)
                                        case .weeklyHighlight, .weeklyChallenge, .weeklyLesson:
                                            scrollProxy.scrollTo("study", anchor: .top)
                                        case .none:
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .keyboard) {
                            HStack {
                                Spacer()
                                Button("Done") {
                                    hideKeyboard()
                                    focusedField = nil
                                }
                                .font(.system(size: 16).weight(.semibold))
                                .foregroundColor(Color.blue)
                            }
                        }
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
                                            .foregroundColor(.black)
                                    }
                                    Text(isSkipping ? "Skipping..." : "Skip")
                                        .font(.system(size: 18))
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
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
                                    .font(.system(size: 18))
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
                        .background(Color(.systemBackground).opacity(0.8))
                        .cornerRadius(10)
                }
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            selectedWeek = weekNumber
            Task {
                await fetchPrayerDays()
                await fetchPlanningAheadData()
                await fetchRuleOfLife()
            }
            
            // Observe keyboard notifications
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    withAnimation(.easeOut(duration: 0.25)) {
                        keyboardHeight = keyboardFrame.height
                    }
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                withAnimation(.easeOut(duration: 0.25)) {
                    keyboardHeight = 0
                }
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
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
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

// Embedded version of Rule of Life form without navigation
struct RuleOfLifeEmbeddedView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Prayer fields
    @State private var prayerMinutes = ""
    @State private var prayerTimeFrom = ""
    @State private var prayerTimeTo = ""
    @State private var wakeUpTime = ""
    @State private var bedTime = ""
    @State private var additionalHours = ""
    @State private var prayerNotes1 = ""
    @State private var prayerNotes2 = ""
    
    // Hours of Prayer selection
    @State private var selectedHours = Set<String>()
    let hoursOfPrayer = [
        "Office of Readings",
        "Morning Prayer",
        "Daytime Prayers",
        "Evening Prayer"
    ]
    
    // Sacraments fields
    @State private var massTimesPerWeek = ""
    @State private var selectedMassDays = [Bool](repeating: false, count: 7) // Array for S, M, T, W, Th, F, S
    @State private var additionalMassDays = ""
    @State private var confessionTimesPerMonth = ""
    @State private var sacramentsNotes1 = ""
    @State private var sacramentsNotes2 = ""
    
    // Virtue fields
    @State private var digitalFast = ""
    @State private var bodilyFast = ""
    @State private var chastityPractices = ""
    @State private var virtueNotes1 = ""
    @State private var virtueNotes2 = ""
    
    // Service fields
    @State private var altarServerParish = ""
    @State private var spiritualWorkOfMercy = ""
    @State private var corporalWorkOfMercy = ""
    @State private var serviceNotes1 = ""
    @State private var serviceNotes2 = ""
    
    // Study fields
    @State private var readingMinutesPerDay = ""
    @State private var readingDaysPerWeek = ""
    @State private var studyNotes1 = ""
    @State private var studyNotes2 = ""
    
    // Specific Discernment fields (Dating Fast is now static checkmarks)
    @State private var spiritualDirectorName = ""
    @State private var seminaryName = ""
    @State private var seminaryVisitDate = ""
    @State private var retreatName = ""
    @State private var retreatDate = ""
    
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var showingSaveConfirmation = false
    @State private var errorMessage = ""
    @State private var showingErrorAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Prayer Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Prayer")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("I will pray for")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        TextField("60", text: $prayerMinutes)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 60)
                            .keyboardType(.numberPad)
                        Text("minutes every day")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }

                    HStack {
                        Text("My prayer time will be from")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        TextField("6:00 AM", text: $prayerTimeFrom)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        Text("to")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        TextField("7:00 AM", text: $prayerTimeTo)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("I will wake up at")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        TextField("5:30 AM", text: $wakeUpTime)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        Spacer()
                    }

                    HStack {
                        Text("My bedtime will be")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        TextField("10:30 PM", text: $bedTime)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        Spacer()
                    }

                    HStack {
                        Text("(Allow for 7 hours of sleep)")
                            .font(.system(size: 14))
                            .italic()
                            .foregroundColor(.secondary)

                    }
                    .padding(.bottom, 10)

                    // Night Prayer - mandatory (always checked)
                    HStack {
                        Image(systemName: "checkmark.square.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 18))
                        Text("I will pray Night Prayer every night.")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.bottom, 10)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("I will also pray these hours from the Liturgy of the Hours every day:")
                            .font(.system(size: 16))
                            .foregroundColor(.black)

                        // Optional hours
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 1), spacing: 8) {
                            ForEach(hoursOfPrayer, id: \.self) { hour in
                                Button(action: {
                                    if selectedHours.contains(hour) {
                                        selectedHours.remove(hour)
                                    } else {
                                        selectedHours.insert(hour)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: selectedHours.contains(hour) ? "checkmark.square.fill" : "square")
                                            .foregroundColor(selectedHours.contains(hour) ? .blue : .gray)
                                            .font(.system(size: 18))
                                        Text(hour)
                                            .font(.system(size: 15))
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("(Other Commitments for Prayer):")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(.top, 10)

                        TextField("e.g., Daily Rosary, Divine Mercy Chaplet", text: $prayerNotes1)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 16))
                    }
                }
            }

            // Sacraments Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Sacraments")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("I will attend Mass on these days:")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    
                    HStack {
                        ForEach(0..<7) { index in
                            Button(action: {
                                selectedMassDays[index].toggle()
                                // Update the count
                                massTimesPerWeek = String(selectedMassDays.filter { $0 }.count)
                            }) {
                                Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                                    .font(.system(size: 16))
                                    .foregroundColor(selectedMassDays[index] ? .white : .primary)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 10)
                                    .background(selectedMassDays[index] ? Color.blue : Color(.systemGray6))
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.bottom, 10)

                    HStack {
                        Text("I will go to Confession")
                            .font(.system(size: 16))
                        TextField("2", text: $confessionTimesPerMonth)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 50)
                            .keyboardType(.numberPad)
                        Text("times a month")
                            .font(.system(size: 16))
                    }
                }
            }
            
            // Virtue Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Virtue")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading) {
                        Text("Digital Fast:")
                            .font(.system(size: 16))
                        TextField("No social media after 9 PM", text: $digitalFast)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Bodily Fast:")
                            .font(.system(size: 16))
                        TextField("Friday abstinence from meat", text: $bodilyFast)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Chastity Practices:")
                            .font(.system(size: 16))
                        TextField("Custody of eyes, pure thoughts", text: $chastityPractices)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            
            // Service Section
            VStack(alignment: .leading, spacing: 10) {
                Text("Service")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading) {
                        Text("Altar Server at Parish:")
                            .font(.system(size: 16))
                        TextField("St. Mary's", text: $altarServerParish)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Spiritual Work of Mercy:")
                            .font(.system(size: 16))
                        TextField("Teach CCD", text: $spiritualWorkOfMercy)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Corporal Work of Mercy:")
                            .font(.system(size: 16))
                        TextField("Food bank volunteer", text: $corporalWorkOfMercy)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            
            // Study Section  
            VStack(alignment: .leading, spacing: 10) {
                Text("Study")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Spiritual reading:")
                            .font(.system(size: 16))
                        TextField("15", text: $readingMinutesPerDay)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 50)
                            .keyboardType(.numberPad)
                        Text("min/day,")
                            .font(.system(size: 16))
                        TextField("5", text: $readingDaysPerWeek)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 50)
                            .keyboardType(.numberPad)
                        Text("days/week")
                            .font(.system(size: 16))
                    }
                }
            }
            
            // Specific Discernment Actions
            VStack(alignment: .leading, spacing: 10) {
                Text("Specific Discernment Actions")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dating Fast (180 days):")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.black)

                    // First checkbox - matching Night Prayer style
                    HStack {
                        Image(systemName: "checkmark.square.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 18))
                        Text("Relate to women as a priest would")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        Spacer()
                    }

                    // Second checkbox - matching Night Prayer style
                    HStack {
                        Image(systemName: "checkmark.square.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 18))
                        Text("Dismiss romantic interests")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        Spacer()
                    }

                    // Third checkbox - matching Night Prayer style
                    HStack {
                        Image(systemName: "checkmark.square.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 18))
                        Text("Avoid one-on-one settings with women")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        Spacer()
                    }
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading) {
                        Text("Spiritual Director:")
                            .font(.system(size: 16))
                        TextField("Fr. Smith", text: $spiritualDirectorName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Seminary to Visit:")
                            .font(.system(size: 16))
                        TextField("St. John's Seminary", text: $seminaryName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Visit Date", text: $seminaryVisitDate)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Discernment Retreat:")
                            .font(.system(size: 16))
                        TextField("Come and See Retreat", text: $retreatName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Retreat Date", text: $retreatDate)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            
            // Save Button
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
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(isSaving ? Color.gray : Color.blue)
                .cornerRadius(10)
            }
            .disabled(isSaving)
            .padding(.top, 20)
        }
        .padding(.horizontal, 16)
        .onAppear {
            Task {
                await loadExistingRule()
            }
        }
        .alert("Success", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your Rule of Life has been saved successfully.")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loadExistingRule() async {
        guard !authViewModel.userId.isEmpty else { return }
        
        isLoading = true
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
                    
                    // Load additional hours and convert to Set (excluding Night Prayer which is mandatory)
                    let hoursString = ruleData["additional_hours"] as? String ?? ""
                    if !hoursString.isEmpty {
                        var hours = Set(hoursString.components(separatedBy: ", "))
                        hours.remove("Night Prayer") // Remove Night Prayer from selectable options
                        selectedHours = hours
                    } else {
                        selectedHours = Set<String>()
                    }
                    additionalHours = hoursString
                    
                    // Sacraments
                    let massDaysString = ruleData["mass_times_per_week"] as? String ?? ""
                    if !massDaysString.isEmpty {
                        let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                        let selectedDayNames = massDaysString.components(separatedBy: ", ")
                        selectedMassDays = [Bool](repeating: false, count: 7)
                        for (index, dayName) in dayNames.enumerated() {
                            if selectedDayNames.contains(dayName) {
                                selectedMassDays[index] = true
                            }
                        }
                        massTimesPerWeek = String(selectedMassDays.filter { $0 }.count)
                    } else {
                        selectedMassDays = [Bool](repeating: false, count: 7)
                        massTimesPerWeek = ""
                    }
                    additionalMassDays = ruleData["additional_mass_days"] as? String ?? ""
                    confessionTimesPerMonth = ruleData["confession_times_per_month"] as? String ?? ""
                    
                    // Virtue
                    digitalFast = ruleData["digital_fast"] as? String ?? ""
                    bodilyFast = ruleData["bodily_fast"] as? String ?? ""
                    chastityPractices = ruleData["chastity_practices"] as? String ?? ""
                    
                    // Service
                    altarServerParish = ruleData["altar_server_parish"] as? String ?? ""
                    spiritualWorkOfMercy = ruleData["spiritual_work_of_mercy"] as? String ?? ""
                    corporalWorkOfMercy = ruleData["corporal_work_of_mercy"] as? String ?? ""
                    
                    // Study
                    readingMinutesPerDay = ruleData["reading_minutes_per_day"] as? String ?? ""
                    readingDaysPerWeek = ruleData["reading_days_per_week"] as? String ?? ""
                    
                    // Specific Discernment
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
            print("Error loading rule of life: \(error)")
            await MainActor.run {
                isLoading = false
            }
        }
    }
    
    // Create a Codable struct for the data
    struct RuleOfLifeData: Codable {
        let user_id: String
        let prayer_minutes: String
        let prayer_time_from: String
        let prayer_time_to: String
        let wake_up_time: String
        let bed_time: String
        let additional_hours: String
        let prayer_notes1: String
        let prayer_notes2: String
        let mass_times_per_week: String
        let additional_mass_days: String
        let confession_times_per_month: String
        let sacraments_notes1: String
        let sacraments_notes2: String
        let digital_fast: String
        let bodily_fast: String
        let chastity_practices: String
        let virtue_notes1: String
        let virtue_notes2: String
        let altar_server_parish: String
        let spiritual_work_of_mercy: String
        let corporal_work_of_mercy: String
        let service_notes1: String
        let service_notes2: String
        let reading_minutes_per_day: String
        let reading_days_per_week: String
        let study_notes1: String
        let study_notes2: String
        let dating_fast_commitment: Bool
        let dismiss_romantic_interests: Bool
        let avoid_one_on_one: Bool
        let spiritual_director_name: String
        let seminary_name: String
        let seminary_visit_date: String
        let retreat_name: String
        let retreat_date: String
    }
    
    private func saveRuleOfLife() {
        guard !authViewModel.userId.isEmpty else {
            errorMessage = "User not authenticated"
            showingErrorAlert = true
            return
        }
        
        isSaving = true
        
        Task {
            do {
                // Convert boolean array to day names
                let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                var selectedDayNames: [String] = []
                for (index, isSelected) in selectedMassDays.enumerated() {
                    if isSelected {
                        selectedDayNames.append(dayNames[index])
                    }
                }
                
                let ruleData = RuleOfLifeData(
                    user_id: authViewModel.userId,
                    prayer_minutes: prayerMinutes,
                    prayer_time_from: prayerTimeFrom,
                    prayer_time_to: prayerTimeTo,
                    wake_up_time: wakeUpTime,
                    bed_time: bedTime,
                    additional_hours: "Night Prayer, " + Array(selectedHours).joined(separator: ", "),
                    prayer_notes1: prayerNotes1,
                    prayer_notes2: prayerNotes2,
                    mass_times_per_week: selectedDayNames.joined(separator: ", "),
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
                    dating_fast_commitment: true,
                    dismiss_romantic_interests: true,
                    avoid_one_on_one: true,
                    spiritual_director_name: spiritualDirectorName,
                    seminary_name: seminaryName,
                    seminary_visit_date: seminaryVisitDate,
                    retreat_name: retreatName,
                    retreat_date: retreatDate
                )
                
                // Check if user already has a rule of life
                let checkResponse = try await SupabaseManager.shared.client
                    .from("rule_of_life")
                    .select("user_id")
                    .eq("user_id", value: authViewModel.userId)
                    .execute()
                
                if let dataArray = try JSONSerialization.jsonObject(with: checkResponse.data) as? [[String: Any]],
                   !dataArray.isEmpty {
                    // Update existing record
                    _ = try await SupabaseManager.shared.client
                        .from("rule_of_life")
                        .update(ruleData)
                        .eq("user_id", value: authViewModel.userId)
                        .execute()
                } else {
                    // Insert new record
                    _ = try await SupabaseManager.shared.client
                        .from("rule_of_life")
                        .insert(ruleData)
                        .execute()
                }
                
                await MainActor.run {
                    isSaving = false
                    showingSaveConfirmation = true
                }
                
            } catch {
                print("Error saving rule of life: \(error)")
                await MainActor.run {
                    isSaving = false
                    errorMessage = "Failed to save rule of life. Please try again."
                    showingErrorAlert = true
                }
            }
        }
    }
}

struct WeekReviewView_Previews: PreviewProvider {
    static var previews: some View {
        WeekReviewView(weekNumber: 1)
    }
}
