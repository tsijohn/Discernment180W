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
    @State private var sacramentNotes: String = "" // New state for Sacrament notes
    @State private var virtueNotes: String = ""
    @State private var virtueAdjustmentsNotes: String = ""
    @State private var studyNotes: String = ""
    @State private var studyAdjustmentsNotes: String = ""
    @State private var serviceNotes: String = ""
    @State private var serviceAdjustmentsNotes: String = ""
    @State private var meditationReadingDate = Date()
    
    @State private var sacramentAdjustmentsNotes: String = "" // New for Sacrament adjustments
    @State private var isLoading: Bool = false // Changed to start as false
    // Planning Ahead Section States
    @State private var bodilyFastDays: [Bool] = Array(repeating: false, count: 7) // S M T W Th F S
    @State private var digitalFastDays: [Bool] = Array(repeating: false, count: 7) // S M T W Th F S
    @State private var isdatingFastCommitted: Bool? = nil

    @State private var hmeCommitment: Bool? = nil
    @State private var worksMercy: Bool? = nil
    @State private var corporalMercy: Bool? = nil
    @State private var spiritualReading: Bool? = nil
    
    @State private var massDays: [Bool] = Array(repeating: false, count: 7) // S M T W Th F S
    // Planning Ahead Section States
    @State private var lotrDays: [Bool] = Array(repeating: false, count: 7) // S M T W Th F S
    @State private var sleepDays: [Bool] = Array(repeating: false, count: 7) // S M T W Th F S
    
    @State private var confessionDay: Int? = nil  //  nil means not selected, 1=Sun, 2=Mon, ..., 7=Sat, 8 = Not this week
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
    @State private var scheduleNotes: String = ""  // For "altar service ... mercy?" notes
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
    @State private var massScheduledDays: [Bool] = Array(repeating: false, count: 7) // S M T W Th F S
    @State private var confessionScheduledDays: [Bool] = Array(repeating: false, count: 7) // S M T W Th F S
    @State private var currentWeek: Int = 0

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Spacer()
                    Text("Week \(weekNumber) Review")
                        .font(.custom("Georgia", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 10)
                    Spacer()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        sectionView(title: "Prayer")
                        sectionView(title: "Sacraments", isMassSection: true) // Sacraments section
                        sectionView(title: "Virtue", isVirtueSection: true)
                        sectionView(title: "Service", isServiceSection: true)
                        sectionView(title: "Study", isStudySection: true)
                        sectionView(title: "Planning Ahead")
                    }
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
        .onAppear {
            Task {
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
                // Prayer Section (No changes)
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
                    .onAppear {
                        Task {

                        }
                    }
                
                
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
                    .onAppear {
                        Task {
                            
                        }
                    }
                
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
                    .onAppear {
                        Task {
                            
                        }
                    }
                
                
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
                // Daily Mass Commitment
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
                
                
                // New Text and TextEditor for Sacrament notes
                VStack(alignment: .leading, spacing: 10) {
                    Text("These were the experiences (if any) that I need to bring to prayer and/or spiritual direction:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $sacramentNotes) // Bind to new state
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
                // New Text and TextEditor for Sacrament adjustments
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on my responses, I will make the following (if any) adjustments:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $sacramentAdjustmentsNotes) // Bind to new state
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
            } else if isVirtueSection {
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
                
                    .onAppear {
                        Task {
                            await fetchPrayerDays()
                            
                        }
                    }
                
                
            } else if isStudySection {
                // Daily Mass Commitment
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
                                //         ^^^^^^^^^^^^^^^^^^^^^^^^^ Change this line
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
                // New Text and TextEditor for Sacrament notes
                VStack(alignment: .leading, spacing: 10) {
                    Text("I need to bring to prayer and/or spiritual direction")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $sacramentNotes) // Bind to new state
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
                // New Text and TextEditor for Sacrament adjustments
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on my responses, I will make the following (if any) adjustments:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $sacramentAdjustmentsNotes) // Bind to new state
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
            } else if isServiceSection {
                // Daily Mass Commitment
                HStack {
                    Text("I fulfilled (or am on track to fulfill) my commitment to altar serving.")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: {altarServingCommitment = true }) {
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
                        Button(action: {spiritualMercyCommitment = true }) {
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
                    Text("I fulfilled (or am on track to fulfill) my commitment to corporal works of mercy.")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: {corporalMercyCommitment = true }) {
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
                    
                    TextEditor(text: $serviceNotes) // Bind to new state
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
                // New Text and TextEditor for Sacrament adjustments
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on my responses, I will make the following (if any) adjustments:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $serviceAdjustmentsNotes) // Bind to new state
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
                
            } else if isStudySection {
                // Daily Mass Commitment
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
                // New Text and TextEditor for Sacrament notes
                VStack(alignment: .leading, spacing: 10) {
                    Text("I need to bring to prayer and/or spiritual direction")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $studyNotes) // Bind to new state
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
                // New Text and TextEditor for Sacrament adjustments
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on my responses, I will make the following (if any) adjustments:")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $studyAdjustmentsNotes) // Bind to new state
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                }.padding(.bottom, 10)
                
            } else if title == "Planning Ahead" {
                // Use the new PlanningAheadView component instead of inline code
                MyPlanningAheadView(
                    massScheduledDays: $massScheduledDays,
                    confessionScheduledDays: $confessionScheduledDays,
                    meditationReadingDate: $meditationReadingDate,
                    isSpiritualMercyScheduled: $isSpiritualMercyScheduled,
                    isCorporalMercyScheduled: $isCorporalMercyScheduled,
                    scheduleNotes: $scheduleNotes,
                    isSpiritualDirectionScheduled: $isSpiritualDirectionScheduled,
                    isSeminaryVisitScheduled: $isSeminaryVisitScheduled,
                    isDiscernmentRetreatScheduled: $isDiscernmentRetreatScheduled
                )
            } else {
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
        // Set loading state on the main thread
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
                
                let massScheduledDaysNames = massScheduledDays.enumerated()
                    .filter { $0.element }
                    .map { dayNames[$0.offset] }
                
                let confessionScheduledDaysNames = confessionScheduledDays.enumerated()
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
                
                let massScheduledDaysJSON = try JSONSerialization.data(withJSONObject: massScheduledDaysNames)
                let massScheduledDaysString = String(data: massScheduledDaysJSON, encoding: .utf8) ?? "[]"
                
                let confessionScheduledDaysJSON = try JSONSerialization.data(withJSONObject: confessionScheduledDaysNames)
                let confessionScheduledDaysString = String(data: confessionScheduledDaysJSON, encoding: .utf8) ?? "[]"
                
                // Build the payload using string key-value pairs for compatibility
                var payload: [String: String] = [
                    "created_at": dateFormatter.string(from: Date()),
                    "user_id": userId,
                    "prayer_days": massDaysString,
                    "meditation_reading_date": dateFormatter.string(from: meditationReadingDate),
                    "week_number": String(weekNumber),
                    "liturgy_of_the_hours_days": lotrDaysString,
                    "slept_hours_days": sleepDaysString,
                    "is_mass_committed": (dailyMassCommitment ?? false) ? "true" : "false",
                    "is_confession_committed": (regularConfession ?? false) ? "true" : "false",
                    "prayer_notes": prayerNotes,
                    "prayer_adjustments_notes": prayerAdjustmentsNotes,
                    "sacrament_notes": sacramentNotes,
                    "sacrament_adjustments_notes": sacramentAdjustmentsNotes,
                    "virtue_notes": virtueNotes,
                    "virtue_adjustments_notes": virtueAdjustmentsNotes,
                    "service_notes": serviceNotes,
                    "service_adjustments_notes": serviceAdjustmentsNotes,
                    "schedule_notes": scheduleNotes,
                    "bodily_fast_days": bodilyFastDaysString,
                    "digital_fast_days": digitalFastDaysString,
                    "mass_scheduled_days": massScheduledDaysString,
                    "confession_scheduled_days": confessionScheduledDaysString,
                    "dating_fast_commitment": (datingFastCommitment ?? false) ? "true" : "false",
                    "hme_commitment": (hmeCommitment ?? false) ? "true" : "false",
                    "spiritual_reading_commitment": (spiritualReadingCommitment ?? false) ? "true" : "false",
                    "corporal_mercy_commitment": (corporalMercyCommitment ?? false) ? "true" : "false"
                ]
                
                // Add optional booleans with null handling
                if let value = dailyMassCommitment {
                    payload["daily_mass_commitment"] = value ? "true" : "false"
                }
                
                if let value = regularConfession {
                    payload["regular_confession"] = value ? "true" : "false"
                }
                
                if let value = isAltarServiceScheduled {
                    payload["is_altar_service_scheduled"] = value ? "true" : "false"
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
                
                if let value = isSpiritualMercyScheduled {
                    payload["is_spiritual_mercy_scheduled"] = value ? "true" : "false"
                }
                
                if let value = isCorporalMercyScheduled {
                    payload["is_corporal_mercy_scheduled"] = value ? "true" : "false"
                }
                
                if let value = isSpiritualDirectionScheduled {
                    payload["is_spiritual_direction_scheduled"] = value ? "true" : "false"
                }
                
                if let value = isSeminaryVisitScheduled {
                    payload["is_seminary_visit_scheduled"] = value ? "true" : "false"
                }
                
                if let value = isDiscernmentRetreatScheduled {
                    payload["is_discernment_retreat_scheduled"] = value ? "true" : "false"
                }
              
//                if let value = isDiscernmentRetreatScheduled {
//                    payload["is_spiritual_direction_scheduled"] = value ? "true" : "false"
//                }
                
                
                if let day = confessionDay {
                    if day == 8 {
                        payload["confession_day"] = "Not this week"
                    } else if day >= 1 && day <= 7 {
                        payload["confession_day"] = dayNames[day - 1]
                    }
                }
                
                if let value = spiritualReadingCommitment {
                    payload["spiritual_reading_commitment"] = value ? "true" : "false"
                }
                
                if let value = dailyMassCommitment {
                    payload["daily_mass_commitment"] = value ? "true" : "false"
                }
                
                
                if let value = datingFastCommitment {
                    payload["dating_fast_commitment"] = value ? "true" : "false"
                }
                
                if let value = hmeCommitment {
                    payload["hme_commitment"] = value ? "true" : "false"
                }
                
                // Check if a record already exists with this user_id and week_number
                let response = try await SupabaseManager.shared.client
                    .from("WeekReview")
                    .select("id")
                    .eq("user_id", value: userId)
                    .eq("week_number", value: String(weekNumber))
                    .execute()
                
                let jsonData = response.data
                
                // Try to parse the response to see if we found an existing record
                do {
                    if let dataArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
                       !dataArray.isEmpty,
                       let existingId = dataArray[0]["id"] as? Int {
                        
                        // Record exists, perform an update
                        print("Updating existing WeekReview record with ID: \(existingId)")
                        
                        try await SupabaseManager.shared.client
                            .from("WeekReview")
                            .update(payload)
                            .eq("id", value: String(existingId))
                            .execute()
                    } else {
                        // No existing record, perform an insert
                        print("Creating new WeekReview record")
                        
                        try await SupabaseManager.shared.client
                            .from("WeekReview")
                            .insert(payload)
                            .execute()
                    }
                    
                    // Update UI on main thread
                    await MainActor.run {
                        isLoading = false
                        showingSaveConfirmation = true
                    }
                } catch {
                    print("Error parsing response data: \(error)")
                    
                    // If we can't parse the response, fall back to insert
                    print("Falling back to creating new WeekReview record")
                    
                    try await SupabaseManager.shared.client
                        .from("WeekReview")
                        .insert(payload)
                        .execute()
                    
                    await MainActor.run {
                        isLoading = false
                        showingSaveConfirmation = true
                    }
                }
            } catch {
                // Handle errors and update UI on main thread
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Error saving review: \(error.localizedDescription)"
                    showingErrorAlert = true
                    print("Error saving weekly review: \(error)")
                }
            }
        }
    }
    
    
    func fetchPrayerDays() async {
        do {
            // Show loading state on main thread
            await MainActor.run {
                isLoading = true
            }
            
            // Make the fetch request for the latest weekly review with all needed fields
            let response = try await SupabaseManager.shared.client
                .from("WeekReview")
                .select("prayer_days, liturgy_of_the_hours_days, slept_hours_days, prayer_notes, prayer_adjustments_notes, sacrament_notes, sacrament_adjustments_notes, virtue_notes, virtue_adjustments_notes, service_notes, service_adjustments_notes, study_notes, study_adjustments_notes,is_mass_committed, is_confession_committed, bodily_fast_days, digital_fast_days, dating_fast_commitment, hme_commitment, altar_serving_commitment, spiritual_mercy_commitment, corporal_mercy_commitment, spiritual_reading_commitment, mass_scheduled_days, confession_scheduled_days, meditation_reading_date, is_spiritual_mercy_scheduled, is_corporal_mercy_scheduled, is_spiritual_direction_scheduled, is_seminary_visit_scheduled, is_discernment_retreat_scheduled")
                .eq("user_id", value: userId)
                .eq("week_number", value: String(weekNumber))
                .order("created_at", ascending: false)
                .limit(1)
                .execute()
            
            // Debug print the raw response to see its structure
            print("Raw Supabase response: \(response)")
            
            // Handle the response data directly
            let jsonData = response.data
            print("Response data: \(jsonData)")
            
            // Try to parse the JSON data
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON string: \(jsonString)")
                
                // Try to parse as a JSON array
                do {
                    if let dataArray = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]],
                       !dataArray.isEmpty {
                        let latestReview = dataArray[0]
                        await processPrayerAndLiturgyData(latestReview)
                    } else if let dataDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                        // If it's a single object rather than an array
                        await processPrayerAndLiturgyData(dataDict)
                    } else {
                        print("JSON parsed but couldn't convert to expected format")
                        await MainActor.run {
                            isLoading = false
                        }
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                    await MainActor.run {
                        isLoading = false
                    }
                }
            } else {
                print("Could not convert response data to string")
                await MainActor.run {
                    isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                print("Error fetching prayer data: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }
    
    // Helper function to process all prayer and liturgy data on the main thread
    @MainActor
    private func processPrayerAndLiturgyData(_ reviewData: [String: Any]) {
        // Helper function to parse JSON array strings
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

        
        // Helper function for legacy format (binary string like "1010101")
        func parseLegacyDaysString(_ binaryString: String?) -> [Bool] {
            guard let binaryString = binaryString else {
                return Array(repeating: false, count: 7)
            }
            
            var boolArray = Array(repeating: false, count: 7)
            for (index, char) in binaryString.enumerated() {
                if index < 7 {
                    boolArray[index] = (char == "1")
                }
            }
            
            return boolArray
        }
        
        // Process each field
        
        // 1. Update Mass days (prayer days)
        if let prayerDaysString = reviewData["prayer_days"] as? String {
            print("Found prayer_days string: \(prayerDaysString)")
            
            if prayerDaysString.starts(with: "[") {
                // JSON array format
                massDays = parseDaysArray(prayerDaysString)
                print("Parsed prayer days as JSON array: \(massDays)")
            } else {
                // Legacy format if applicable
                massDays = parseLegacyDaysString(prayerDaysString)
                print("Parsed prayer days as legacy binary string: \(massDays)")
            }
        } else {
            print("No prayer_days string found in response data")
        }
        
        // 2. Update Liturgy of the Hours days
        if let lotrDaysString = reviewData["liturgy_of_the_hours_days"] as? String {
            print("Found lotr_days string: \(lotrDaysString)")
            
            if lotrDaysString.starts(with: "[") {
                // JSON array format
                lotrDays = parseDaysArray(lotrDaysString)
                print("Parsed LOTR days as JSON array: \(lotrDays)")
            } else {
                // Legacy format if applicable
                lotrDays = parseLegacyDaysString(lotrDaysString)
                print("Parsed LOTR days as legacy binary string: \(lotrDays)")
            }
        } else {
            print("No lotr_days string found in response data")
        }
        
        // 3. Update Sleep days
        if let sleepDaysString = reviewData["slept_hours_days"] as? String {
            print("Found sleep_days string: \(sleepDaysString)")
            
            if sleepDaysString.starts(with: "[") {
                // JSON array format
                sleepDays = parseDaysArray(sleepDaysString)
                print("Parsed sleep days as JSON array: \(sleepDays)")
            } else {
                // Legacy format if applicable
                sleepDays = parseLegacyDaysString(sleepDaysString)
                print("Parsed sleep days as legacy binary string: \(sleepDays)")
            }
        } else {
            print("No sleep_days string found in response data")
        }
        
        // 4. Update Prayer Notes
        if let prayerNotesData = reviewData["prayer_notes"] as? String {
            prayerNotes = prayerNotesData
            print("Updated prayer notes")
        } else {
            print("No prayer notes found in response data")
        }
        
        if let prayerAdjustmentsData = reviewData["prayer_adjustments_notes"] as? String {
            prayerAdjustmentsNotes = prayerAdjustmentsData
            print("Updated prayer adjustments notes")
        } else {
            print("No prayer adjustments notes found in response data")
        }
        
        if let sacramentNotesData = reviewData["sacrament_notes"] as? String {
            sacramentNotes = sacramentNotesData
            print("Updated sacrament notes")
        } else {
            print("No sacrament notes found in response data")
        }

        // For sacrament adjustment notes
        if let sacramentAdjustmentsData = reviewData["sacrament_adjustments_notes"] as? String {
            sacramentAdjustmentsNotes = sacramentAdjustmentsData
            print("Updated sacrament adjustment notes")
        } else {
            print("No sacrament adjustment notes found in response data")
        }
        
        if let virtueNotesData = reviewData["virtue_notes"] as? String {
            virtueNotes = virtueNotesData
            print("Updated virtue notes")
        } else {
            print("No virtue notes found in response data")
        }

        // For virtue adjustment notes
        if let virtueAdjustmentsData = reviewData["virtue_adjustments_notes"] as? String {
            virtueAdjustmentsNotes = virtueAdjustmentsData
            print("Updated virtue adjustment notes")
        } else {
            print("No virtue adjustment notes found in response data")
        }
        
        if let serviceNotesData = reviewData["service_notes"] as? String {
            serviceNotes = serviceNotesData
            print("Updated virtue notes")
        } else {
            print("No virtue notes found in response data")
        }

        // For virtue adjustment notes
        if let serviceAdjustmentsData = reviewData["service_adjustments_notes"] as? String {
            serviceAdjustmentsNotes = serviceAdjustmentsData
            print("Updated virtue adjustment notes")
        } else {
            print("No virtue adjustment notes found in response data")
        }
        
        if let studyNotesData = reviewData["study_notes"] as? String {
            studyNotes = studyNotesData    // Make sure you have this state variable defined
            print("Updated study notes")
        } else {
            print("No study notes found in response data")
        }

        // For study adjustment notes
        if let studyAdjustmentsData = reviewData["study_adjustments_notes"] as? String {
            studyAdjustmentsNotes = studyAdjustmentsData    // Make sure you have this state variable defined
            print("Updated study adjustment notes")
        } else {
            print("No study adjustment notes found in response data")
        }

        if let massCommittedString = reviewData["is_mass_committed"] as? String {
            if massCommittedString.lowercased() == "true" {
                dailyMassCommitment = true
            } else if massCommittedString.lowercased() == "false" {
                dailyMassCommitment = false
            } else {
                dailyMassCommitment = nil
            }
            print("Updated daily Mass commitment from is_mass_committed: \(String(describing: dailyMassCommitment))")
        } else {
            print("No is_mass_committed data found in response data")
        }
        
        if let confessionCommittedString = reviewData["is_confession_committed"] as? String {
            if confessionCommittedString.lowercased() == "true" {
                regularConfession = true
            } else if confessionCommittedString.lowercased() == "false" {
                regularConfession = false
            } else {
                regularConfession = nil
            }
            print("Updated regular confession from is_confession_committed: \(String(describing: regularConfession))")
        } else {
            print("No is_confession_committed data found in response data")
        }
        
        if let bodilyFastDaysString = reviewData["bodily_fast_days"] as? String {
            print("Found bodily_fast_days string: \(bodilyFastDaysString)")
            
            if bodilyFastDaysString.starts(with: "[") {
                // JSON array format
                bodilyFastDays = parseDaysArray(bodilyFastDaysString)
                print("Parsed bodily fast days as JSON array: \(bodilyFastDays)")
            } else {
                // Legacy format if applicable
                bodilyFastDays = parseLegacyDaysString(bodilyFastDaysString)
                print("Parsed bodily fast days as legacy binary string: \(bodilyFastDays)")
            }
        } else {
            print("No bodily_fast_days string found in response data")
        }
        
        if let digitalFastDaysString = reviewData["digital_fast_days"] as? String {
            print("Found digital_fast_days string: \(digitalFastDaysString)")
            
            if digitalFastDaysString.starts(with: "[") {
                // JSON array format
                digitalFastDays = parseDaysArray(digitalFastDaysString)
                print("Parsed digital fast days as JSON array: \(digitalFastDays)")
            } else {
                // Legacy format if applicable
                digitalFastDays = parseLegacyDaysString(digitalFastDaysString)
                print("Parsed digital fast days as legacy binary string: \(digitalFastDays)")
            }
        } else {
            print("No digital_fast_days string found in response data")
        }
        
        if let massCommittedString = reviewData["is_mass_committed"] as? String {
            if massCommittedString.lowercased() == "true" {
                dailyMassCommitment = true
            } else if massCommittedString.lowercased() == "false" {
                dailyMassCommitment = false
            } else {
                dailyMassCommitment = nil
            }
            print("Updated daily Mass commitment from is_mass_committed: \(String(describing: dailyMassCommitment))")
        } else {
            print("No is_mass_committed data found in response data")
        }
        
        if let datingFastCommitmentString = reviewData["dating_fast_commitment"] as? String {
            if datingFastCommitmentString.lowercased() == "true" {
                datingFastCommitment = true
            } else if datingFastCommitmentString.lowercased() == "false" {
                datingFastCommitment = false
            } else {
                datingFastCommitment = nil
            }
            print("Updated dating fast commitment: \(String(describing: datingFastCommitment))")
        } else {
            print("No is_dating_fast_faithful data found in response data")
        }
        
        if let hmeCommitmentString = reviewData["hme_commitment"] as? String {
            if hmeCommitmentString.lowercased() == "true" {
                hmeCommitment = true
            } else if hmeCommitmentString.lowercased() == "false" {
                hmeCommitment = false
            } else {
                hmeCommitment = nil
            }
            print("Updated HME commitment: \(String(describing: hmeCommitment))")
        } else {
            print("No hme_commitment data found in response data")
        }

        if let altarServingCommitmentString = reviewData["altar_serving_commitment"] as? String {
            if altarServingCommitmentString.lowercased() == "true" {
                altarServingCommitment = true
            } else if altarServingCommitmentString.lowercased() == "false" {
                altarServingCommitment = false
            } else {
                altarServingCommitment = nil
            }
            print("Updated altar serving commitment: \(String(describing: altarServingCommitment))")
        } else {
            print("No altar_serving_commitment data found in response data")
        }
        
        if let spiritualMercyCommitmentString = reviewData["spiritual_mercy_commitment"] as? String {
            if spiritualMercyCommitmentString.lowercased() == "true" {
                spiritualMercyCommitment = true
            } else if spiritualMercyCommitmentString.lowercased() == "false" {
                spiritualMercyCommitment = false
            } else {
                spiritualMercyCommitment = nil
            }
            print("Updated spiritual mercy commitment: \(String(describing: spiritualMercyCommitment))")
        } else {
            print("No spiritual_mercy_commitment data found in response data")
        }
        
        if let corporalMercyCommitmentString = reviewData["corporal_mercy_commitment"] as? String {
            if corporalMercyCommitmentString.lowercased() == "true" {
                corporalMercyCommitment = true
            } else if corporalMercyCommitmentString.lowercased() == "false" {
                corporalMercyCommitment = false
            } else {
                corporalMercyCommitment = nil
            }
            print("Updated corporal mercy commitment: \(String(describing: corporalMercyCommitment))")
        } else {
            print("No corporal_mercy_commitment data found in response data")
        }
        
        if let spiritualReadingCommitmentString = reviewData["spiritual_reading_commitment"] as? String {
            if spiritualReadingCommitmentString.lowercased() == "true" {
                spiritualReadingCommitment = true
            } else if spiritualReadingCommitmentString.lowercased() == "false" {
                spiritualReadingCommitment = false
            } else {
                spiritualReadingCommitment = nil
            }
            print("Updated spiritual reading commitment: \(String(describing: spiritualReadingCommitment))")
        } else {
            print("No spiritual_reading data found in response data")
        }
        
        if let massScheduledDaysString = reviewData["mass_scheduled_days"] as? String {
            print("Found mass_scheduled_days string: \(massScheduledDaysString)")
            
            if massScheduledDaysString.starts(with: "[") {
                // JSON array format
                massScheduledDays = parseDaysArray(massScheduledDaysString)
                print("Parsed mass scheduled days as JSON array: \(massScheduledDays)")
            } else {
                // Legacy format if applicable
                massScheduledDays = parseLegacyDaysString(massScheduledDaysString)
                print("Parsed mass scheduled days as legacy binary string: \(massScheduledDays)")
            }
        } else {
            print("No mass_scheduled_days string found in response data")
        }
        
        if let confessionScheduledDaysString = reviewData["confession_scheduled_days"] as? String {
            print("Found confession_scheduled_days string: \(confessionScheduledDaysString)")
            
            if confessionScheduledDaysString.starts(with: "[") {
                // JSON array format
                confessionScheduledDays = parseDaysArray(confessionScheduledDaysString)
                print("Parsed confession scheduled days as JSON array: \(confessionScheduledDays)")
            } else {
                // Legacy format if applicable
                confessionScheduledDays = parseLegacyDaysString(confessionScheduledDaysString)
                print("Parsed confession scheduled days as legacy binary string: \(confessionScheduledDays)")
            }
        } else {
            print("No confession_scheduled_days string found in response data")
        }
        
        // Add this to processPrayerAndLiturgyData function
        if let meditationReadingDateString = reviewData["meditation_reading_date"] as? String {
            print("Found meditation_reading_date string: \(meditationReadingDateString)")
            
            // Create a date formatter to parse the ISO8601 date string
            let dateFormatter = ISO8601DateFormatter()
            if let parsedDate = dateFormatter.date(from: meditationReadingDateString) {
                meditationReadingDate = parsedDate
                print("Parsed meditation reading date: \(parsedDate)")
            } else {
                print("Failed to parse meditation reading date string")
            }
        } else {
            print("No meditation_reading_date string found in response data")
        }

        if let spiritualMercyScheduledString = reviewData["is_spiritual_mercy_scheduled"] as? String {
            if spiritualMercyScheduledString.lowercased() == "true" {
                isSpiritualMercyScheduled = true
            } else if spiritualMercyScheduledString.lowercased() == "false" {
                isSpiritualMercyScheduled = false
            } else {
                isSpiritualMercyScheduled = nil
            }
            print("Updated spiritual mercy scheduled: \(String(describing: isSpiritualMercyScheduled))")
        } else {
            print("No is_spiritual_mercy_scheduled data found in response data")
        }
        
        if let corporalMercyScheduledString = reviewData["is_corporal_mercy_scheduled"] as? String {
            if corporalMercyScheduledString.lowercased() == "true" {
                isCorporalMercyScheduled = true
            } else if corporalMercyScheduledString.lowercased() == "false" {
                isCorporalMercyScheduled = false
            } else {
                isCorporalMercyScheduled = nil
            }
            print("Updated corporal mercy scheduled: \(String(describing: isCorporalMercyScheduled))")
        } else {
            print("No is_corporal_mercy_scheduled data found in response data")
        }
        
        if let spiritualDirectionScheduledString = reviewData["is_spiritual_direction_scheduled"] as? String {
            if spiritualDirectionScheduledString.lowercased() == "true" {
                isSpiritualDirectionScheduled = true
            } else if spiritualDirectionScheduledString.lowercased() == "false" {
                isSpiritualDirectionScheduled = false
            } else {
                isSpiritualDirectionScheduled = nil
            }
            print("Updated spiritual direction scheduled: \(String(describing: isSpiritualDirectionScheduled))")
        } else {
            print("No is_spiritual_direction_scheduled data found in response data")
        }
                    
        if let discernmentRetreatScheduledString = reviewData["is_discernment_retreat_scheduled"] as? String {
            if discernmentRetreatScheduledString.lowercased() == "true" {
                isDiscernmentRetreatScheduled = true
            } else if discernmentRetreatScheduledString.lowercased() == "false" {
                isDiscernmentRetreatScheduled = false
            } else {
                isDiscernmentRetreatScheduled = nil
            }
            print("Updated discernment retreat scheduled: \(String(describing: isDiscernmentRetreatScheduled))")
        } else {
            print("No is_discernment_retreat_scheduled data found in response data")
        }
        
        if let seminaryVisitScheduledString = reviewData["is_seminary_visit_scheduled"] as? String {
            if seminaryVisitScheduledString.lowercased() == "true" {
                isSeminaryVisitScheduled = true
            } else if seminaryVisitScheduledString.lowercased() == "false" {
                isSeminaryVisitScheduled = false
            } else {
                isSeminaryVisitScheduled = nil
            }
            print("Updated seminary visit scheduled: \(String(describing: isSeminaryVisitScheduled))")
        } else {
            print("No is_seminary_visit_scheduled data found in response data")
        }
                    
                    
        // Print for debugging
        print("Prayer and liturgy data processing complete")
        
        // Turn off loading indicator
        isLoading = false
    }
}
struct WeekReviewView_Previews: PreviewProvider {
    static var previews: some View {
        WeekReviewView(weekNumber: 1)
    }
}
