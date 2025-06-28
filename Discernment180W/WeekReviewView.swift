import SwiftUI
import CoreData
import Supabase

struct WeeklyReview: Codable, Identifiable {
    let id: Int?
    let highlight: String
    let challenge: String
    let lesson: String
    let date: Date
    let userId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case highlight
        case challenge
        case lesson
        case date = "created_at"
        case userId = "user_id"
    }
}

struct WeekReviewView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    // Keep a consistent user ID
    var weekNumber: Int

    private let userId: String = "ae88bf9d-f37b-4919-88b8-74a8c2ff5c8b"
    
    @State private var prayerDays: Int = 3
    @State private var liturgyOfTheHoursDays: Int = 1
    @State private var sleptHoursDays: Int = 1
    @State private var isMassCommitted: Bool = false
    @State private var isConfessionCommitted: Bool = false
    @State private var prayerNotes: String = ""
    @State private var prayerAdjustmentsNotes: String = ""
    @State private var sacramentNotes: String = ""
    @State private var virtueNotes: String = ""
    @State private var virtueAdjustmentsNotes: String = ""
    @State private var studyNotes: String = ""
    @State private var studyAdjustmentsNotes: String = ""
    @State private var serviceNotes: String = ""
    @State private var serviceAdjustmentsNotes: String = ""
    @State private var meditationReadingDate = Date()
    
    @State private var sacramentAdjustmentsNotes: String = ""
    @State private var isLoading: Bool = false
    @State private var bodilyFastDays: [Bool] = Array(repeating: false, count: 7)
    @State private var digitalFastDays: [Bool] = Array(repeating: false, count: 7)
    @State private var isdatingFastCommitted: Bool? = nil

    @State private var hmeCommitment: Bool? = nil
    @State private var worksMercy: Bool? = nil
    @State private var corporalMercy: Bool? = nil
    @State private var spiritualReading: Bool? = nil
    
    @State private var massDays: [Bool] = Array(repeating: false, count: 7)
    @State private var lotrDays: [Bool] = Array(repeating: false, count: 7)
    @State private var sleepDays: [Bool] = Array(repeating: false, count: 7)
    
    @State private var confessionDay: Int? = nil
    @State private var isAltarServiceScheduled: Bool? = nil
    @State private var altarServingCommitment: Bool? = nil
    @State private var spiritualMercyCommitment: Bool? = nil
    @State private var corporalMercyCommitment: Bool? = nil
    @State private var spiritualReadingCommitment: Bool? = nil

    @State private var dailyMassCommitment: Bool? = nil
    @State private var datingFastCommitment: Bool? = nil

    @State private var regularConfession: Bool? = nil
    
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

    var body: some View {
        VStack(spacing: 0) {
            // Fixed header with back button and home button
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
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
                
                Text("Week \(weekNumber) Review")
                    .font(.custom("Georgia", size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                // Home button
                Button(action: {
                    // Multiple approaches to ensure we get to root
                    
                    // First dismiss all modal presentations
                    presentationMode.wrappedValue.dismiss()
                    
                    // Then try multiple methods to get to root
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        // Method 1: Try UIKit navigation
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            
                            var currentVC = window.rootViewController
                            
                            // Navigate through the hierarchy to find navigation controller
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
                        
                        // Method 2: Dismiss all and try again
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first,
                               let rootNav = window.rootViewController as? UINavigationController {
                                rootNav.popToRootViewController(animated: true)
                            }
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        Text("Home")
                            .font(.system(size: 17, weight: .medium))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .medium))
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
                            sectionView(title: "Prayer")
                            sectionView(title: "Sacraments", isMassSection: true)
                            sectionView(title: "Virtue", isVirtueSection: true)
                            sectionView(title: "Service", isServiceSection: true)
                            sectionView(title: "Study", isStudySection: true)
                        }
                        .padding(.top, 8)
                    }
                    
                    Button(action: {
                        saveWeeklyReview()
                    }) {
                        Text("Save Weekly Review")
                            .font(.custom("Georgia", size: 18))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
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
            Task {
                await fetchPrayerDays()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Success", isPresented: $showingSaveConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your weekly review has been saved.")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    func sectionView(title: String, isMassSection: Bool = false, isVirtueSection: Bool = false, isServiceSection: Bool = false, isStudySection: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.custom("Georgia", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.leading, 16)
            
            if title == "Prayer" {
                // Prayer Section
                Text("I fulfilled my commitment to daily, personal prayer _ / 7 days this week.")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                HStack {
                    ForEach(0..<7) { index in
                        Button(action: {
                            massDays[index].toggle()
                        }) {
                            Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(massDays[index] ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(massDays[index] ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                    }
                }.padding(.bottom, 10)
                    .padding(.leading, 16)
                
                Text("I fulfilled my commitment to the Liturgy of the Hours _ / 7 days this week.")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                HStack {
                    ForEach(0..<7) { index in
                        Button(action: {
                            lotrDays[index].toggle()
                        }) {
                            Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(lotrDays[index] ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(lotrDays[index] ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                    }
                }.padding(.bottom, 10)
                    .padding(.leading, 16)
                
                Text("I slept at least 7 hours _ / 7 days this week.")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                HStack {
                    ForEach(0..<7) { index in
                        Button(action: {
                            sleepDays[index].toggle()
                        }) {
                            Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(sleepDays[index] ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(sleepDays[index] ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                    }
                }.padding(.bottom, 10)
                    .padding(.leading, 16)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("These were the experiences (if any) that I need to bring to prayer and/or spiritual direction:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $prayerNotes)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on my responses, I will make the following (if any) adjustments:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $prayerAdjustmentsNotes)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
            } else if isMassSection {
                // Sacraments Section
                HStack {
                    Text("I fulfilled my commitment to daily Mass this week.")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: { dailyMassCommitment = true }) {
                            Text("Yes")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(dailyMassCommitment == true ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(dailyMassCommitment == true ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        Button(action: { dailyMassCommitment = false }) {
                            Text("No")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(dailyMassCommitment == false ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(dailyMassCommitment == false ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                    }
                    .padding(.trailing, 16)
                }.padding(.bottom, 10)
                
                HStack {
                    Text("I fulfilled (or am on track to fulfill) my commitment to regular Confession.")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: { regularConfession = true }) {
                            Text("Yes")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(regularConfession == true ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(regularConfession == true ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        Button(action: { regularConfession = false }) {
                            Text("No")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(regularConfession == false ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(regularConfession == false ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                    }
                    .padding(.trailing, 16)
                }.padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("These were the experiences (if any) that I need to bring to prayer and/or spiritual direction:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $sacramentNotes)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on my responses, I will make the following (if any) adjustments:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $sacramentAdjustmentsNotes)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
            } else if isVirtueSection {
                // Virtue Section
                Text("I was faithful to my bodily fast _ / 7 days this week.")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                HStack {
                    ForEach(0..<7) { index in
                        Button(action: {
                            bodilyFastDays[index].toggle()
                        }) {
                            Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(bodilyFastDays[index] ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(bodilyFastDays[index] ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                    }
                }.padding(.bottom, 10)
                    .padding(.leading, 16)
                
                Text("I was faithful to my digital fast _ / 7 days this week.")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                HStack {
                    ForEach(0..<7) { index in
                        Button(action: {
                            digitalFastDays[index].toggle()
                        }) {
                            Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(digitalFastDays[index] ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(digitalFastDays[index] ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                    }
                }.padding(.bottom, 10)
                    .padding(.leading, 16)
                
                HStack {
                    Text("I was faithful to my dating fast.")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: { datingFastCommitment = true }) {
                            Text("Yes")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(datingFastCommitment == true ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(datingFastCommitment == true ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        Button(action: { datingFastCommitment = false }) {
                            Text("No")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(datingFastCommitment == false ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(datingFastCommitment == false ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                    }
                    .padding(.trailing, 16)
                }.padding(.bottom, 10)
                
                HStack {
                    Text("I was faithful to the necessary practices from hismercyendures.org.")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: { hmeCommitment = true }) {
                            Text("Yes")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(hmeCommitment == true ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(hmeCommitment == true ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        Button(action: { hmeCommitment = false }) {
                            Text("No")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(hmeCommitment == false ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(hmeCommitment == false ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                    }
                    .padding(.trailing, 16)
                }.padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("These were the experiences (if any) that I need to bring to prayer and/or spiritual direction:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $virtueNotes)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on my responses, I will make the following (if any) adjustments:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $virtueAdjustmentsNotes)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
            } else if isServiceSection {
                // Service Section
                HStack {
                    Text("I fulfilled (or am on track to fulfill) my commitment to altar serving.")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: { altarServingCommitment = true }) {
                            Text("Yes")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(altarServingCommitment == true ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(altarServingCommitment == true ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        Button(action: { altarServingCommitment = false }) {
                            Text("No")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(altarServingCommitment == false ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(altarServingCommitment == false ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                    }
                    .padding(.trailing, 16)
                }.padding(.bottom, 10)
                
                HStack {
                    Text("I fulfilled (or am on track to fulfill) my commitment to spiritual works of mercy.")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: { spiritualMercyCommitment = true }) {
                            Text("Yes")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(spiritualMercyCommitment == true ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(spiritualMercyCommitment == true ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        Button(action: { spiritualMercyCommitment = false }) {
                            Text("No")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(spiritualMercyCommitment == false ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(spiritualMercyCommitment == false ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                    }
                    .padding(.trailing, 16)
                }.padding(.bottom, 10)
                
                HStack {
                    Spacer()
                    HStack {
                        Button(action: { corporalMercyCommitment = true }) {
                            Text("Yes")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(corporalMercyCommitment == true ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(corporalMercyCommitment == true ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        Button(action: { corporalMercyCommitment = false }) {
                            Text("No")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(corporalMercyCommitment == false ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(corporalMercyCommitment == false ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                    }
                    .padding(.trailing, 16)
                }.padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("These were the experiences (if any) that I need to bring to prayer and/or spiritual direction:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $serviceNotes)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on my responses, I will make the following (if any) adjustments:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $serviceAdjustmentsNotes)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
            } else if isStudySection {
                // Study Section
                HStack {
                    Text("Have I fulfilled my commitment to spiritual reading?")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: { spiritualReadingCommitment = true }) {
                            Text("Yes")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(spiritualReadingCommitment == true ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(spiritualReadingCommitment == true ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        Button(action: { spiritualReadingCommitment = false }) {
                            Text("No")
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(spiritualReadingCommitment == false ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(spiritualReadingCommitment == false ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                    }
                    .padding(.trailing, 16)
                }.padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("I need to bring to prayer and/or spiritual direction")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $studyNotes)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on my responses, I will make the following (if any) adjustments:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $studyAdjustmentsNotes)
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
            } else {
                // Default section
                Text(loremIpsumText())
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .lineSpacing(5)
                    .padding(.horizontal, 16)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
            }
        }
    }
    
    func loremIpsumText() -> String {
        return """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
        """
    }
    
    private func saveWeeklyReview() {
        Task { @MainActor in
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
                    "user_id": userId,
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
                    .eq("user_id", value: userId)
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
                    isLoading = false
                    showingSaveConfirmation = true
                }
                
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Error saving review: \(error.localizedDescription)"
                    showingErrorAlert = true
                }
            }
        }
    }
    
    func fetchPrayerDays() async {
        do {
            await MainActor.run {
                isLoading = true
            }
            
            let response = try await SupabaseManager.shared.client
                .from("WeekReview")
                .select("prayer_days, liturgy_of_the_hours_days, slept_hours_days, prayer_notes, prayer_adjustments_notes, sacrament_notes, sacrament_adjustments_notes, virtue_notes, virtue_adjustments_notes, service_notes, service_adjustments_notes, study_notes, study_adjustments_notes, daily_mass_commitment, regular_confession, bodily_fast_days, digital_fast_days, dating_fast_commitment, hme_commitment, altar_serving_commitment, spiritual_mercy_commitment, corporal_mercy_commitment, spiritual_reading_commitment")
                .eq("user_id", value: userId)
                .eq("week_number", value: String(weekNumber))
                .order("created_at", ascending: false)
                .limit(1)
                .execute()
            
            let jsonData = response.data
            
            if let dataArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
               !dataArray.isEmpty {
                let latestReview = dataArray[0]
                await processPrayerAndLiturgyData(latestReview)
            } else {
                await MainActor.run {
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
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
