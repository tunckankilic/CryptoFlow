import SwiftUI

/// A minimal sparkline (line chart) for displaying price trends in widgets.
struct SparklineView: View {
    let data: [Double]
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            if data.count > 1, let minVal = data.min(), let maxVal = data.max(), maxVal > minVal {
                let range = maxVal - minVal
                Path { path in
                    for (index, value) in data.enumerated() {
                        let x = geometry.size.width * CGFloat(index) / CGFloat(data.count - 1)
                        let y = geometry.size.height * (1 - CGFloat((value - minVal) / range))
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            } else {
                // Flat line when no meaningful data
                Path { path in
                    let y = geometry.size.height / 2
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                }
                .stroke(color.opacity(0.3), lineWidth: 1)
            }
        }
    }
}
