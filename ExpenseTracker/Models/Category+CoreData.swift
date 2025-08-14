import Foundation
import CoreData

@objc(Category)
public class Category: NSManagedObject {
}

extension Category {
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
		return NSFetchRequest<Category>(entityName: "Category")
	}
	
	@NSManaged public var id: UUID
	@NSManaged public var name: String
	@NSManaged public var icon: String?
	@NSManaged public var colorHex: String?
	@NSManaged public var monthlyBudgetBase: NSDecimalNumber?
	@NSManaged public var transactions: NSSet?
}

// MARK: Generated accessors for transactions
extension Category {
	@objc(addTransactionsObject:)
	@NSManaged public func addToTransactions(_ value: Transaction)

	@objc(removeTransactionsObject:)
	@NSManaged public func removeFromTransactions(_ value: Transaction)

	@objc(addTransactions:)
	@NSManaged public func addToTransactions(_ values: NSSet)

	@objc(removeTransactions:)
	@NSManaged public func removeFromTransactions(_ values: NSSet)
}