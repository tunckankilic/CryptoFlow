import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct FearGreedEntry: TimelineEntry {
    let date: Date
    let data: SharedDataManager.FearGreedData
}

// MARK: - Timeline Provider

struct FearGreedProvider: TimelineProvider {
    func placeholder(in context: Context) -> FearGreedEntry {
        FearGreedEntry(date: .now, data: SharedDataManager.sampleFearGreed)
    }

    func getSnapshot(in context: Context, completion: @escaping (FearGreedEntry) -> Void) {
        let entry = FearGreedEntry(date: .now, data: SharedDataManager.getFearGreed())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FearGreedEntry>) -> Void) {
        let data = SharedDataManager.getFearGreed()
        let entry = FearGreedEntry(date: .now, data: data)
        // Fear & Greed updates once daily — refresh every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

// MARK: - Widget Views

struct FearGreedSmallView: View {
    let entry: FearGreedEntry

    var body: some View {
        VStack(spacing: 4) {
            Text("Fear & Greed")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.gray)

            GaugeView(value: entry.data.value, label: entry.data.label)
                .frame(width: 90, height: 90)

            if let ts = entry.data.timestamp {
                Text(ts, style: .date)
                    .font(.system(size: 8))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .widgetURL(URL(string: "cryptowave://market"))
    }
}

// MARK: - Widget Configuration

struct FearGreedWidget: Widget {
    let kind = "FearGreedWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FearGreedProvider()) { entry in
            ZStack {
                ContainerRelativeShape()
                    .fill(Color.black.gradient)

                if #available(iOS 17.0, *) {
                    FearGreedSmallView(entry: entry)
                        .containerBackground(.clear, for: .widget)
                } else {
                    FearGreedSmallView(entry: entry)
                }
            }
        }
        .configurationDisplayName("Fear & Greed")
        .description("Crypto market sentiment index.")
        .supportedFamilies([.systemSmall])
    }
}
