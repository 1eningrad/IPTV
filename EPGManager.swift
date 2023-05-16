import Compression
import Foundation
import Alamofire
import Compression // Новый импорт

class EPGManager: ObservableObject {
    static let shared = EPGManager()
    
    private var epgChannels: [String: EPGChannel] = [:]
    
    public init() { }
    
    enum EPGError: Error {
        case decompressionError
    }
    
    func downloadAndParseEPG(channels: [ChannelModel], completion: @escaping (Result<[ChannelModel], Error>) -> Void) {
        let epgURL = "http://epg.g-cdn.app/xmltv.xml.gz"
        loadAndParseEPG(url: epgURL) { result in
            switch result {
            case .success(_):
                var updatedChannels = self.updateCurrentPrograms(channels: channels)
                updatedChannels = self.updateChannelLogos(channels: updatedChannels)
                completion(.success(updatedChannels))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadAndParseEPG(url: String, completion: @escaping (Result<[EPGChannel], Error>) -> Void) {
        downloadEPG(url: url) { result in
            switch result {
            case .success(let data):
                let parser = EPGParser()
                let epgChannels = parser.parse(data: data)
                self.epgChannels = epgChannels.reduce(into: [String: EPGChannel]()) { (result, channel) in
                    result[channel.id] = channel
                }
                completion(.success(epgChannels))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateChannelsWithEPG(channels: [ChannelModel]) -> [ChannelModel] {
        return channels.map { channel in
            let updatedChannel = channel
            if let epgChannel = epgChannels[channel.epgID ?? ""] {
                updatedChannel.logoURL = epgChannel.logoURL
                updatedChannel.currentProgram = epgChannel.currentProgram
            }
            return updatedChannel
        }
    }
    
    func currentProgram(for channel: ChannelModel) -> EPGProgram? {
        guard let epgID = channel.epgID, let epgChannel = epgChannels[epgID] else {
            return nil
        }
        let now = Date()
        for program in epgChannel.programs {
            if now >= program.startTime && now < program.endTime {
                return program
            }
        }
        return nil
    }
    
    func updateCurrentPrograms(channels: [ChannelModel]) -> [ChannelModel] {
        return channels.map { channel in
            let updatedChannel = channel
            if let program = self.currentProgram(for: updatedChannel) {
                updatedChannel.currentProgram = program // Изменено на program
            } else {
                updatedChannel.currentProgram = nil // Значение по умолчанию
            }
            return updatedChannel
        }
    }
    
    func updateChannelLogos(channels: [ChannelModel]) -> [ChannelModel] {
        return channels.map { channel in
            let updatedChannel = channel
            if let epgID = channel.epgID, let epgChannel = epgChannels[epgID] {
                updatedChannel.logoURL = epgChannel.logoURL
            } else {
                updatedChannel.logoURL = nil
            }
            return updatedChannel
        }
    }
    
    func getAllEPGChannels() -> [EPGChannel] {
        return Array(epgChannels.values)
    }
    
    private func downloadEPG(url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let destination: DownloadRequest.Destination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("epg.xml.gz")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        AF.download(url, to: destination)
            .response { response in
                if let error = response.error {
                    completion(.failure(error))
                } else if let fileURL = response.fileURL {
                    do {
                        let data = try self.unzipEPG(fileURL: fileURL)
                        completion(.success(data))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
    }
    
    private func unzipEPG(fileURL: URL) throws -> Data {
        let compressedData = try Data(contentsOf: fileURL)
        guard let decompressedData = compressedData.decompress(withAlgorithm: .zlib) else {
            throw EPGError.decompressionError
        }
        return decompressedData
    }
}
