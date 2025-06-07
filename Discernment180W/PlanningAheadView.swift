//
//  PlanningAheadView.swift
//  Discernment180W
//
//  Created by John Kim on 4/10/25.
//
import SwiftUI
@State private var massDays: [Bool] = Array(repeating: false, count: 7)
@State private var confessionDay: Int? = nil
@State private var isAltarServiceScheduled: Bool? = nil
@State private var meditationReadingDate = Date()
@State private var isSpiritualMercyScheduled: Bool? = nil
@State private var isCorporalMercyScheduled: Bool? = nil
@State private var scheduleNotes: String = ""
@State private var isSpiritualDirectionScheduled: Bool? = nil
@State private var isSeminaryVisitScheduled: Bool? = nil
@State private var isDiscernmentRetreatScheduled: Bool? = nil

struct PlanningAheadView: View {
    // Pass in the state variables as bindings
    @Binding var massDays: [Bool]
    @Binding var confessionDay: Int?
    @Binding var isAltarServiceScheduled: Bool?
    @Binding var meditationReadingDate: Date
    @Binding var isSpiritualMercyScheduled: Bool?
    @Binding var isCorporalMercyScheduled: Bool?
    @Binding var scheduleNotes: String
    @Binding var isSpiritualDirectionScheduled: Bool?
    @Binding var isSeminaryVisitScheduled: Bool?
    @Binding var isDiscernmentRetreatScheduled: Bool?
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                // Mass Days Section
                MassDaysSection(massDays: $massDays)
                
                Divider().padding(.horizontal, 16)
                
                // Confession Day Section
                ConfessionDaySection(confessionDay: $confessionDay)
                
                Divider().padding(.horizontal, 16)
                
                // Yes/No Questions - First Group
                QuestionGroup1(
                    isAltarServiceScheduled: $isAltarServiceScheduled,
                    meditationReadingDate: $meditationReadingDate
                )
                
                // Yes/No Questions - Second Group
                QuestionGroup2(
                    isSpiritualMercyScheduled: $isSpiritualMercyScheduled,
                    isCorporalMercyScheduled: $isCorporalMercyScheduled
                )
                
                // Text Editor
                NotesSection(scheduleNotes: $scheduleNotes)
                
                Divider().padding(.horizontal, 16)
                
                // Final Yes/No Questions
                QuestionGroup3(
                    isSpiritualDirectionScheduled: $isSpiritualDirectionScheduled,
                    isSeminaryVisitScheduled: $isSeminaryVisitScheduled,
                    isDiscernmentRetreatScheduled: $isDiscernmentRetreatScheduled
                )
            }
            .padding(.vertical, 8)
        }
    }
}
