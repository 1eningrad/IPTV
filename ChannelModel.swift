import Foundation
import SwiftUI
import Combine

class ChannelModel: Identifiable, ObservableObject {
    let id: UUID
    var name: String
    var url: String
    @Published var isFavorite: Bool
    var group: String?
    var epgID: String?
    var logoURL: String?
    var currentProgram: EPGProgram?

    init(id: UUID, name: String, url: String, isFavorite: Bool, epgID: String? = nil, group: String? = nil, logoURL: String? = nil, currentProgram: EPGProgram? = nil) {
        self.id = id
        self.name = name
        self.url = url
        self.isFavorite = isFavorite
        self.epgID = epgID
        self.group = group
        self.logoURL = logoURL
        self.currentProgram = currentProgram
    }

    func updateFavoriteStatus(isFavorite: Bool) {
        self.isFavorite = isFavorite
    }
}
