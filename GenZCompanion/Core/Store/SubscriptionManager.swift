import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
	@Published private(set) var products: [Product] = []
	@Published private(set) var isProActive: Bool = false

	let entitlement = EntitlementGating()

	private let productIds: Set<String> = [
		"genzcompanion.pro.monthly"
	]

	func start() {
		Task { await refreshProductsAndEntitlements() }
		Task { await listenForTransactions() }
	}

	func refreshProductsAndEntitlements() async {
		do {
			products = try await Product.products(for: Array(productIds))
			for await result in Transaction.currentEntitlements {
				if case .verified(let transaction) = result {
					await updateEntitlements(from: transaction)
				}
			}
		} catch {
			print("[Store] Error fetching products: \(error)")
		}
	}

	func purchase(_ product: Product) async throws {
		let result = try await product.purchase()
		switch result {
		case .success(let verification):
			if case .verified(let transaction) = verification {
				await updateEntitlements(from: transaction)
				await transaction.finish()
			}
		case .userCancelled, .pending:
			break
		@unknown default:
			break
		}
	}

	func restore() async {
		for await result in Transaction.currentEntitlements {
			if case .verified(let transaction) = result {
				await updateEntitlements(from: transaction)
			}
		}
	}

	private func listenForTransactions() async {
		for await result in Transaction.updates {
			if case .verified(let transaction) = result {
				await updateEntitlements(from: transaction)
				await transaction.finish()
			}
		}
	}

	private func updateEntitlements(from transaction: Transaction) async {
		switch transaction.productType {
		case .autoRenewable, .nonRenewable:
			let isActive = transaction.revocationDate == nil && transaction.isUpgraded == false && (transaction.expirationDate ?? .distantFuture) > Date()
			isProActive = isActive
			entitlement.setPro(isActive)
		default:
			break
		}
	}
}