import SwiftUI

/// A circular gauge for the Fear & Greed Index (0–100).
///
/// The arc goes from green (0 = Extreme Fear) through yellow (50 = Neutral)
/// to red (100 = Extreme Greed).
struct GaugeView: View {
    let value: Int
    let label: String

    private var progress: Double {
        min(max(Double(value) / 100.0, 0), 1)
    }

    private var gaugeColor: Color {
        switch value {
        case 0..<25: return .green
        case 25..<45: return Color(red: 0.5, green: 0.8, blue: 0.2)
        case 45..<55: return .yellow
        case 55..<75: return .orange
        default: return .red
        }
    }

    var body: some View {
        ZStack {
            // Background arc
            Circle()
                .trim(from: 0.0, to: 0.75)
                .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(135))

            // Value arc
            Circle()
                .trim(from: 0.0, to: progress * 0.75)
                .stroke(gaugeColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(135))

            // Center text
            VStack(spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
    }
}
