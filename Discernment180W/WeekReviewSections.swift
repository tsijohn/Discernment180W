import SwiftUI

// MARK: - Section View Extension
extension WeekReviewView {
    func sectionView(title: String, isMassSection: Bool = false, isVirtueSection: Bool = false, isServiceSection: Bool = false, isStudySection: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 18))
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.leading, 16)
            
            if title == "Prayer" {
                // Prayer Section
                Text("I fulfilled my commitment to daily, personal prayer _ / 7 days this week.")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                HStack {
                    ForEach(0..<7) { index in
                        Button(action: {
                            massDays[index].toggle()
                        }) {
                            Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                                .font(.system(size: 16))
                                .foregroundColor(massDays[index] ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(massDays[index] ? Color.blue : Color(.systemGray6))
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
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                HStack {
                    ForEach(0..<7) { index in
                        Button(action: {
                            lotrDays[index].toggle()
                        }) {
                            Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                                .font(.system(size: 16))
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
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                HStack {
                    ForEach(0..<7) { index in
                        Button(action: {
                            sleepDays[index].toggle()
                        }) {
                            Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                                .font(.system(size: 16))
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
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $prayerNotes)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .id("prayerNotesField")
                }.padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on my responses, I will make the following (if any) adjustments:")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $prayerAdjustmentsNotes)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .id("prayerAdjustmentsField")
                }.padding(.bottom, 10)
                
            } else if isMassSection {
                // Sacraments Section
                HStack {
                    Text("I fulfilled my commitment to daily Mass this week.")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: { dailyMassCommitment = true }) {
                            Text("Yes")
                                .font(.system(size: 16))
                                .foregroundColor(dailyMassCommitment == true ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(dailyMassCommitment == true ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        Button(action: { dailyMassCommitment = false }) {
                            Text("No")
                                .font(.system(size: 16))
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
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: { regularConfession = true }) {
                            Text("Yes")
                                .font(.system(size: 16))
                                .foregroundColor(regularConfession == true ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(regularConfession == true ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        Button(action: { regularConfession = false }) {
                            Text("No")
                                .font(.system(size: 16))
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
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $sacramentNotes)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .id("sacramentNotesField")
                }.padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on my responses, I will make the following (if any) adjustments:")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $sacramentAdjustmentsNotes)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .id("sacramentAdjustmentsField")
                }.padding(.bottom, 10)
                
            } else if isVirtueSection {
                // Virtue Section
                Text("I was faithful to my bodily fast _ / 7 days this week.")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                HStack {
                    ForEach(0..<7) { index in
                        Button(action: {
                            bodilyFastDays[index].toggle()
                        }) {
                            Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                                .font(.system(size: 16))
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
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(.leading, 16)
                HStack {
                    ForEach(0..<7) { index in
                        Button(action: {
                            digitalFastDays[index].toggle()
                        }) {
                            Text(["S", "M", "T", "W", "Th", "F", "S"][index])
                                .font(.system(size: 16))
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
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: { datingFastCommitment = true }) {
                            Text("Yes")
                                .font(.system(size: 16))
                                .foregroundColor(datingFastCommitment == true ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(datingFastCommitment == true ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        Button(action: { datingFastCommitment = false }) {
                            Text("No")
                                .font(.system(size: 16))
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
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: { hmeCommitment = true }) {
                            Text("Yes")
                                .font(.system(size: 16))
                                .foregroundColor(hmeCommitment == true ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(hmeCommitment == true ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        Button(action: { hmeCommitment = false }) {
                            Text("No")
                                .font(.system(size: 16))
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
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $virtueNotes)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .id("virtueNotesField")
                }.padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on my responses, I will make the following (if any) adjustments:")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $virtueAdjustmentsNotes)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .id("virtueAdjustmentsField")
                }.padding(.bottom, 10)
                
            } else if isServiceSection {
                // Service Section
                HStack {
                    Text("I fulfilled (or am on track to fulfill) my commitment to altar serving.")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: { altarServingCommitment = true }) {
                            Text("Yes")
                                .font(.system(size: 16))
                                .foregroundColor(altarServingCommitment == true ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(altarServingCommitment == true ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        Button(action: { altarServingCommitment = false }) {
                            Text("No")
                                .font(.system(size: 16))
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
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: { spiritualMercyCommitment = true }) {
                            Text("Yes")
                                .font(.system(size: 16))
                                .foregroundColor(spiritualMercyCommitment == true ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(spiritualMercyCommitment == true ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        Button(action: { spiritualMercyCommitment = false }) {
                            Text("No")
                                .font(.system(size: 16))
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
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: { corporalMercyCommitment = true }) {
                            Text("Yes")
                                .font(.system(size: 16))
                                .foregroundColor(corporalMercyCommitment == true ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(corporalMercyCommitment == true ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        Button(action: { corporalMercyCommitment = false }) {
                            Text("No")
                                .font(.system(size: 16))
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
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $serviceNotes)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .id("serviceNotesField")
                }.padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on my responses, I will make the following (if any) adjustments:")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $serviceAdjustmentsNotes)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .id("serviceAdjustmentsField")
                }.padding(.bottom, 10)
                
            } else if isStudySection {
                // Study Section
                HStack {
                    Text("Have I fulfilled my commitment to spiritual reading?")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    Spacer()
                    HStack {
                        Button(action: { spiritualReadingCommitment = true }) {
                            Text("Yes")
                                .font(.system(size: 16))
                                .foregroundColor(spiritualReadingCommitment == true ? .white : .black)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(spiritualReadingCommitment == true ? Color.blue : Color.white)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.black, lineWidth: 1))
                        }
                        Button(action: { spiritualReadingCommitment = false }) {
                            Text("No")
                                .font(.system(size: 16))
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
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $studyNotes)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .id("studyNotesField")
                }.padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Based on my responses, I will make the following (if any) adjustments:")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(.leading, 16)
                    
                    TextEditor(text: $studyAdjustmentsNotes)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding(8)
                        .frame(height: 100)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .id("studyAdjustmentsField")
                }.padding(.bottom, 10)
                
            } else {
                // Default section
                Text(loremIpsumText())
                    .font(.system(size: 16))
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
}