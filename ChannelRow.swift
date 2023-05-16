import SwiftUI

struct ChannelRow: View {
    @EnvironmentObject var epgManager: EPGManager
    var channel: ChannelModel
    
    var body: some View {
        HStack {
            if let logoURL = channel.logoURL, let url = URL(string: logoURL) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 45)
                .cornerRadius(5)
                .padding(.trailing, 10)
            } else {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 80, height: 45)
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(channel.name)
                    .font(.headline)
                if let currentProgram = channel.currentProgram {
                    Text(currentProgram.title) // Обновлено: добавлено .title
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .onAppear {
            print("channel.currentProgram: \(channel.currentProgram?.title ?? "nil")") // Обновлено: добавлено .title
            print("channel.logoURL: \(channel.logoURL ?? "nil")")
        }
    }
}
