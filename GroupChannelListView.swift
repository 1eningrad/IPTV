import SwiftUI

struct GroupChannelListView: View {
    let groupName: String
    @StateObject private var epgManager = EPGManager.shared
    @StateObject private var viewModel: ChannelListViewModel
    @State private var selectedChannel: ChannelModel?
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""

    private var filteredChannels: [ChannelModel] {
        if searchText.isEmpty {
            return viewModel.channels.sorted { $0.name < $1.name }
        } else {
            return viewModel.channels
                .filter { $0.name.lowercased().contains(searchText.lowercased()) }
                .sorted { $0.name < $1.name }
        }
    }

    init(groupName: String, channels: [ChannelModel]) {
        self.groupName = groupName
        _viewModel = StateObject(wrappedValue: ChannelListViewModel(channels: channels))
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(groupName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
                Spacer()
            }
            .padding(.top, 20)
            
            SearchBar(text: $searchText)
                .padding(.horizontal)
            
            List(filteredChannels) { channel in
                Button(action: {
                    selectedChannel = channel
                }) {
                    ChannelRow(channel: channel)
                        .padding(.vertical, 8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .environmentObject(epgManager) // Убедитесь, что вы используете EnvironmentObject
            .listStyle(PlainListStyle())
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .fullScreenCover(item: $selectedChannel) { channelBinding in
            ChannelPlayerView(channels: Binding.constant(viewModel.channels),
                              currentIndex: Binding.constant(viewModel.channels.firstIndex(where: { $0.id == channelBinding.id }) ?? 0))
            .edgesIgnoringSafeArea(.all)
            .statusBar(hidden: true)
            .gesture(DragGesture().onEnded({ value in
                if value.translation.height > 50 {
                    selectedChannel = nil
                }
            }))
        }
        .highPriorityGesture(DragGesture().onEnded { value in
            if value.translation.width > 50 {
                presentationMode.wrappedValue.dismiss()
            }
        })
        .onAppear {
            epgManager.downloadAndParseEPG(channels: viewModel.channels) { result in
                switch result {
                case .success(let updatedChannels):
                    viewModel.updateChannels(channels: updatedChannels)
                case .failure(let error):
                    print("Failed to update EPG: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct GroupChannelListView_Previews: PreviewProvider {
    static var previews: some View {
        GroupChannelListView(groupName: "Group 1", channels: [
            ChannelModel(id: UUID(), name: "Channel 1", url: "http://example.com/channel1", isFavorite: false, epgID: "1", group: "Group 1"),
            ChannelModel(id: UUID(), name: "Channel 2", url: "http://example.com/channel2", isFavorite: false, epgID: "2", group: "Group 1")
        ])
        .environmentObject(EPGManager.shared)
    }
}

    struct SearchBar: UIViewRepresentable {
        @Binding var text: String
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        func makeUIView(context: Context) -> UISearchBar {
            let searchBar = UISearchBar(frame: .zero)
            searchBar.delegate = context.coordinator
            searchBar.searchBarStyle = .minimal
            searchBar.placeholder = "Поиск"
            return searchBar
        }
        
        func updateUIView(_ uiView: UISearchBar, context: Context) {
            uiView.text = text
        }
        
        class Coordinator: NSObject, UISearchBarDelegate {
            let parent: SearchBar
            
            init(_ parent: SearchBar) {
                self.parent = parent
            }
            
            func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                parent.text = searchText
            }
            
            func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    struct SearchBar_Previews: PreviewProvider {
        static var previews: some View {
            SearchBar(text: .constant(""))
        }
    }
