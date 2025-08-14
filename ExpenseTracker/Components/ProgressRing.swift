import SwiftUI

struct ProgressRing: View {
	let progress: Double // 0...1
	
	var color: Color {
		if progress >= 1.0 { return .brandRed }
		if progress >= 0.8 { return .amber }
		return .brandRed.opacity(0.7)
	}
	
	var body: some View {
		ZStack {
			Circle().trim(from: 0, to: CGFloat(progress)).stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round)).rotationEffect(.degrees(-90))
			Circle().stroke(Color.gray.opacity(0.15), lineWidth: 8)
		}
		.animation(.spring(), value: progress)
	}
}