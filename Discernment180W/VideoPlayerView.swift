import SwiftUI
import AVKit
import AVFoundation

struct VideoPlayerView: View {
    @State private var showPreviewPage = false
    @State private var showSignUpPage = false
    @State private var showLoginPage = false
    @State private var showDay0Preview = false
    @State private var isVideoPlaying = true
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    var videoURL: URL? {
        Bundle.main.url(forResource: "welcome_to_discernment_180 (720p)", withExtension: "mp4")
    }
    // Use bundled VTT subtitle file
    var subtitleURL: URL? {
        Bundle.main.url(forResource: "auto_generated_captions", withExtension: "vtt")
    }
    var body: some View {
        ZStack {
            Color(red: 19 / 255, green: 42 / 255, blue: 71 / 255)
                .ignoresSafeArea()

            VStack {
                Text("Intro to D180")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 25)

                if let videoURL = videoURL {
                    AVPlayerView(url: videoURL, subtitleURL: subtitleURL, isPlaying: $isVideoPlaying)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scaleEffect(1.10)
                        .clipped()
                } else {
                    // Show error message if video file not found
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.6))
                        Text("Video file not found")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

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
                        isVideoPlaying = false
                        showDay0Preview = true
                    }) {
                        Text("Preview Day 0")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 50)

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
        .fullScreenCover(isPresented: $showDay0Preview) {
            Day0View()
                .environmentObject(authViewModel)
                .environmentObject(AppState())
        }
    }
}

// Subtitle model
struct Subtitle: Identifiable {
    let id = UUID()
    let startTime: TimeInterval
    let endTime: TimeInterval
    let text: String
}

// VTT Parser
class VTTParser {
    static func parse(vttContent: String) -> [Subtitle] {
        var subtitles: [Subtitle] = []
        let lines = vttContent.components(separatedBy: .newlines)
        var i = 0
        
        while i < lines.count {
            let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Look for timestamp line (contains -->)
            if line.contains("-->") {
                let times = line.components(separatedBy: "-->")
                if times.count == 2 {
                    let startTime = parseTime(times[0].trimmingCharacters(in: .whitespaces))
                    let endTime = parseTime(times[1].trimmingCharacters(in: .whitespaces))
                    
                    // Collect subtitle text (next non-empty lines until empty line or next timestamp)
                    var subtitleText = ""
                    i += 1
                    while i < lines.count {
                        let textLine = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                        if textLine.isEmpty || textLine.contains("-->") {
                            break
                        }
                        if !subtitleText.isEmpty {
                            subtitleText += "\n"
                        }
                        subtitleText += textLine
                        i += 1
                    }
                    
                    if !subtitleText.isEmpty {
                        subtitles.append(Subtitle(startTime: startTime, endTime: endTime, text: subtitleText))
                    }
                    continue
                }
            }
            i += 1
        }
        
        return subtitles
    }
    
    static func parseTime(_ timeString: String) -> TimeInterval {
        // Parse VTT time format: HH:MM:SS.mmm or MM:SS.mmm
        let components = timeString.components(separatedBy: ":")
        var seconds: TimeInterval = 0
        
        if components.count == 3 {
            // HH:MM:SS.mmm
            seconds += (Double(components[0]) ?? 0) * 3600
            seconds += (Double(components[1]) ?? 0) * 60
            seconds += Double(components[2].replacingOccurrences(of: ",", with: ".")) ?? 0
        } else if components.count == 2 {
            // MM:SS.mmm
            seconds += (Double(components[0]) ?? 0) * 60
            seconds += Double(components[1].replacingOccurrences(of: ",", with: ".")) ?? 0
        }
        
        return seconds
    }
}

// AVPlayerView with muted audio and subtitles enabled
struct AVPlayerView: View {
    let url: URL
    let subtitleURL: URL? // Optional VTT subtitle file URL
    @Binding var isPlaying: Bool
    @State private var player: AVPlayer?
    @State private var isMuted: Bool = true
    @State private var subtitles: [Subtitle] = []
    @State private var currentSubtitle: String = ""
    @State private var timeObserver: Any?
    
    var body: some View {
        ZStack {
            VideoPlayer(player: player)
                .onAppear {
                    setupPlayer()
                    if let subtitleURL = subtitleURL {
                        loadSubtitles(from: subtitleURL)
                    }
                }
                .onChange(of: isPlaying) { playing in
                    if playing {
                        player?.play()
                    } else {
                        player?.pause()
                    }
                }
                .onChange(of: isMuted) { muted in
                    player?.isMuted = muted
                    player?.volume = muted ? 0.0 : 1.0
                }
                .onDisappear {
                    if let observer = timeObserver {
                        player?.removeTimeObserver(observer)
                    }
                    player?.pause()
                    player = nil
                }
            
            // Subtitle overlay
            VStack {
                Spacer()
                
                if !currentSubtitle.isEmpty {
                    Text(currentSubtitle)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                        .padding(.bottom, 20) // Moved much closer to bottom
                }
                
                // Mute/Unmute button overlay
                HStack {
                    Spacer()
                    Button(action: {
                        isMuted.toggle()
                    }) {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
    
    private func setupPlayer() {
        // Create and configure player
        let newPlayer = AVPlayer(url: url)
        
        // Set initial audio state
        newPlayer.isMuted = isMuted
        newPlayer.volume = isMuted ? 0.0 : 1.0
        
        self.player = newPlayer
        
        // Add time observer for subtitle updates
        let interval = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserver = newPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            Task { @MainActor in
                self.updateSubtitle(for: time.seconds)
            }
        }
        
        // Start playing after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.isPlaying {
                newPlayer.play()
            }
        }
    }
    
    private func loadSubtitles(from url: URL) {
        Task {
            do {
                // Download VTT file
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // Convert data to string
                if let vttContent = String(data: data, encoding: .utf8) {
                    // Parse VTT content
                    let parsedSubtitles = VTTParser.parse(vttContent: vttContent)
                    
                    await MainActor.run {
                        self.subtitles = parsedSubtitles
                        print("Loaded \(parsedSubtitles.count) subtitles")
                    }
                }
            } catch {
                print("Error loading VTT file: \(error)")
            }
        }
    }
    
    private func updateSubtitle(for currentTime: TimeInterval) {
        // Find the subtitle that should be displayed at the current time
        let subtitle = subtitles.first { subtitle in
            currentTime >= subtitle.startTime && currentTime <= subtitle.endTime
        }
        
        // Update the displayed subtitle
        if let subtitle = subtitle {
            if currentSubtitle != subtitle.text {
                currentSubtitle = subtitle.text
            }
        } else {
            if !currentSubtitle.isEmpty {
                currentSubtitle = ""
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
