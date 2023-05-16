import SwiftUI
import MobileVLCKit

struct VLCVideoView: UIViewRepresentable {
    @ObservedObject var playerViewModel: VLCPlayerViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        playerViewModel.player.drawable = view
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        playerViewModel.player.drawable = uiView
        playerViewModel.player.videoAspectRatio = strdup("16:9")
    }

    class Coordinator: NSObject {
        var vlcVideoView: VLCVideoView

        init(_ vlcVideoView: VLCVideoView) {
            self.vlcVideoView = vlcVideoView
        }
    }
}
