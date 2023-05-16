import Foundation
import Alamofire
import MobileVLCKit

class NetworkManager {
    static let shared = NetworkManager()
    
    func loadPlaylist(from url: String, completion: @escaping (Result<PlaylistModel, Error>) -> Void) {
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                // Разбор файла m3u/m3u8 и создание плейлиста
                if let content = String(data: data, encoding: .utf8) {
                    let playlist = self.parseM3U(content: content)
                    completion(.success(playlist))
                } else if let content = String(data: data, encoding: .windowsCP1251) {
                    let playlist = self.parseM3U(content: content)
                    completion(.success(playlist))
                } else {
                    completion(.failure(AFError.responseValidationFailed(reason: .dataFileNil)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func parseM3U(content: String) -> PlaylistModel {
        let lines = content.split(separator: "\n")
        var channels: [ChannelModel] = []
        var currentChannelName = ""
        var currentChannelGroup: String?

        for line in lines {
            if line.starts(with: "#EXTINF:") {
                let nameComponents = line.components(separatedBy: ",")

                if nameComponents.count > 1 {
                    currentChannelName = String(nameComponents[1])
                }

                let groupTitlePrefix = "group-title=\""
                if let groupTitleRange = line.range(of: groupTitlePrefix) {
                    let groupTitleStart = groupTitleRange.upperBound
                    if let groupTitleEnd = line[groupTitleStart...].firstIndex(of: "\"") {
                        currentChannelGroup = String(line[groupTitleStart..<groupTitleEnd])
                    }
                }
            } else if !line.starts(with: "#") && !line.isEmpty {
                let channelUrl = String(line)
                let channel = ChannelModel(id: UUID(), name: currentChannelName, url: channelUrl, isFavorite: false, group: currentChannelGroup)
                channels.append(channel)
                currentChannelName = ""
                currentChannelGroup = nil
            }
        }

        let playlist = PlaylistModel(id: UUID(), name: "Новый плейлист", channels: channels)
        return playlist
    }
}
