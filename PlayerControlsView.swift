import SwiftUI
import MobileVLCKit

struct PlayerControlsView: View {
    @ObservedObject var playerViewModel: VLCPlayerViewModel
    @Binding var channels: [ChannelModel]
    @Binding var currentIndex: Int
    @State private var isPlaying = false

    var body: some View {
        HStack(spacing: 30) {
            Button(action: {
                switchToPreviousChannel()
            }) {
                Image(systemName: "backward.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray) // изменение цвета кнопки
            }

            Button(action: {
                isPlaying.toggle()
                if isPlaying {
                    playerViewModel.player.play()
                } else {
                    playerViewModel.player.pause()
                }
            }) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray) // изменение цвета кнопки
            }

            Button(action: {
                switchToNextChannel()
            }) {
                Image(systemName: "forward.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.gray) // изменение цвета кнопки
            }
        }
        .padding()
    }

    private func switchToPreviousChannel() {
        print("Текущий индекс до переключения: \(currentIndex)")
        if currentIndex > 0 {
            currentIndex -= 1
            print("Текущий индекс после переключения: \(currentIndex)")
            print("Переключение на предыдущий канал: \(channels[currentIndex].name)")
            playerViewModel.player.media = VLCMedia(url: URL(string: channels[currentIndex].url)!)
            playerViewModel.player.play()
        } else {
            print("Переключение на предыдущий канал невозможно: достигнут начало списка каналов")
        }
    }

    private func switchToNextChannel() {
        print("Текущий индекс до переключения: \(currentIndex)")
        if currentIndex < channels.count - 1 {
            currentIndex += 1
            print("Текущий индекс после переключения: \(currentIndex)")
            print("Переключение на следующий канал: \(channels[currentIndex].name)")
            playerViewModel.player.media = VLCMedia(url: URL(string: channels[currentIndex].url)!)
            playerViewModel.player.play()
        } else {
            print("Переключение на следующий канал невозможно: достигнут конец списка каналов")
        }
    }
}

struct PlayerControlsView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerControlsView(playerViewModel: VLCPlayerViewModel(), channels: .constant([]), currentIndex: .constant(0))
    }
}
