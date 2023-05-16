import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var channelData: ChannelData
    @State private var selectedChannel: ChannelModel?
    private var epgManager = EPGManager.shared

    var body: some View {
        NavigationView {
            List {
                ForEach(channelData.favoriteChannels) { channel in
                    Button(action: {
                        selectedChannel = channel
                    }) {
                        ChannelRow(channel: channel)
                    }
                }
            }
            .navigationBarTitle("Избранное")
            .fullScreenCover(item: $selectedChannel) { channelBinding in
                ChannelPlayerView(channels: .constant(channelData.favoriteChannels),
                                  currentIndex: .constant(channelData.favoriteChannels.firstIndex(where: { $0.id == channelBinding.id }) ?? 0))
                    .edgesIgnoringSafeArea(.all)
                    .statusBar(hidden: true)
                    .gesture(DragGesture().onEnded({ value in
                        if value.translation.height > 50 {
                            selectedChannel = nil
                        }
                    }))
            }
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView().environmentObject(ChannelData())
    }
}
