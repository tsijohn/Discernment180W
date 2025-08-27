import SwiftUI
import WebKit

struct SplashScreenView: View {
    @State private var showNextView = false
    @State private var isActive = false
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            // Blue background
            Color(hex: "#132A47")
                .ignoresSafeArea()
            
            VStack {
                Spacer()

                VStack(spacing: 5) { // Spacing between text elements
                    Image("d180_app_icon") // Make sure "app_icon" exists in Assets.xcassets
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 240, height: 240) // Adjust size as needed
                        .padding(.bottom, 5)
                        .padding(.top, -110)
                        .foregroundColor(.white) // Apply white tint

                    Text("A Six-Month Guide for Catholic Men to Discern the Priesthood")
                        .font(.system(size: 25, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.top, 15)
                }
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showNextView = true
            }
        }
        .fullScreenCover(isPresented: $showNextView) {
            if authViewModel.isAuthenticated {
                HomePageView()
                    .environmentObject(authViewModel)
                    .environmentObject(appState)
            } else {
                VideoPlayerView()
                    .environmentObject(authViewModel)
                    .environmentObject(appState)
            }
        }
    }
}
