import SwiftUI
import StoreKit

struct UpgradeView: View {
	@EnvironmentObject private var subscriptionManager: SubscriptionManager
	@State private var purchasing: Bool = false

	var body: some View {
		NavigationView {
			VStack(spacing: 16) {
				Text("Your AI, private & offline. No signup. No cloud.")
					.font(.headline)
					.multilineTextAlignment(.center)
					.padding(.top)

				if subscriptionManager.isProActive {
					Label("Pro Active", systemImage: "checkmark.seal.fill").foregroundStyle(.green)
				} else {
					Text("Free: 10 summaries/notes per month")
						.font(.subheadline)
				}

				List(subscriptionManager.products, id: \.id) { product in
					VStack(alignment: .leading) {
						Text(product.displayName).font(.headline)
						Text(product.displayPrice).font(.subheadline)
					}
					.onTapGesture { Task { await buy(product) } }
				}
				.listStyle(.insetGrouped)
				.frame(maxHeight: 240)

				Button("Restore Purchases") { Task { await subscriptionManager.restore() } }
					.buttonStyle(.bordered)

				Spacer()
			}
			.padding()
			.navigationTitle("Upgrade")
		}
	}

	private func buy(_ product: Product) async {
		purchasing = true
		defer { purchasing = false }
		do { try await subscriptionManager.purchase(product) } catch { print("Purchase failed: \(error)") }
	}
}