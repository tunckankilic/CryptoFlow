import SwiftUI

/// A simple pie/donut chart for portfolio allocation.
struct PieChartView: View {
    let holdings: [SharedDataManager.HoldingItem]

    private let colors: [Color] = [
        Color(red: 0.96, green: 0.65, blue: 0.14), // BTC gold
        Color(red: 0.39, green: 0.45, blue: 0.95), // ETH blue
        Color(red: 0.95, green: 0.76, blue: 0.19), // BNB yellow
        Color(red: 0.0, green: 0.78, blue: 0.33),  // green
        Color(red: 0.55, green: 0.27, blue: 0.68),  // purple
        Color(red: 0.0, green: 0.69, blue: 0.85),   // cyan
    ]

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            ZStack {
                ForEach(Array(slices.enumerated()), id: \.offset) { index, slice in
                    PieSlice(startAngle: slice.start, endAngle: slice.end)
                        .fill(colors[index % colors.count])
                }
                // Inner circle for donut effect
                Circle()
                    .fill(Color.black.opacity(0.8))
                    .frame(width: size * 0.5, height: size * 0.5)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var slices: [(start: Angle, end: Angle)] {
        var result: [(start: Angle, end: Angle)] = []
        var currentAngle = Angle.degrees(-90)
        let total = holdings.reduce(0) { $0 + $1.percentage }
        guard total > 0 else { return [] }

        for holding in holdings {
            let sweep = Angle.degrees(holding.percentage / total * 360)
            result.append((start: currentAngle, end: currentAngle + sweep))
            currentAngle = currentAngle + sweep
        }
        return result
    }
}

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}
