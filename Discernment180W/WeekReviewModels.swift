import Foundation

// MARK: - Planning Ahead Data Structure
struct PlanningAheadData {
    let massScheduledDays: [Bool]
    let confessionScheduledDays: [Bool]
    let altarServiceScheduled: Bool?
    let spiritualMercyScheduled: Bool?
    let corporalMercyScheduled: Bool?
    let spiritualDirectionScheduled: Bool?
    let seminaryVisitScheduled: Bool?
    let discernmentRetreatScheduled: Bool?
    let scheduleNotes: String
}

// MARK: - Rule of Life Display Data
struct RuleOfLifeDisplayData {
    let prayerMinutes: String
    let prayerTimeFrom: String
    let prayerTimeTo: String
    let wakeUpTime: String
    let bedTime: String
    let additionalHours: String
    let massTimesPerWeek: String
    let additionalMassDays: String
    let confessionTimesPerMonth: String
    let digitalFast: String
    let bodilyFast: String
    let chastityPractices: String
    let altarServerParish: String
    let spiritualWorkOfMercy: String
    let corporalWorkOfMercy: String
    let readingMinutesPerDay: String
    let readingDaysPerWeek: String
    let datingFastCommitment: Bool
    let dismissRomanticInterests: Bool
    let avoidOneOnOne: Bool
    let spiritualDirectorName: String
    let seminaryName: String
    let seminaryVisitDate: String
    let retreatName: String
    let retreatDate: String
}