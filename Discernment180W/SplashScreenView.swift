import SwiftUI
import WebKit

struct SplashScreenView: View {
    @State private var showNextView = false
    @EnvironmentObject var authViewModel: AuthViewModel // Authentication state

    var body: some View {
        ZStack {
            // Blue background
            Color(hex: "#132A47")
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                VStack(spacing: 30) { // Spacing between text elements
                    Text("ARE YOU CALLED?")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text("DISCERNMENT 180")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("A Six-Month Guide for Catholic Men to Discern the Priesthood")
                        .font(.system(size: 20, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
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
            if authViewModel.isLoggedIn {
                HomePageView()
            } else {
                VideoPlayerView()
            }
        }
    }
}

