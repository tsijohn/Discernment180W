import SwiftUI

struct MyPlanningAheadView: View {
    // Environment for color scheme detection
    @Environment(\.colorScheme) var colorScheme

    // State properties from the original view
    @Binding var massScheduledDays: [Bool]
    @Binding var confessionScheduledDays: [Bool]
    @Binding var meditationReadingDate: Date
    @Binding var isSpiritualMercyScheduled: Bool?
    @Binding var isCorporalMercyScheduled: Bool?
    @Binding var scheduleNotes: String
    @Binding var isSpiritualDirectionScheduled: Bool?
    @Binding var isSeminaryVisitScheduled: Bool?
    @Binding var isDiscernmentRetreatScheduled: Bool?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Planning Ahead Section
            Text("What day(s) will I go to Mass this week?")
                .font(.system(size: 16))
                .foregroundColor(AppColors.primaryText) // Changed from .black
                .padding(.leading, 16)
            HStack {
                ForEach(0..<7) { index in
                    Button(action: {
                        massScheduledDays[index].toggle()
                    }) {
                        Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                            .font(.system(size: 16))
                            .foregroundColor(massScheduledDays[index] ? .white : AppColors.primaryText) // Adaptive text
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(massScheduledDays[index] ? Color.blue : AppColors.secondaryBackground) // Adaptive background
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.separator, lineWidth: 1) // Adaptive border
                            )
                    }
                }
            }.padding(.bottom, 10)
                .padding(.leading, 16)

            Text("What day(s) will I go to Confession this week?")
                .font(.system(size: 16))
                .foregroundColor(AppColors.primaryText) // Changed from .black
                .padding(.leading, 16)
            HStack {
                ForEach(0..<7) { index in
                    Button(action: {
                        confessionScheduledDays[index].toggle()
                    }) {
                        Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                            .font(.system(size: 16))
                            .foregroundColor(confessionScheduledDays[index] ? .white : AppColors.primaryText) // Adaptive text
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(confessionScheduledDays[index] ? Color.blue : AppColors.secondaryBackground) // Adaptive background
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.separator, lineWidth: 1) // Adaptive border
                            )
                    }
                }
            }.padding(.bottom, 10)
                .padding(.leading, 16)

            HStack {
                Text("When will I make extra time to read the excursus on meditation this week?")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primaryText) // Changed from .black
                    .padding(.leading, 16)
                    .lineLimit(2)
                Spacer()
                DatePicker(
                    "",
                    selection: $meditationReadingDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
                .padding(.trailing, 16)
            }
            .padding(.bottom, 10)

            HStack {
                Text("Spiritual works of mercy?")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primaryText) // Changed from .black
                    .padding(.leading, 16)
                Spacer()
                HStack {
                    Button(action: { isSpiritualMercyScheduled = true }) {
                        Text("Yes")
                            .font(.system(size: 16))
                            .foregroundColor(isSpiritualMercyScheduled == true ? .white : AppColors.primaryText) // Adaptive
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(isSpiritualMercyScheduled == true ? Color.blue : AppColors.secondaryBackground) // Adaptive
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.separator, lineWidth: 1) // Adaptive border
                            )
                    }

                    Button(action: { isSpiritualMercyScheduled = false }) {
                        Text("No")
                            .font(.system(size: 16))
                            .foregroundColor(isSpiritualMercyScheduled == false ? .white : AppColors.primaryText) // Adaptive
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(isSpiritualMercyScheduled == false ? Color.blue : AppColors.secondaryBackground) // Adaptive
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.separator, lineWidth: 1) // Adaptive border
                            )
                    }
                }
                .padding(.trailing, 16)
            }
            .padding(.bottom, 10)

            HStack {
                Text("Corporal works of mercy?")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primaryText) // Changed from .black
                    .padding(.leading, 16)
                Spacer()
                HStack {
                    Button(action: { isCorporalMercyScheduled = true }) {
                        Text("Yes")
                            .font(.system(size: 16))
                            .foregroundColor(isCorporalMercyScheduled == true ? .white : AppColors.primaryText) // Adaptive
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(isCorporalMercyScheduled == true ? Color.blue : AppColors.secondaryBackground) // Adaptive
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.separator, lineWidth: 1) // Adaptive border
                            )
                    }

                    Button(action: { isCorporalMercyScheduled = false }) {
                        Text("No")
                            .font(.system(size: 16))
                            .foregroundColor(isCorporalMercyScheduled == false ? .white : AppColors.primaryText) // Adaptive
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(isCorporalMercyScheduled == false ? Color.blue : AppColors.secondaryBackground) // Adaptive
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.separator, lineWidth: 1) // Adaptive border
                            )
                    }
                }
                .padding(.trailing, 16)
            }
            .padding(.bottom, 10)

            VStack(alignment: .leading, spacing: 10) {
                // Continue with Seminary/Order visit question
                Text("Are you going to visit a Seminary or Religious Order this week?")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primaryText) // Changed from .black
                    .padding(.leading, 16)

                HStack {
                    Spacer()
                    HStack {
                        Button(action: { isSeminaryVisitScheduled = true }) {
                            Text("Yes")
                                .font(.system(size: 16))
                                .foregroundColor(isSeminaryVisitScheduled == true ? .white : AppColors.primaryText) // Adaptive
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(isSeminaryVisitScheduled == true ? Color.blue : AppColors.secondaryBackground) // Adaptive
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppColors.separator, lineWidth: 1) // Adaptive border
                                )
                        }

                        Button(action: { isSeminaryVisitScheduled = false }) {
                            Text("No")
                                .font(.system(size: 16))
                                .foregroundColor(isSeminaryVisitScheduled == false ? .white : AppColors.primaryText) // Adaptive
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(isSeminaryVisitScheduled == false ? Color.blue : AppColors.secondaryBackground) // Adaptive
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppColors.separator, lineWidth: 1) // Adaptive border
                                )
                        }
                    }
                    .padding(.trailing, 16)
                }
                .padding(.bottom, 10)

                // Spiritual direction question
                Text("Are you going to meet for Spiritual Direction this week?")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primaryText) // Changed from .black
                    .padding(.leading, 16)

                HStack {
                    Spacer()
                    HStack {
                        Button(action: { isSpiritualDirectionScheduled = true }) {
                            Text("Yes")
                                .font(.system(size: 16))
                                .foregroundColor(isSpiritualDirectionScheduled == true ? .white : AppColors.primaryText) // Adaptive
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(isSpiritualDirectionScheduled == true ? Color.blue : AppColors.secondaryBackground) // Adaptive
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppColors.separator, lineWidth: 1) // Adaptive border
                                )
                        }

                        Button(action: { isSpiritualDirectionScheduled = false }) {
                            Text("No")
                                .font(.system(size: 16))
                                .foregroundColor(isSpiritualDirectionScheduled == false ? .white : AppColors.primaryText) // Adaptive
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(isSpiritualDirectionScheduled == false ? Color.blue : AppColors.secondaryBackground) // Adaptive
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppColors.separator, lineWidth: 1) // Adaptive border
                                )
                        }
                    }
                    .padding(.trailing, 16)
                }
                .padding(.bottom, 10)

                // Discernment retreat question
                Text("Are you signed up for a Discernment Retreat?")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primaryText) // Changed from .black
                    .padding(.leading, 16)

                HStack {
                    Spacer()
                    HStack {
                        Button(action: { isDiscernmentRetreatScheduled = true }) {
                            Text("Yes")
                                .font(.system(size: 16))
                                .foregroundColor(isDiscernmentRetreatScheduled == true ? .white : AppColors.primaryText) // Adaptive
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(isDiscernmentRetreatScheduled == true ? Color.blue : AppColors.secondaryBackground) // Adaptive
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppColors.separator, lineWidth: 1) // Adaptive border
                                )
                        }

                        Button(action: { isDiscernmentRetreatScheduled = false }) {
                            Text("No")
                                .font(.system(size: 16))
                                .foregroundColor(isDiscernmentRetreatScheduled == false ? .white : AppColors.primaryText) // Adaptive
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(isDiscernmentRetreatScheduled == false ? Color.blue : AppColors.secondaryBackground) // Adaptive
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppColors.separator, lineWidth: 1) // Adaptive border
                                )
                        }
                    }
                    .padding(.trailing, 16)
                }
                .padding(.bottom, 10)

                // Notes section
                Text("Notes:")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primaryText) // Changed from .black
                    .padding(.leading, 16)

                TextEditor(text: $scheduleNotes)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primaryText) // Adaptive text
                    .background(AppColors.secondaryBackground) // Adaptive background
                    .frame(minHeight: 100)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.separator, lineWidth: 1) // Adaptive border
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
            }
        }
        .background(AppColors.primaryBackground) // Adaptive main background
    }
}

// MARK: - Dark Mode Migration Notes
/*
 Changes made for dark mode support:

 1. Added @Environment(\.colorScheme) to detect current color scheme
 2. Replaced all Color.white backgrounds with AppColors.secondaryBackground
 3. Replaced all Color.black text with AppColors.primaryText
 4. Replaced all Color.black borders with AppColors.separator
 5. Background colors now use adaptive system colors
 6. Text colors automatically adapt to the current color scheme
 7. Button states maintain visibility in both light and dark modes

 The AppColors system provides:
 - Automatic adaptation between light/dark modes
 - Consistent theming across the app
 - Better accessibility and contrast ratios
 - System-level color integration
*/