import SwiftUI

struct EPGInputView: View {
    @Binding var playlist: PlaylistModel?
    @ObservedObject var playlistsViewModel: PlaylistsViewModel
    @State private var epgURL = ""
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Введите ссылку на EPG (xmltv)")
                .font(.headline)
                .padding()

            TextField("URL EPG", text: $epgURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if let playlist = playlist {
                    playlistsViewModel.addEPG(url: epgURL, toPlaylist: playlist) { result in
                        switch result {
                        case .success():
                            presentationMode.wrappedValue.dismiss()
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    }
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
        }
        .padding()
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Ошибка"), message: Text(errorMessage), dismissButton: .default(Text("ОК")))
        }
    }
}
