import Foundation

class FavoritesViewModel: ObservableObject {
    @Published var favoriteChannels: [ChannelModel] = []
}
