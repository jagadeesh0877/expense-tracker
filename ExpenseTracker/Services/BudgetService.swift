import Foundation
import CoreData
import Combine

final class BudgetService: ObservableObject {
	static let shared = BudgetService()
	@Published private(set) var monthToDateSpendBase: Decimal = 0
	@Published private(set) var categorySpendBase: [UUID: Decimal] = [:]
	
	private var cancellables: Set<AnyCancellable> = []
	
	func recalc(context: NSManagedObjectContext, for month: Date = Date()) {
		let start = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: month)) ?? Date()
		let end = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: start) ?? Date()
		let request = Transaction.fetchRequest()
		request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", start as NSDate, end as NSDate)
		do {
			let items = try context.fetch(request)
			let total = items.reduce(Decimal(0)) { $0 + ($1.amountInBase as Decimal? ?? 0) }
			var byCat: [UUID: Decimal] = [:]
			for t in items {
				if let id = t.category?.id { byCat[id] = (byCat[id] ?? 0) + (t.amountInBase as Decimal? ?? 0) }
			}
			DispatchQueue.main.async {
				self.monthToDateSpendBase = total
				self.categorySpendBase = byCat
			}
		} catch { }
	}
}