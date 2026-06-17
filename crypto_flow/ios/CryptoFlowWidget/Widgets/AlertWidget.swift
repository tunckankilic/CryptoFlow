import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct AlertEntry: TimelineEntry {
    let date: Date
    let alertData: SharedDataManager.AlertData
}

// MARK: - Timeline Provider

struct AlertProvider: TimelineProvider {
    func placeholder(in context: Context) -> AlertEntry {
        AlertEntry(date: .now, alertData: SharedDataManager.sampleAlerts)
    }

    func getSnapshot(in context: Context, completion: @escaping (AlertEntry) -> Void) {
        let entry = AlertEntry(date: .now, alertData: SharedDataManager.getAlerts())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AlertEntry>) -> Void) {
        let data = SharedDataManager.getAlerts()
        let entry = AlertEntry(date: .now, alertData: data)
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Widget Views

struct AlertMediumView: View {
    let entry: AlertEntry

    var body: some View {
        let data = entry.alertData

        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "bell.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                Text("Price Alerts")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                HStack(spacing: 8) {
                    Label("\(data.activeCount)", systemImage: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "00C853"))
                    Label("\(data.triggeredCount)", systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.orange)
                }
            }

            // Alert list
            if data.alerts.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                        Text("No alerts set")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                Spacer()
            } else {
                ForEach(Array(data.alerts.prefix(3))) { alert in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(alert.status == "triggered" ? Color.orange : Color(hex: "00C853"))
                            .frame(width: 6, height: 6)

                        Text(alert.symbol.replacingOccurrences(of: "USDT", with: ""))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)

                        Image(systemName: alertIcon(for: alert.type))
                            .font(.system(size: 9))
                            .foregroundColor(.gray)

                        Text(formatAlertPrice(alert.targetPrice))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white)

                        Spacer()

                        Text(alert.status.capitalized)
                            .font(.system(size: 9, weight: .medium))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule().fill(
                                    alert.status == "triggered"
                                        ? Color.orange.opacity(0.2)
                                        : Color(hex: "00C853").opacity(0.2)
                                )
                            )
                            .foregroundColor(
                                alert.status == "triggered" ? .orange : Color(hex: "00C853")
                            )
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding()
        .widgetURL(URL(string: "cryptowave://alerts"))
    }

    private func alertIcon(for type: String) -> String {
        switch type {
        case "above", "percentUp": return "arrow.up"
        case "below", "percentDown": return "arrow.down"
        default: return "arrow.up.arrow.down"
        }
    }

    private func formatAlertPrice(_ price: Double) -> String {
        if price >= 1000 {
            return "$\(String(format: "%.0f", price))"
        }
        return "$\(String(format: "%.2f", price))"
    }
}

// MARK: - Widget Configuration

struct AlertWidget: Widget {
    let kind = "AlertWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AlertProvider()) { entry in
            ZStack {
                ContainerRelativeShape()
                    .fill(Color.black.gradient)

                if #available(iOS 17.0, *) {
                    AlertMediumView(entry: entry)
                        .containerBackground(.clear, for: .widget)
                } else {
                    AlertMediumView(entry: entry)
                }
            }
        }
        .configurationDisplayName("Price Alerts")
        .description("Monitor your active and triggered price alerts.")
        .supportedFamilies([.systemMedium])
    }
}
