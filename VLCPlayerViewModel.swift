import Foundation
import MobileVLCKit

class VLCPlayerViewModel: ObservableObject {
    @Published var player = VLCMediaPlayer()
}
