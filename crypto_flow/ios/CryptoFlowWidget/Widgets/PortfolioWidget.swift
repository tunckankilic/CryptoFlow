import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct PortfolioEntry: TimelineEntry {
    let date: Date
    let portfolio: SharedDataManager.PortfolioData
}

// MARK: - Timeline Provider

struct PortfolioProvider: TimelineProvider {
    func placeholder(in context: Context) -> PortfolioEntry {
        PortfolioEntry(date: .now, portfolio: SharedDataManager.samplePortfolio)
    }

    func getSnapshot(in context: Context, completion: @escaping (PortfolioEntry) -> Void) {
        let entry = PortfolioEntry(date: .now, portfolio: SharedDataManager.getPortfolio())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PortfolioEntry>) -> Void) {
        let portfolio = SharedDataManager.getPortfolio()
        let entry = PortfolioEntry(date: .now, portfolio: portfolio)
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Widget Views

struct PortfolioSmallView: View {
    let entry: PortfolioEntry

    var body: some View {
        let p = entry.portfolio
        let isPositive = p.pnl >= 0

        VStack(alignment: .leading, spacing: 4) {
            Text("Portfolio")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)

            Text(formatCurrency(p.totalValue))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            HStack(spacing: 4) {
                Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 10))
                Text("\(isPositive ? "+" : "")\(String(format: "%.2f", p.pnlPercentage))%")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(isPositive ? Color(hex: "00C853") : Color(hex: "FF1744"))

            Spacer()

            Text(formatCurrency(p.pnl))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(isPositive ? Color(hex: "00C853") : Color(hex: "FF1744"))
        }
        .padding()
        .widgetURL(URL(string: "cryptowave://portfolio"))
    }
}

struct PortfolioMediumView: View {
    let entry: PortfolioEntry

    var body: some View {
        let p = entry.portfolio
        let isPositive = p.pnl >= 0

        HStack(spacing: 16) {
            // Left: summary
            VStack(alignment: .leading, spacing: 4) {
                Text("Portfolio")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)

                Text(formatCurrency(p.totalValue))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                HStack(spacing: 4) {
                    Image(systemName: isPositive ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 10))
                    Text(formatCurrency(p.pnl))
                        .font(.system(size: 12, weight: .semibold))
                    Text("(\(isPositive ? "+" : "")\(String(format: "%.1f", p.pnlPercentage))%)")
                        .font(.system(size: 11))
                }
                .foregroundColor(isPositive ? Color(hex: "00C853") : Color(hex: "FF1744"))

                Spacer()
            }

            // Right: pie chart
            if !p.holdings.isEmpty {
                VStack {
                    PieChartView(holdings: p.holdings)
                        .frame(width: 80, height: 80)

                    Spacer(minLength: 0)
                }
            }
        }
        .padding()
        .widgetURL(URL(string: "cryptowave://portfolio"))
    }
}

struct PortfolioLargeView: View {
    let entry: PortfolioEntry

    var body: some View {
        let p = entry.portfolio
        let isPositive = p.pnl >= 0

        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Portfolio")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    Text(formatCurrency(p.totalValue))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatCurrency(p.pnl))
                        .font(.system(size: 14, weight: .semibold))
                    Text("\(isPositive ? "+" : "")\(String(format: "%.2f", p.pnlPercentage))%")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(isPositive ? Color(hex: "00C853") : Color(hex: "FF1744"))
            }

            Divider().background(Color.gray.opacity(0.3))

            // Holdings list
            ForEach(Array(p.holdings.prefix(5))) { holding in
                HStack {
                    Circle()
                        .fill(colorForSymbol(holding.symbol))
                        .frame(width: 8, height: 8)
                    Text(holding.symbol)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Text(formatCurrency(holding.value))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                    Text("\(String(format: "%.1f", holding.percentage))%")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .frame(width: 45, alignment: .trailing)
                }
            }

            Spacer(minLength: 0)

            // Footer
            if let lastUpdated = SharedDataManager.getLastUpdated() {
                Text("Updated \(lastUpdated, style: .relative) ago")
                    .font(.system(size: 9))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .padding()
        .widgetURL(URL(string: "cryptowave://portfolio"))
    }

    private func colorForSymbol(_ symbol: String) -> Color {
        let colors: [Color] = [
            Color(red: 0.96, green: 0.65, blue: 0.14),
            Color(red: 0.39, green: 0.45, blue: 0.95),
            Color(red: 0.95, green: 0.76, blue: 0.19),
            Color(red: 0.0, green: 0.78, blue: 0.33),
            Color(red: 0.55, green: 0.27, blue: 0.68),
        ]
        let index = abs(symbol.hashValue) % colors.count
        return colors[index]
    }
}

// MARK: - Widget Configuration

struct PortfolioWidget: Widget {
    let kind = "PortfolioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PortfolioProvider()) { entry in
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
        .configurationDisplayName("Portfolio")
        .description("Your crypto portfolio value and allocation at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }

    @ViewBuilder
    func viewForFamily(_ entry: PortfolioEntry) -> some View {
        PortfolioMediumView(entry: entry)
    }
}

// MARK: - Helpers

private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.maximumFractionDigits = value >= 1000 ? 0 : 2
    return formatter.string(from: NSNumber(value: value)) ?? "$0"
}
