import SwiftUI

struct PlaylistCard: View {
    var playlist: PlaylistModel
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(playlist.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 4)
                
                Spacer()
                
                Image(systemName: "tv")
                    .foregroundColor(.white)
                    .opacity(0.8)
            }
            
            Text("\(playlist.channels.count) каналов")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray3), lineWidth: 1)
        )
    }
}

struct PlaylistCard_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistCard(playlist: PlaylistModel(id: UUID(), name: "Test Playlist", channels: []))
            .previewLayout(.sizeThatFits)
    }
}
