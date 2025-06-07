
import SwiftUI

struct PlanningAheadView: View {
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
            Text("Planning Ahead")
                .font(.custom("Georgia", size: 18))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.leading, 16)
            
            // Planning Ahead Section
            Text("What day(s) will I go to Mass this week?")
                .font(.custom("Georgia", size: 16))
                .foregroundColor(.black)
                .padding(.leading, 16)
            HStack {
                ForEach(0..<7) { index in
                    Button(action: {
                        massScheduledDays[index].toggle()
                    }) {
                        Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(massScheduledDays[index] ? .white : .black)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(massScheduledDays[index] ? Color.blue : Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                }
            }.padding(.bottom, 10)
                .padding(.leading, 16)
            
            Text("What day(s) will I go to Confession this week?")
                .font(.custom("Georgia", size: 16))
                .foregroundColor(.black)
                .padding(.leading, 16)
            HStack {
                ForEach(0..<7) { index in
                    Button(action: {
                        confessionScheduledDays[index].toggle()
                    }) {
                        Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(confessionScheduledDays[index] ? .white : .black)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(confessionScheduledDays[index] ? Color.blue : Color.white)
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
                Text("When will I make extra time to read the excursus on meditation this week?")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
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
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                Spacer()
                HStack {
                    Button(action: { isSpiritualMercyScheduled = true }) {
                        Text("Yes")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(isSpiritualMercyScheduled == true ? .white : .black)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(isSpiritualMercyScheduled == true ? Color.blue : Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    }
                    Button(action: { isSpiritualMercyScheduled = false }) {
                        Text("No")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(isSpiritualMercyScheduled == false ? .white : .black)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(isSpiritualMercyScheduled == false ? Color.blue : Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    }
                }
                .padding(.trailing, 16)
            }.padding(.bottom, 10)
            
            HStack {
                Text("Corporal works of mercy?")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                Spacer()
                HStack {
                    Button(action: { isCorporalMercyScheduled = true }) {
                        Text("Yes")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(isCorporalMercyScheduled == true ? .white : .black)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(isCorporalMercyScheduled == true ? Color.blue : Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    }
                    Button(action: { isCorporalMercyScheduled = false }) {
                        Text("No")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(isCorporalMercyScheduled == false ? .white : .black)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(isCorporalMercyScheduled == false ? Color.blue : Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    }
                }
                .padding(.trailing, 16)
            }.padding(.bottom, 10)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("What and when?")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                
                TextEditor(text: $scheduleNotes)
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(8)
                    .frame(height: 40)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
            }.padding(.bottom, 10)
            
            HStack {
                Text("Have I scheduled my next spiritual direction?")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                Spacer()
                HStack {
                    Button(action: { isSpiritualDirectionScheduled = true }) {
                        Text("Yes")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(isSpiritualDirectionScheduled == true ? .white : .black)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(isSpiritualDirectionScheduled == true ? Color.blue : Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    }
                    Button(action: { isSpiritualDirectionScheduled = false }) {
                        Text("No")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(isSpiritualDirectionScheduled == false ? .white : .black)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(isSpiritualDirectionScheduled == false ? Color.blue : Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    }
                }
                .padding(.trailing, 16)
            }.padding(.bottom, 10)
            
            HStack {
                Text("Have I scheduled my seminary visit?")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                Spacer()
                HStack {
                    Button(action: { isSeminaryVisitScheduled = true }) {
                        Text("Yes")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(isSeminaryVisitScheduled == true ? .white : .black)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(isSeminaryVisitScheduled == true ? Color.blue : Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    }
                    Button(action: { isSeminaryVisitScheduled = false }) {
                        Text("No")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(isSeminaryVisitScheduled == false ? .white : .black)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(isSeminaryVisitScheduled == false ? Color.blue : Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    }
                }
                .padding(.trailing, 16)
            }.padding(.bottom, 10)
            
            HStack {
                Text("Have I scheduled my discernment retreat?")
                    .font(.custom("Georgia", size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                Spacer()
                HStack {
                    Button(action: { isDiscernmentRetreatScheduled = true }) {
                        Text("Yes")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(isDiscernmentRetreatScheduled == true ? .white : .black)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(isDiscernmentRetreatScheduled == true ? Color.blue : Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    }
                    Button(action: { isDiscernmentRetreatScheduled = false }) {
                        Text("No")
                            .font(.custom("Georgia", size: 16))
                            .foregroundColor(isDiscernmentRetreatScheduled == false ? .white : .black)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(isDiscernmentRetreatScheduled == false ? Color.blue : Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                    }
                }
                .padding(.trailing, 16)
            }.padding(.bottom, 10)
        }
        .background(Color(.systemGray6))
    }
}

struct PlanningAheadView_Previews: PreviewProvider {
    @State static var massScheduledDays: [Bool] = Array(repeating: false, count: 7)
    @State static var confessionScheduledDays: [Bool] = Array(repeating: false, count: 7)
    @State static var meditationReadingDate = Date()
    @State static var spiritualMercyScheduled: Bool? = nil
    @State static var corporalMercyScheduled: Bool? = nil
    @State static var scheduleNotes = ""
    @State static var spiritualDirectionScheduled: Bool? = nil
    @State static var seminaryVisitScheduled: Bool? = nil
    @State static var discernmentRetreatScheduled: Bool? = nil
    
    static var previews: some View {
        PlanningAheadView(
            massScheduledDays: $massScheduledDays,
            confessionScheduledDays: $confessionScheduledDays,
            meditationReadingDate: $meditationReadingDate,
            isSpiritualMercyScheduled: $spiritualMercyScheduled,
            isCorporalMercyScheduled: $corporalMercyScheduled,
            scheduleNotes: $scheduleNotes,
            isSpiritualDirectionScheduled: $spiritualDirectionScheduled,
            isSeminaryVisitScheduled: $seminaryVisitScheduled,
            isDiscernmentRetreatScheduled: $discernmentRetreatScheduled
        )
    }
}
