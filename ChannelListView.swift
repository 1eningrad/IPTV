import SwiftUI

struct ChannelListView: View {
    @ObservedObject var playlist: PlaylistModel

    private var groupedChannels: [String: [ChannelModel]] {
        Dictionary(grouping: playlist.channels, by: { $0.group ?? "Без категории" })
    }

    var body: some View {
        ScrollView {
            VStack {
                ForEach(groupedChannels.keys.sorted(), id: \.self) { group in
                    let channels = groupedChannels[group]!
                    GroupChannelRow(group: group, channels: channels)
                }
            }
            .padding()
        }
        .navigationBarTitle("Группы")
    }
}

struct GroupChannelRow: View {
    let group: String
    let channels: [ChannelModel]

    var body: some View {
        HStack {
            NavigationLink(destination: GroupChannelListView(groupName: group, channels: channels)) {
                Text(group)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ChannelListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChannelListView(playlist: PlaylistModel(id: UUID(), name: "Плейлист 1", channels: [
                ChannelModel(id: UUID(), name: "Канал 1", url: "https://example.com/channel1.m3u8", isFavorite: true, epgID: "1", group: "Фильмы"),
                ChannelModel(id: UUID(), name: "Канал 2", url: "https://example.com/channel2.m3u8", isFavorite: false, epgID: "2", group: "Спорт")
            ]))
        }
    }
}
