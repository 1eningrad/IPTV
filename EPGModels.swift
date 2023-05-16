import Foundation

class EPGChannel {
    let id: String
    var channelNames: [String] = []
    var programs: [EPGProgram]
    var logoURL: String?
    var currentProgram: EPGProgram?

    init(id: String, channelNames: [String] = [], programs: [EPGProgram] = [], logoURL: String? = nil, currentProgram: EPGProgram? = nil) {
        self.id = id
        self.channelNames = channelNames
        self.programs = programs
        self.logoURL = logoURL
        self.currentProgram = currentProgram
    }
}

class EPGProgram: Codable {
    let id: String
    var title: String
    let startTime: Date
    let endTime: Date
    let channelId: String
    var description: String?

    init(id: String, title: String, startTime: Date, endTime: Date, channelId: String, description: String? = nil) {
        self.id = id
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.channelId = channelId
        self.description = description
    }
}
