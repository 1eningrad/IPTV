import Foundation
import Combine
import DataCompression

class PlaylistsViewModel: ObservableObject {
    @Published var playlists: [PlaylistModel] {
        didSet {
            savePlaylists()
        }
    }

    private let userDefaultsKey = "playlists"
    private let epgManager = EPGManager.shared

    init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedPlaylists = try? JSONDecoder().decode([PlaylistModel].self, from: data) {
            playlists = decodedPlaylists
        } else {
            playlists = []
        }
    }

    private func savePlaylists() {
        if let data = try? JSONEncoder().encode(playlists) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    func addEPG(url: String, toPlaylist playlist: PlaylistModel, completion: @escaping (Result<Void, Error>) -> Void) {
        epgManager.downloadAndParseEPG(channels: playlist.channels) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedChannels):
                    if let index = self?.playlists.firstIndex(where: { $0.id == playlist.id }) {
                        let updatedPlaylist = PlaylistModel(id: playlist.id, name: playlist.name, channels: updatedChannels)
                        self?.playlists[index] = updatedPlaylist
                    }
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
