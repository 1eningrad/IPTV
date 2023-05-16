import Foundation
import SwiftUI
import Combine

final class ChannelData: ObservableObject {
    @Published var favoriteChannels: [ChannelModel] = []
    
    init() {
        // Здесь вы можете добавить начальные данные для favoriteChannels, если это необходимо
        // или загрузить данные из хранилища
    }
}
