import SwiftUI
import AVKit

struct VideoPlayerView: View {
    @State private var showPreviewPage = false
    @State private var showSignUpPage = false
    @State private var isVideoPlaying = true // Track video playback state

    let videoURL = URL(string: "https://discernment180.s3.us-east-2.amazonaws.com/welcome_to_discernment_180.mp4")!

    var body: some View {
        ZStack {
            Color(red: 19 / 255, green: 42 / 255, blue: 71 / 255)
                .ignoresSafeArea()

            VStack {
                AVPlayerView(url: videoURL, isPlaying: $isVideoPlaying)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: 20) {
                    Button(action: {
                        isVideoPlaying = false // Stop video when navigating
                        showPreviewPage = true
                    }) {
                        Text("Still not sure")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                    }
                    .frame(height: 50)

                    Button(action: {
                        isVideoPlaying = false // Stop video when navigating
                        showSignUpPage = true
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
                }
                .padding(.bottom, 30)
            }
        }
        .fullScreenCover(isPresented: $showPreviewPage) {
            PreviewPage()
        }
        .fullScreenCover(isPresented: $showSignUpPage) {
            SignUpPageView()
        }
    }
}

// Updated AVPlayerView with binding to control playback
struct AVPlayerView: View {
    let url: URL
    private let player: AVPlayer
    @Binding var isPlaying: Bool

    init(url: URL, isPlaying: Binding<Bool>) {
        self.url = url
        self.player = AVPlayer(url: url)
        self._isPlaying = isPlaying
    }

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                if isPlaying {
                    player.play()
                }
            }
            .onChange(of: isPlaying) { playing in
                if playing {
                    player.play()
                } else {
                    player.pause()
                }
            }
            .onDisappear {
                player.pause()
            }
    }
}

// Dummy Preview Page
struct PreviewPage: View {
    var body: some View {
        Text("Preview Page")
            .font(.largeTitle)
            .foregroundColor(.black)
            .padding()
    }
}

