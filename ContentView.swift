import SwiftUI

struct ContentView: View {
    @EnvironmentObject var epgManager: EPGManager
    @StateObject private var playlistsViewModel = PlaylistsViewModel()
    @StateObject private var channelData = ChannelData()
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        TabView {
            PlaylistView(playlistsViewModel: playlistsViewModel)
                .tabItem {
                    Image(systemName: "tv.fill")
                    Text("Плейлисты")
                        .font(.headline)
                }
                .environmentObject(channelData)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.orange.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .onAppear {
                    loadEPG()
                }

            FavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Избранное")
                        .font(.headline)
                }
                .environmentObject(channelData)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.1), Color.purple.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Настройки")
                        .font(.headline)
                }
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.1), Color.green.opacity(0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        }
        .accentColor(isDarkMode ? .white : .black)
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
    }

    private func loadEPG() {
        guard let playlist = playlistsViewModel.playlists.first else {
            return
        }

        epgManager.downloadAndParseEPG(channels: playlist.channels) { result in
            switch result {
            case .success(let updatedChannels):
                print("EPG успешно загружен и обработан")
                if let index = playlistsViewModel.playlists.firstIndex(where: { $0.id == playlist.id }) {
                    let updatedPlaylist = PlaylistModel(id: playlist.id, name: playlist.name, channels: updatedChannels)
                    playlistsViewModel.playlists[index] = updatedPlaylist
                }
            case .failure(let error):
                print("Ошибка загрузки или обработки EPG: \(error)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(EPGManager.shared)
    }
}
