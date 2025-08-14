import Foundation
import CoreData

@objc(Transaction)
public class Transaction: NSManagedObject {
}

extension Transaction {
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
		return NSFetchRequest<Transaction>(entityName: "Transaction")
	}
	
	@NSManaged public var id: UUID
	@NSManaged public var date: Date
	@NSManaged public var amountOriginal: NSDecimalNumber
	@NSManaged public var currencyCode: String
	@NSManaged public var amountInBase: NSDecimalNumber
	@NSManaged public var note: String?
	@NSManaged public var createdAt: Date
	@NSManaged public var updatedAt: Date
	@NSManaged public var category: Category?
}