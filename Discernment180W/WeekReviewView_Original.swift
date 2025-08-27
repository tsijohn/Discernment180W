import SwiftUI
import CoreData
import Supabase

struct WeekReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var dataManager = WeekReviewDataManager()
    
    @State var weekNumber: Int
    @State private var showingWeekPicker = false
    @State private var selectedWeek: Int = 1
    @State private var showingPlanningAhead = false
    @State private var showingMyRule = false
    @State private var meditationReadingDate = Date()
    
    let showSkipButton: Bool
    
    init(weekNumber: Int, showSkipButton: Bool = false) {
        self.weekNumber = weekNumber
        self.showSkipButton = showSkipButton
        self._selectedWeek = State(initialValue: weekNumber)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            WeekReviewHeader(
                weekNumber: weekNumber,
                isReviewSaved: dataManager.isReviewSaved,
                onBackPressed: { dismiss() }
            )
            
            // Week Navigation
            WeekNavigationView(
                weekNumber: $weekNumber,
                showingWeekPicker: $showingWeekPicker,
                onWeekSelected: { week in
                    handleWeekSelection(week)
                }
            )

            // Planning Ahead and My Rule sections
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    PlanningAheadView(
                        planningData: dataManager.planningAheadData,
                        showingPlanningAhead: $showingPlanningAhead
                    )
                    
                    RuleOfLifeView(
                        ruleData: dataManager.ruleOfLifeData,
                        showingMyRule: $showingMyRule
                    )
                }
                .padding(.horizontal, 16)
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
                            PrayerSectionView(formData: $dataManager.formData)
                            SacramentsSectionView(formData: $dataManager.formData)
                            VirtueSectionView(formData: $dataManager.formData)
                            ServiceSectionView(formData: $dataManager.formData)
                            StudySectionView(formData: $dataManager.formData)
                        }
                        .padding(.top, 8)
                    }
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        // Skip button
                        if showSkipButton {
                            Button(action: {
                                guard !dataManager.isSkipping else { return }
                                handleSkipReview()
                            }) {
                                HStack {
                                    if dataManager.isSkipping {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .foregroundColor(.primary)
                                    }
                                    Text(dataManager.isSkipping ? "Skipping..." : "Skip")
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
                            .disabled(dataManager.isSkipping || dataManager.isSaving)
                        }
                        
                        // Save button
                        Button(action: {
                            guard !dataManager.isSaving else { return }
                            handleSaveReview()
                        }) {
                            HStack {
                                if dataManager.isSaving {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundColor(.white)
                                }
                                Text(dataManager.isSaving ? "Saving..." : "Save Weekly Review")
                                    .font(.custom("Georgia", size: 18))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(dataManager.isSaving || dataManager.isSkipping ? Color.gray : Color.blue)
                            .cornerRadius(10)
                        }
                        .disabled(dataManager.isSaving || dataManager.isSkipping)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    Spacer()
                }
                
                if dataManager.isLoading {
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
                await dataManager.fetchAllData(
                    for: weekNumber,
                    userEmail: authViewModel.userEmail,
                    userId: authViewModel.userId
                )
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Success", isPresented: $dataManager.showingSaveConfirmation) {
            Button("OK", role: .cancel) {
                navigateToHome()
            }
        } message: {
            Text("Your weekly review has been saved.")
        }
        .alert("Error", isPresented: $dataManager.showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(dataManager.errorMessage)
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleWeekSelection(_ week: Int) {
        dataManager.clearFormData()
        weekNumber = week
        selectedWeek = week
        showingWeekPicker = false
        
        Task {
            await dataManager.fetchAllData(
                for: weekNumber,
                userEmail: authViewModel.userEmail,
                userId: authViewModel.userId
            )
        }
    }
    
    private func handleSaveReview() {
        Task {
            await dataManager.saveWeeklyReview(
                weekNumber: weekNumber,
                userId: authViewModel.userId
            )
        }
    }
    
    private func handleSkipReview() {
        Task {
            await dataManager.skipWeeklyReview(userEmail: authViewModel.userEmail)
            navigateToHome()
        }
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
    
}

struct WeekReviewView_Previews: PreviewProvider {
    static var previews: some View {
        WeekReviewView(weekNumber: 1)
    }
}

