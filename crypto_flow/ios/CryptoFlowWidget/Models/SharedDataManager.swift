import Foundation

/// Reads data written by the Flutter app via `home_widget` into the shared
/// App Group `UserDefaults` container.
struct SharedDataManager {
    static let appGroupId = "group.site.tunckankilic.cryptoFlow"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    // MARK: - Keys (must match WidgetDataKeys in Dart)

    enum Key {
        static let tickerData = "ticker_data"
        static let portfolioTotalValue = "portfolio_total_value"
        static let portfolioPnl = "portfolio_pnl"
        static let portfolioPnlPercentage = "portfolio_pnl_percentage"
        static let portfolioHoldings = "portfolio_holdings"
        static let alertsData = "alerts_data"
        static let alertsActiveCount = "alerts_active_count"
        static let alertsTriggeredCount = "alerts_triggered_count"
        static let fearGreedValue = "fear_greed_value"
        static let fearGreedLabel = "fear_greed_label"
        static let fearGreedTimestamp = "fear_greed_timestamp"
        static let lastUpdated = "last_updated"
    }

    // MARK: - Ticker

    struct TickerItem: Identifiable, Codable {
        var id: String { symbol }
        let symbol: String
        let price: Double
        let change24h: Double
        let changePercent24h: Double
    }

    static func getTickers() -> [TickerItem] {
        guard let json = defaults?.string(forKey: Key.tickerData),
              let data = json.data(using: .utf8),
              let items = try? JSONDecoder().decode([TickerItem].self, from: data)
        else { return sampleTickers }
        return items.isEmpty ? sampleTickers : items
    }

    // MARK: - Portfolio

    struct PortfolioData {
        let totalValue: Double
        let pnl: Double
        let pnlPercentage: Double
        let holdings: [HoldingItem]
    }

    struct HoldingItem: Identifiable, Codable {
        var id: String { symbol }
        let symbol: String
        let value: Double
        let percentage: Double
    }

    static func getPortfolio() -> PortfolioData {
        let totalValue = defaults?.double(forKey: Key.portfolioTotalValue) ?? 0
        let pnl = defaults?.double(forKey: Key.portfolioPnl) ?? 0
        let pnlPct = defaults?.double(forKey: Key.portfolioPnlPercentage) ?? 0

        var holdings: [HoldingItem] = []
        if let json = defaults?.string(forKey: Key.portfolioHoldings),
           let data = json.data(using: .utf8) {
            holdings = (try? JSONDecoder().decode([HoldingItem].self, from: data)) ?? []
        }

        if totalValue == 0 {
            return samplePortfolio
        }
        return PortfolioData(
            totalValue: totalValue,
            pnl: pnl,
            pnlPercentage: pnlPct,
            holdings: holdings
        )
    }

    // MARK: - Alerts

    struct AlertData {
        let activeCount: Int
        let triggeredCount: Int
        let alerts: [AlertItem]
    }

    struct AlertItem: Identifiable, Codable {
        var id: String { "\(symbol)_\(targetPrice)" }
        let symbol: String
        let type: String
        let targetPrice: Double
        let status: String
    }

    static func getAlerts() -> AlertData {
        let active = defaults?.integer(forKey: Key.alertsActiveCount) ?? 0
        let triggered = defaults?.integer(forKey: Key.alertsTriggeredCount) ?? 0

        var alerts: [AlertItem] = []
        if let json = defaults?.string(forKey: Key.alertsData),
           let data = json.data(using: .utf8) {
            alerts = (try? JSONDecoder().decode([AlertItem].self, from: data)) ?? []
        }

        if active == 0 && triggered == 0 {
            return sampleAlerts
        }
        return AlertData(activeCount: active, triggeredCount: triggered, alerts: alerts)
    }

    // MARK: - Fear & Greed

    struct FearGreedData {
        let value: Int
        let label: String
        let timestamp: Date?
    }

    static func getFearGreed() -> FearGreedData {
        let value = defaults?.integer(forKey: Key.fearGreedValue) ?? 0
        let label = defaults?.string(forKey: Key.fearGreedLabel) ?? ""

        var timestamp: Date?
        if let ts = defaults?.string(forKey: Key.fearGreedTimestamp) {
            let formatter = ISO8601DateFormatter()
            timestamp = formatter.date(from: ts)
        }

        if value == 0 {
            return sampleFearGreed
        }
        return FearGreedData(value: value, label: label, timestamp: timestamp)
    }

    // MARK: - Last Updated

    static func getLastUpdated() -> Date? {
        guard let ts = defaults?.string(forKey: Key.lastUpdated) else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: ts)
    }

    // MARK: - Sample Data (placeholder when no data from Flutter yet)

    static let sampleTickers: [TickerItem] = [
        TickerItem(symbol: "BTCUSDT", price: 65432.10, change24h: 1250.30, changePercent24h: 1.95),
        TickerItem(symbol: "ETHUSDT", price: 3456.78, change24h: -89.12, changePercent24h: -2.51),
        TickerItem(symbol: "BNBUSDT", price: 567.89, change24h: 12.34, changePercent24h: 2.22),
    ]

    static let samplePortfolio = PortfolioData(
        totalValue: 12345.67,
        pnl: 567.89,
        pnlPercentage: 4.82,
        holdings: [
            HoldingItem(symbol: "BTC", value: 7500, percentage: 60.7),
            HoldingItem(symbol: "ETH", value: 3200, percentage: 25.9),
            HoldingItem(symbol: "BNB", value: 1645.67, percentage: 13.4),
        ]
    )

    static let sampleAlerts = AlertData(
        activeCount: 3,
        triggeredCount: 1,
        alerts: [
            AlertItem(symbol: "BTCUSDT", type: "above", targetPrice: 70000, status: "active"),
            AlertItem(symbol: "ETHUSDT", type: "below", targetPrice: 3000, status: "triggered"),
        ]
    )

    static let sampleFearGreed = FearGreedData(
        value: 62,
        label: "Greed",
        timestamp: Date()
    )
}
