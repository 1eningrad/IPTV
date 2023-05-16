import Foundation

struct ChannelModelCodable: Codable {
    let id: UUID
    var name: String
    var url: String
    var isFavorite: Bool
    var group: String?
    var epgID: String?
    var logoURL: String?
    var currentProgram: EPGProgram?

    init(fromModel model: ChannelModel) {
        self.id = model.id
        self.name = model.name
        self.url = model.url
        self.isFavorite = model.isFavorite
        self.group = model.group
        self.epgID = model.epgID
        self.logoURL = model.logoURL
        self.currentProgram = model.currentProgram
    }

    func toModel() -> ChannelModel {
        let model = ChannelModel(id: id, name: name, url: url, isFavorite: isFavorite, epgID: epgID, group: group, logoURL: logoURL, currentProgram: currentProgram)
        return model
    }
}

extension ChannelModel {
    convenience init(fromCodable codable: ChannelModelCodable) {
        self.init(id: codable.id, name: codable.name, url: codable.url, isFavorite: codable.isFavorite, epgID: codable.epgID, group: codable.group, logoURL: codable.logoURL, currentProgram: codable.currentProgram)
    }

    func toCodable() -> ChannelModelCodable {
        return ChannelModelCodable(fromModel: self)
    }
}

extension ChannelModelCodable {
    enum CodingKeys: CodingKey {
        case id, name, url, epgID, isFavorite, group, logoURL, currentProgram
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        url = try container.decode(String.self, forKey: .url)
        epgID = try container.decodeIfPresent(String.self, forKey: .epgID)
        group = try container.decodeIfPresent(String.self, forKey: .group)
        logoURL = try container.decodeIfPresent(String.self, forKey: .logoURL)
        currentProgram = try? container.decode(EPGProgram.self, forKey: .currentProgram)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encodeIfPresent(epgID, forKey: .epgID)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encodeIfPresent(group, forKey: .group)
        try container.encodeIfPresent(logoURL, forKey: .logoURL)
        if let currentProgram = currentProgram {
            try container.encode(currentProgram, forKey: .currentProgram)
        }
    }
}
