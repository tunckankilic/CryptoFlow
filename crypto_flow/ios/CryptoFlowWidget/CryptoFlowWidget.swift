import WidgetKit
import SwiftUI

/// Widget bundle that registers all CryptoFlow home screen widgets.
@main
struct CryptoFlowWidgetBundle: WidgetBundle {
    var body: some Widget {
        CryptoTickerWidget()
        PortfolioWidget()
        AlertWidget()
        FearGreedWidget()
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
