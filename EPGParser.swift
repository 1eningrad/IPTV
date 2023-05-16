import Foundation

class EPGParser: NSObject, XMLParserDelegate {
    private var epgChannels: [String: EPGChannel] = [:]
    private var currentEPGChannel: EPGChannel?  // Изменим 'let' на 'var'
    private var currentEPGProgram: EPGProgram?
    private var foundCharacters: String = ""
    private var isFirstDisplayName = true

    func parse(data: Data) -> [EPGChannel] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        print("Starting XML parsing...")
        parser.parse()
        print("XML parsing finished")
        
        return Array(epgChannels.values)
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        foundCharacters = ""
        
        if elementName == "channel" {
            print("Found channel element")
            isFirstDisplayName = true
            if let channelId = attributeDict["id"] {
                currentEPGChannel = EPGChannel(id: channelId, channelNames: [], programs: [], logoURL: nil) // Обновлено: добавлено свойство channelNames
            }
        } else if elementName == "programme", let channelId = attributeDict["channel"], let start = attributeDict["start"], let stop = attributeDict["stop"] {
            print("Found programme element")
            if let startTime = DateFormatter.xmlTV.date(from: start), let endTime = DateFormatter.xmlTV.date(from: stop) {
                currentEPGProgram = EPGProgram(id: UUID().uuidString, title: "", startTime: startTime, endTime: endTime, channelId: channelId)
            }
        } else if elementName == "icon" {
            print("Found icon element")
            if let logoURL = attributeDict["src"] {
                currentEPGChannel?.logoURL = logoURL
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        print("Found characters: \(string)")
        self.foundCharacters += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "channel":
            print("Finished channel element")
            if let epgChannel = currentEPGChannel {
                epgChannels[epgChannel.id] = epgChannel
                currentEPGChannel = nil
            }
        case "display-name":
            print("Finished display-name element")
            if let currentEPGChannel = currentEPGChannel {
                currentEPGChannel.channelNames.append(foundCharacters) // Обновлено: добавление имени канала в список имен
            }
        case "title":
            print("Finished title element")
            currentEPGProgram?.title = foundCharacters
        case "desc":
            print("Finished desc element")
            currentEPGProgram?.description = foundCharacters
        case "programme":
            print("Finished programme element")
            if let epgProgram = currentEPGProgram, var channel = epgChannels[epgProgram.channelId] {
                channel.programs.append(epgProgram)
                epgChannels[epgProgram.channelId] = channel
            }
            currentEPGProgram = nil
        default:
            break
        }

        foundCharacters = ""
    }

        }

        extension DateFormatter {
            static let xmlTV: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMddHHmmss Z"
                return formatter
            }()
        }
