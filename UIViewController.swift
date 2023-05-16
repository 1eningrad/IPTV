import SwiftUI

struct EPGView: View {
    @EnvironmentObject private var epgManager: EPGManager
    @State private var channels: [ChannelModel] = [
        ChannelModel(id: UUID(), name: "Channel 1", url: "http://example.com/channel1", isFavorite: false, epgID: "1", group: "Group 1"),
        ChannelModel(id: UUID(), name: "Channel 2", url: "http://example.com/channel2", isFavorite: false, epgID: "2", group: "Group 1")
    ]

    var body: some View {
        NavigationView {
            List(channels) { channel in
                ChannelRow(channel: channel)
                    .environmentObject(epgManager)
            }
            .onAppear(perform: loadEPG)
            .navigationBarTitle("EPG")
        }
    }

    private func loadEPG() {
        epgManager.downloadAndParseEPG(channels: channels) { result in
            switch result {
            case .success(let updatedChannels):
                print("EPG успешно загружен и обработан")
                channels = updatedChannels
            case .failure(let error):
                print("Ошибка загрузки или обработки EPG: \(error)")
            }
        }
    }
}

struct EPGView_Previews: PreviewProvider {
    static var previews: some View {
        EPGView()
            .environmentObject(EPGManager.shared)
    }
}

