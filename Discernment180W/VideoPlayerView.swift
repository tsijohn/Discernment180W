import SwiftUI
import AVKit
import AVFoundation

struct VideoPlayerView: View {
    @State private var showPreviewPage = false
    @State private var showSignUpPage = false
    @State private var showLoginPage = false
    @State private var isVideoPlaying = true
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    let videoURL = URL(string: "https://discernment180.s3.us-east-2.amazonaws.com/welcome_to_discernment_180.mp4")!

    var body: some View {
        ZStack {
            Color(red: 19 / 255, green: 42 / 255, blue: 71 / 255)
                .ignoresSafeArea()

            VStack {
                Text("Intro to D180")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)

                AVPlayerView(url: videoURL, isPlaying: $isVideoPlaying)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 20) {
                    Button(action: {
                        isVideoPlaying = false
                        if authViewModel.isAuthenticated {
                            showSignUpPage = true
                        } else {
                            showSignUpPage = true
                        }
                    }) {
                        Text("Begin Program")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 216 / 255, green: 158 / 255, blue: 99 / 255))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                    }
                    .frame(height: 50)

                    Button(action: {
                        // Disabled for now
                    }) {
                        Text("Preview Day 0")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.5))
                            .foregroundColor(.white.opacity(0.6))
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                    }
                    .frame(height: 50)
                    .disabled(true)
                    
                    if !authViewModel.isAuthenticated {
                        Button(action: {
                            isVideoPlaying = false
                            showLoginPage = true
                        }) {
                            Text("Already have an account? Sign In")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .fullScreenCover(isPresented: $showPreviewPage) {
            PreviewPage()
        }
        .fullScreenCover(isPresented: $showSignUpPage) {
            SignUpPageView()
                .environmentObject(authViewModel)
                .environmentObject(AppState())
        }
        .fullScreenCover(isPresented: $showLoginPage) {
            LoginView()
                .environmentObject(authViewModel)
        }
    }
}

// AVPlayerView with muted audio and subtitles enabled
struct AVPlayerView: View {
    let url: URL
    @Binding var isPlaying: Bool
    @State private var player: AVPlayer?
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                setupPlayerWithSubtitles()
            }
            .onChange(of: isPlaying) { playing in
                if playing {
                    player?.play()
                } else {
                    player?.pause()
                }
            }
            .onDisappear {
                player?.pause()
                player = nil
            }
    }
    
    private func setupPlayerWithSubtitles() {
        // Create and configure player
        let newPlayer = AVPlayer(url: url)
        
        // MUTE the audio
        newPlayer.isMuted = true
        newPlayer.volume = 0.0
        
        // Configure the player item for subtitles
        if let currentItem = newPlayer.currentItem {
            // Enable subtitles/closed captions if available
            configureSubtitles(for: currentItem)
        }
        
        self.player = newPlayer
        
        // Start playing after a short delay to ensure everything is set up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if isPlaying {
                newPlayer.play()
            }
        }
    }
    
    private func configureSubtitles(for playerItem: AVPlayerItem) {
        // Get available media selection groups
        let asset = playerItem.asset
        
        // Try to find and enable subtitles/closed captions
        Task {
            do {
                // Load the available media characteristics
                let characteristics = try await asset.load(.availableMediaCharacteristicsWithMediaSelectionOptions)
                
                // Check for legible (subtitle/caption) content
                if characteristics.contains(.legible) {
                    if let group = try await asset.loadMediaSelectionGroup(for: .legible) {
                        // Get available subtitle options
                        let options = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options, with: Locale.current)
                        
                        // Select the first available subtitle option (usually the default)
                        if let subtitleOption = options.first {
                            await MainActor.run {
                                playerItem.select(subtitleOption, in: group)
                            }
                        } else if let firstOption = group.options.first {
                            // If no locale-specific option, use the first available
                            await MainActor.run {
                                playerItem.select(firstOption, in: group)
                            }
                        }
                    }
                }
                
                // Also check for closed captions
                if characteristics.contains(.containsOnlyForcedSubtitles) {
                    if let group = try await asset.loadMediaSelectionGroup(for: .legible) {
                        // Enable forced subtitles
                        let forcedOptions = AVMediaSelectionGroup.mediaSelectionOptions(from: group.options,
                                                                                       withMediaCharacteristics: [.containsOnlyForcedSubtitles])
                        if let forcedOption = forcedOptions.first {
                            await MainActor.run {
                                playerItem.select(forcedOption, in: group)
                            }
                        }
                    }
                }
            } catch {
                print("Error configuring subtitles: \(error)")
            }
        }
        
        // Also try to enable accessibility features for subtitles
        playerItem.appliesPerFrameHDRDisplayMetadata = true
        
        // If the video has embedded captions, this will ensure they're visible
        if let textStyleRules = playerItem.textStyleRules {
            playerItem.textStyleRules = textStyleRules
        } else {
            // Create default text style rules for better subtitle visibility
            let textStyleRule = AVTextStyleRule(textMarkupAttributes: [
                kCMTextMarkupAttribute_ForegroundColorARGB: [1.0, 1.0, 1.0, 1.0],
                kCMTextMarkupAttribute_BackgroundColorARGB: [0.5, 0.0, 0.0, 0.0],
                kCMTextMarkupAttribute_RelativeFontSize: 100,
                kCMTextMarkupAttribute_BoldStyle: true
            ] as [String : Any])
            
            if let rule = textStyleRule {
                playerItem.textStyleRules = [rule]
            }
        }
    }
}

struct PreviewPage: View {
    var body: some View {
        Text("Preview Page")
            .font(.largeTitle)
            .foregroundColor(.black)
            .padding()
    }
}
