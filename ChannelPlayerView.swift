import SwiftUI
import MobileVLCKit

struct ChannelPlayerView: View {
    @Binding var channels: [ChannelModel]
    @Binding var currentIndex: Int
    
    @StateObject private var playerViewModel = VLCPlayerViewModel()
    @State private var isControlsVisible = false
    @State private var currentTime: Float = 0
    @State private var duration: Float = 0

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            ZStack {
                VLCVideoView(playerViewModel: playerViewModel)
                    .onAppear {
                        playerViewModel.player.media = VLCMedia(url: URL(string: channels[currentIndex].url)!)
                        playerViewModel.player.play()
                    }
                    .onDisappear {
                        playerViewModel.player.stop()
                    }
                    .onTapGesture {
                        isControlsVisible.toggle()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            isControlsVisible = false
                        }
                    }
                    .edgesIgnoringSafeArea(.all)

                if isControlsVisible {
                    VStack {
                        Spacer()
                        HStack {
                            Text("\(Int(currentTime / 60)):\(Int(currentTime.truncatingRemainder(dividingBy: 60)))")
                            Slider(value: $currentTime, in: 0...duration) { _ in
                                playerViewModel.player.position = currentTime / duration
                            }
                            Text("\(Int(duration / 60)):\(Int(duration.truncatingRemainder(dividingBy: 60)))")
                        }
                        .padding()

                        PlayerControlsView(playerViewModel: playerViewModel, channels: $channels, currentIndex: $currentIndex)
                    }
                }
            }
            .onReceive(timer) { _ in
                currentTime = (playerViewModel.player.time.value?.floatValue ?? 0) / 1000
                duration = (playerViewModel.player.media?.length.value?.floatValue ?? 0) / 1000
            }

            .navigationBarTitle(channels[currentIndex].name, displayMode: .inline)
        }
    }
}

struct ChannelPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelPlayerView(channels: .constant([]), currentIndex: .constant(0))
    }
}
