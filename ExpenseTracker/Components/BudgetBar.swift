import SwiftUI

struct BudgetBar: View {
	let spent: Double
	let budget: Double
	
	private var ratio: Double { guard budget > 0 else { return 0 }; return spent / budget }
	private var color: Color { ratio >= 1 ? .brandRed : (ratio >= 0.8 ? .amber : .brandRed.opacity(0.8)) }
	
	@State private var shake: Bool = false
	
	var body: some View {
		GeometryReader { geo in
			ZStack(alignment: .leading) {
				RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.15))
				RoundedRectangle(cornerRadius: 8).fill(color)
					.frame(width: geo.size.width * min(max(ratio, 0), 1))
			}
		}
		.frame(height: 12)
		.onChange(of: ratio) { newValue in
			if newValue >= 1.0 { withAnimation(.default) { shake.toggle() } }
		}
		.modifier(Shake(animates: shake))
	}
}

private struct Shake: GeometryEffect {
	var animates: Bool
	var amount: CGFloat = 4
	var shakesPerUnit = 3
	var animatableData: CGFloat { animates ? 1 : 0 }
	func effectValue(size: CGSize) -> ProjectionTransform {
		let translation = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
		return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
	}
}