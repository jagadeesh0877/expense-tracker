import Foundation
import CoreData

final class PersistenceService: ObservableObject {
	static let shared = PersistenceService()
	let container: NSPersistentContainer
	
	var viewContext: NSManagedObjectContext { container.viewContext }
	
	init(inMemory: Bool = false) {
		container = NSPersistentContainer(name: "ExpenseTracker")
		if inMemory {
			let storeDescription = NSPersistentStoreDescription()
			storeDescription.type = NSInMemoryStoreType
			container.persistentStoreDescriptions = [storeDescription]
		}
		container.loadPersistentStores { _, error in
			if let error = error { fatalError("Unresolved Core Data error: \(error)") }
		}
		container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		container.viewContext.automaticallyMergesChangesFromParent = true
	}
	
	func saveContext() {
		let context = container.viewContext
		if context.hasChanges {
			do { try context.save() } catch { print("Core Data save error: \(error)") }
		}
	}
}