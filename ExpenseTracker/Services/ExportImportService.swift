import Foundation
import CoreData

struct ExportImportService {
	struct ExportCategory: Codable { let id: UUID, let name: String, let icon: String?, let colorHex: String?, let monthlyBudgetBase: Decimal? }
	struct ExportTransaction: Codable { let id: UUID, let date: Date, let categoryId: UUID?, let amountOriginal: Decimal, let currencyCode: String, let amountInBase: Decimal, let note: String?, let createdAt: Date, let updatedAt: Date }
	struct Payload: Codable { let categories: [ExportCategory], let transactions: [ExportTransaction] }
	
	static func exportAll(context: NSManagedObjectContext) throws -> Data {
		let catReq = Category.fetchRequest()
		let txReq = Transaction.fetchRequest()
		let cats = (try? context.fetch(catReq)) ?? []
		let txs = (try? context.fetch(txReq)) ?? []
		let outCats = cats.map { ExportCategory(id: $0.id, name: $0.name, icon: $0.icon, colorHex: $0.colorHex, monthlyBudgetBase: $0.monthlyBudgetBase as Decimal?) }
		let outTxs = txs.map { ExportTransaction(id: $0.id, date: $0.date, categoryId: $0.category?.id, amountOriginal: $0.amountOriginal as Decimal, currencyCode: $0.currencyCode, amountInBase: $0.amountInBase as Decimal, note: $0.note, createdAt: $0.createdAt, updatedAt: $0.updatedAt) }
		let payload = Payload(categories: outCats, transactions: outTxs)
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
		encoder.dateEncodingStrategy = .iso8601
		return try encoder.encode(payload)
	}
	
	@discardableResult
	static func importData(context: NSManagedObjectContext, data: Data, merge: Bool) throws -> (inserted: Int, updated: Int, transactions: Int) {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		let payload = try decoder.decode(Payload.self, from: data)
		var inserted = 0
		var updated = 0
		if !merge { try clearAll(context: context) }
		var idToCategory: [UUID: Category] = [:]
		// Categories
		for c in payload.categories {
			let fetch: NSFetchRequest<Category> = Category.fetchRequest()
			fetch.predicate = NSPredicate(format: "id == %@", c.id as CVarArg)
			let existing = try context.fetch(fetch).first
			let target = existing ?? Category(context: context)
			if existing == nil { inserted += 1 } else { updated += 1 }
			target.id = c.id
			target.name = c.name
			target.icon = c.icon
			target.colorHex = c.colorHex
			target.monthlyBudgetBase = (c.monthlyBudgetBase ?? 0) as NSDecimalNumber
			idToCategory[c.id] = target
		}
		// Transactions
		var txCount = 0
		for t in payload.transactions {
			let fetch: NSFetchRequest<Transaction> = Transaction.fetchRequest()
			fetch.predicate = NSPredicate(format: "id == %@", t.id as CVarArg)
			let existing = try context.fetch(fetch).first
			let target = existing ?? Transaction(context: context)
			if existing == nil { inserted += 1 } else { updated += 1 }
			target.id = t.id
			target.date = t.date
			target.category = t.categoryId.flatMap { idToCategory[$0] }
			target.amountOriginal = t.amountOriginal as NSDecimalNumber
			target.currencyCode = t.currencyCode
			target.amountInBase = t.amountInBase as NSDecimalNumber
			target.note = t.note
			target.createdAt = t.createdAt
			target.updatedAt = t.updatedAt
			txCount += 1
		}
		try context.save()
		return (inserted, updated, txCount)
	}
	
	static func clearAll(context: NSManagedObjectContext) throws {
		for entityName in ["Transaction", "Category"] {
			let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
			let batch = NSBatchDeleteRequest(fetchRequest: fetch)
			try context.execute(batch)
		}
		try context.save()
	}
}