import Foundation

enum VoiceInputTool: String, CaseIterable, Identifiable {
    case doubao
    case typeless

    var id: String { rawValue }
    var title: String { self == .typeless ? "Typeless" : L10n.text("豆包输入法", "Doubao") }
    var observesDoubao: Bool { self == .doubao }
}

enum ChromecastVoiceMode: String, CaseIterable, Identifiable {
    case holdToTalk
    case hybrid

    var id: String { rawValue }
    var title: String {
        switch self {
        case .holdToTalk: L10n.text("按住说话", "Hold to talk")
        case .hybrid: L10n.text("点按免持／按住说话", "Tap toggle / hold")
        }
    }
}
