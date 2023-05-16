import Combine
import SwiftUI

class ChannelListViewModel: ObservableObject {
    @Published private(set) var channels: [ChannelModel] = []
    @Published private(set) var groups: Set<String> = []

    private var cancellables: Set<AnyCancellable> = []

    init(channels: [ChannelModel]) {
        self.channels = channels
        $channels
            .map { channels in
                Set(channels.compactMap { $0.group })
            }
            .assign(to: \.groups, on: self)
            .store(in: &cancellables)

        updateChannels(channels: channels)
    }

    func updateChannels(channels: [ChannelModel]) {
        self.channels = channels
    }

    func channel(for group: String) -> [ChannelModel] {
        return channels.filter { $0.group == group }
    }
}
