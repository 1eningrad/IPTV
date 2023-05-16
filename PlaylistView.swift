import SwiftUI
import Alamofire

struct PlaylistView: View {
    @StateObject var playlistsViewModel = PlaylistsViewModel()
    @State private var showingAddPlaylistAlert = false
    @State private var showingRenamePlaylistSheet = false
    @State private var showingAddEPGSheet = false
    @State private var playlistURL = ""
    @State private var playlistName = ""
    @State private var newPlaylistName = ""
    @State private var selectedPlaylist: PlaylistModel?
    @State private var errorMessage: String = ""
    @State private var showingErrorAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(playlistsViewModel.playlists) { playlist in
                        NavigationLink(destination: ChannelListView(playlist: playlist)) {
                            PlaylistCard(playlist: playlist)
                        }
                        .contextMenu {
                            Button(action: {
                                self.selectedPlaylist = playlist
                                self.showingRenamePlaylistSheet = true
                            }) {
                                Text("Переименовать")
                                Image(systemName: "pencil")
                            }
                            Button(action: {
                                if let index = playlistsViewModel.playlists.firstIndex(where: { $0.id == playlist.id }) {
                                    playlistsViewModel.playlists.remove(at: index)
                                }
                            }) {
                                Text("Удалить")
                                Image(systemName: "trash")
                            }
                            Button(action: {
                                self.selectedPlaylist = playlist
                                self.showingAddEPGSheet = true
                            }) {
                                Text("Добавить EPG")
                                Image(systemName: "antenna.radiowaves.left.and.right")
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Плейлисты")
            .navigationBarItems(trailing: Button(action: {
                showingAddPlaylistAlert = true
            }) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 22, height: 22)
            })
            .sheet(isPresented: $showingAddPlaylistAlert) {
                VStack {
                    Text("Введите ссылку на плейлист")
                        .font(.headline)
                        .padding()

                    TextField("Название плейлиста", text: $playlistName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    TextField("URL плейлиста", text: $playlistURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button(action: {
                        let validationResult = validateAndLoadPlaylist(url: playlistURL, name: playlistName)
                        if validationResult.isValid {
                            loadAndParsePlaylist(url: playlistURL, name: playlistName)
                            showingAddPlaylistAlert = false
                        } else {
                            errorMessage = validationResult.errorMessage
                            showingErrorAlert = true
                        }
                    }) {
                        Text("Добавить")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    .alert(isPresented: $showingErrorAlert) {
                        Alert(title: Text("Ошибка"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                    }
                }
                .padding()
            }
            .sheet(isPresented: $showingRenamePlaylistSheet) {
                VStack {
                    Text("Введите новое название плейлиста")
                        .font(.headline)
                        .padding()

                    TextField("Новое название", text: $newPlaylistName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button(action: {
                        if let selectedPlaylist = self.selectedPlaylist {
                            renamePlaylist(selectedPlaylist)
                            showingRenamePlaylistSheet = false
                        }
                    }) {
                        Text("Сохранить")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding()
            }
            .sheet(isPresented: $showingAddEPGSheet) {
                EPGInputView(playlist: self.$selectedPlaylist, playlistsViewModel: playlistsViewModel)
            }
        }
    }

    private func validateAndLoadPlaylist(url: String, name: String) -> (isValid: Bool, errorMessage: String) {
        if isValidURL(url: url) && !isDuplicatePlaylistName(name: name) {
            return (true, "")
        } else {
            return (false, "Неверный URL или дублирование имени плейлиста.")
        }
    }

    func loadAndParsePlaylist(url: String, name: String) {
        NetworkManager.shared.loadPlaylist(from: url) { result in
            switch result {
            case .success(let playlist):
                DispatchQueue.main.async {
                    let newPlaylist = PlaylistModel(id: playlist.id, name: name.isEmpty ? playlist.name : name, channels: playlist.channels)
                    playlistsViewModel.playlists.append(newPlaylist)
                }
            case .failure(let error):
                print("Error loading playlist: \(error)")
            }
        }
    }

    private func renamePlaylist(_ playlist: PlaylistModel) {
        if let index = playlistsViewModel.playlists.firstIndex(where: { $0.id == playlist.id }) {
            let updatedPlaylist = PlaylistModel(id: playlist.id, name: newPlaylistName.isEmpty ? playlist.name : newPlaylistName, channels: playlist.channels)
            playlistsViewModel.playlists[index] = updatedPlaylist
            newPlaylistName = ""
        }
    }

    private func isValidURL(url: String) -> Bool {
        let urlRegex = "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)"
        let urlPredicate = NSPredicate(format: "SELF MATCHES %@", urlRegex)
        return urlPredicate.evaluate(with: url)
    }

    private func isDuplicatePlaylistName(name: String) -> Bool {
        return self.playlistsViewModel.playlists.contains(where: { $0.name == name })
    }
}
