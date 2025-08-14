import Foundation
import CoreData

enum Seeder {
	static func seedDefaultCategoriesIfNeeded(context: NSManagedObjectContext) {
		let fetch: NSFetchRequest<Category> = Category.fetchRequest()
		fetch.fetchLimit = 1
		if let count = try? context.count(for: fetch), count > 0 { return }
		let defaults: [(String, String)] = [
			("Food", "fork.knife"),
			("Transport", "car.fill"),
			("Groceries", "cart.fill"),
			("Utilities", "bolt.fill"),
			("Rent", "house.fill"),
			("Entertainment", "gamecontroller.fill"),
			("Health", "heart.fill"),
			("Education", "book.fill"),
			("Shopping", "bag.fill"),
			("Travel", "airplane"),
			("Misc", "ellipsis.circle")
		]
		for (name, symbol) in defaults {
			let c = Category(context: context)
			c.id = UUID()
			c.name = name
			c.icon = symbol
			c.colorHex = nil
			c.monthlyBudgetBase = 0
		}
		try? context.save()
	}
}