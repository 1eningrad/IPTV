import SwiftUI
import Alamofire

struct AddPlaylistView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var playlistName = ""
    @State private var url = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack {
                TextField("Введите название плейлиста", text: $playlistName)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                TextField("Введите URL плейлиста", text: $url)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                addButton
                    .padding(.horizontal)
                    .disabled(isLoading)
                    .overlay(loadingOverlay)

                Spacer()
            }
            .padding(.top)
            .navigationBarTitle("Добавить плейлист", displayMode: .inline)
            .navigationBarItems(trailing: closeButton)
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Ошибка"), message: Text(errorMessage), dismissButton: .default(Text("ОК")))
        }
    }

    private var addButton: some View {
        Button(action: {
            handleAddPlaylist()
        }) {
            Text("Добавить плейлист")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(10)
        }
    }

    private var loadingOverlay: some View {
        Group {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .transition(.opacity)
    }

    private var closeButton: some View {
        Button("Закрыть") {
            presentationMode.wrappedValue.dismiss()
        }
    }

    private func handleAddPlaylist() {
        if let validURL = URL(string: url) {
            withAnimation {
                isLoading = true
            }
            AF.request(validURL).responseString { response in
                withAnimation {
                    isLoading = false
                }
                if let data = response.value, data.starts(with: "#EXTM3U") {
                    // Здесь вы можете обработать добавление плейлиста по валидному URL и названию плейлиста
                    presentationMode.wrappedValue.dismiss()
                } else {
                    showError = true
                    errorMessage = "URL не содержит корректный M3U или M3U8 плейлист"
                }
            }
        } else {
            showError = true
            errorMessage = "Введите корректный URL-адрес"
        }
    }
}

struct AddPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        AddPlaylistView()
    }
}
