//
//  WeekPreviewView.swift
//  Discernment180W
//
//  Created by John Kim on 1/8/25.
//

import SwiftUI

struct WeekPreviewView: View {
    @Environment(\.presentationMode) var presentationMode // For navigating back

    var body: some View {
        ZStack {
            Color(.systemGray6) // Light grey background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Spacer()

                    // Header with title
                    Text("Week 2 Preview")
                        .font(.custom("Georgia", size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 10)

                    Spacer()
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Prayer Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Prayer")
                                .font(.custom("Georgia", size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.leading, 16) // Added left padding

                            Text(loremIpsumText())
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(.black)
                                .lineSpacing(5)
                                .padding(.horizontal)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                        }

                        // Study Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Study")
                                .font(.custom("Georgia", size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.leading, 16) // Added left padding

                            Text(loremIpsumText())
                                .font(.custom("Georgia", size: 16))
                                .foregroundColor(.black)
                                .lineSpacing(5)
                                .padding(.horizontal)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 20)
                }

                Spacer()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Sample lorem ipsum text
    func loremIpsumText() -> String {
        return """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
        """
    }
}

struct WeekPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        WeekPreviewView()
    }
}

