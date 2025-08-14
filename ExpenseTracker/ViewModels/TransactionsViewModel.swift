import Foundation
import CoreData

final class TransactionsViewModel: ObservableObject {
	@Published var query: String = ""
	@Published var sortKey: String = "dateDesc"
	
	func sorted(_ items: FetchedResults<Transaction>) -> [Transaction] {
		var arr = Array(items)
		switch sortKey {
		case "dateAsc": arr.sort { $0.date < $1.date }
		case "amountDesc": arr.sort { ($0.amountInBase as Decimal) > ($1.amountInBase as Decimal) }
		case "amountAsc": arr.sort { ($0.amountInBase as Decimal) < ($1.amountInBase as Decimal) }
		default: arr.sort { $0.date > $1.date }
		}
		return arr
	}
	
	func filtered(_ items: [Transaction]) -> [Transaction] {
		guard !query.isEmpty else { return items }
		return items.filter { t in
			let note = t.note ?? ""
			return note.localizedCaseInsensitiveContains(query) || (t.category?.name ?? "").localizedCaseInsensitiveContains(query)
		}
	}
}