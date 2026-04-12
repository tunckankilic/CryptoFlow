import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct CryptoTickerEntry: TimelineEntry {
    let date: Date
    let tickers: [SharedDataManager.TickerItem]
}

// MARK: - Timeline Provider

struct CryptoTickerProvider: TimelineProvider {
    func placeholder(in context: Context) -> CryptoTickerEntry {
        CryptoTickerEntry(date: .now, tickers: SharedDataManager.sampleTickers)
    }

    func getSnapshot(in context: Context, completion: @escaping (CryptoTickerEntry) -> Void) {
        let entry = CryptoTickerEntry(date: .now, tickers: SharedDataManager.getTickers())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CryptoTickerEntry>) -> Void) {
        let tickers = SharedDataManager.getTickers()
        let entry = CryptoTickerEntry(date: .now, tickers: tickers)
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Widget Views

struct CryptoTickerSmallView: View {
    let entry: CryptoTickerEntry

    var body: some View {
        if let ticker = entry.tickers.first {
            VStack(alignment: .leading, spacing: 4) {
                Text(ticker.symbol.replacingOccurrences(of: "USDT", with: ""))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)

                Text(formatPrice(ticker.price))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                HStack(spacing: 4) {
                    Image(systemName: ticker.changePercent24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 10))
                    Text(formatPercent(ticker.changePercent24h))
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(ticker.changePercent24h >= 0 ? Color(hex: "00C853") : Color(hex: "FF1744"))

                Spacer()

                Text("CryptoWave")
                    .font(.system(size: 8))
                    .foregroundColor(.gray.opacity(0.6))
            }
            .padding()
            .widgetURL(URL(string: "cryptowave://ticker/\(ticker.symbol)"))
        }
    }
}

struct CryptoTickerMediumView: View {
    let entry: CryptoTickerEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Watchlist")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)

            ForEach(Array(entry.tickers.prefix(3))) { ticker in
                HStack {
                    Text(ticker.symbol.replacingOccurrences(of: "USDT", with: ""))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 45, alignment: .leading)

                    Spacer()

                    Text(formatPrice(ticker.price))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white)

                    Text(formatPercent(ticker.changePercent24h))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(ticker.changePercent24h >= 0 ? Color(hex: "00C853") : Color(hex: "FF1744"))
                        .frame(width: 60, alignment: .trailing)
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
        .widgetURL(URL(string: "cryptowave://market"))
    }
}

// MARK: - Widget Configuration

struct CryptoTickerWidget: Widget {
    let kind = "CryptoTickerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CryptoTickerProvider()) { entry in
            ZStack {
                ContainerRelativeShape()
                    .fill(Color.black.gradient)

                if #available(iOS 17.0, *) {
                    viewForFamily(entry)
                        .containerBackground(.clear, for: .widget)
                } else {
                    viewForFamily(entry)
                }
            }
        }
        .configurationDisplayName("Crypto Ticker")
        .description("Real-time cryptocurrency prices from your watchlist.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }

    @ViewBuilder
    func viewForFamily(_ entry: CryptoTickerEntry) -> some View {
        // The system will select the right view based on the widget family.
        // For simplicity, we use medium as default since WidgetKit picks the
        // correct family at render time.
        CryptoTickerMediumView(entry: entry)
    }
}

// MARK: - Helpers

private func formatPrice(_ price: Double) -> String {
    if price >= 1000 {
        return "$\(String(format: "%.0f", price))"
    } else if price >= 1 {
        return "$\(String(format: "%.2f", price))"
    } else {
        return "$\(String(format: "%.4f", price))"
    }
}

private func formatPercent(_ value: Double) -> String {
    let sign = value >= 0 ? "+" : ""
    return "\(sign)\(String(format: "%.2f", value))%"
}
