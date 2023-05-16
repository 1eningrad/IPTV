import Foundation

class PlaylistModel: Identifiable, ObservableObject, Codable {
    let id: UUID
    var name: String
    @Published var channels: [ChannelModel]

    init(id: UUID, name: String, channels: [ChannelModel]) {
        self.id = id
        self.name = name
        self.channels = channels
    }

    enum CodingKeys: CodingKey {
        case id, name, channels
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let channelModelsCodable = try container.decode([ChannelModelCodable].self, forKey: .channels)
        channels = channelModelsCodable.map { ChannelModel(fromCodable: $0) }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        let channelModelsCodable = channels.map { $0.toCodable() }
        try container.encode(channelModelsCodable, forKey: .channels)
    }
}
