import SwiftUI
import CoreData

struct AddEditExpenseView: View {
	@Environment(\.managedObjectContext) private var context
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject var fx: FxService
	
	@State private var amountText: String = ""
	@State private var currencyCode: String = "AED"
	@State private var date: Date = Date()
	@State private var note: String = ""
	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]) private var categories: FetchedResults<Category>
	@State private var selectedCategory: Category?
	
	private var amountDecimal: Decimal { Decimal(string: amountText) ?? 0 }
	private var amountInAED: Decimal? { fx.convertToBase(amount: amountDecimal, currencyCode: currencyCode) }
	
	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("Amount")) {
					HStack {
						TextField("0.00", text: $amountText).keyboardType(.decimalPad)
						CurrencyPicker(code: $currencyCode)
					}
					if currencyCode.uppercased() != FxRates.baseCurrencyCode {
						Text("≈ " + (Formatters.currencyAED.string(from: (amountInAED ?? 0) as NSDecimalNumber) ?? "-"))
							.font(.caption)
					}
				}
				Section(header: Text("Category")) {
					CategoryGrid(selected: $selectedCategory)
				}
				Section(header: Text("Date")) {
					DatePicker("Date", selection: $date, displayedComponents: .date)
				}
				Section(header: Text("Note")) {
					TextField("Optional", text: $note)
				}
				Section {
					Button(action: save) { Text("Save") }.buttonStyle(BrandButtonStyle())
				}
			}
			.navigationTitle("Add Expense")
			.toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
		}
	}
	
	private func save() {
		let t = Transaction(context: context)
		t.id = UUID()
		t.date = date
		t.category = selectedCategory
		t.amountOriginal = amountDecimal as NSDecimalNumber
		t.currencyCode = currencyCode.uppercased()
		let base = amountInAED ?? amountDecimal
		t.amountInBase = base as NSDecimalNumber
		t.note = note.isEmpty ? nil : note
		t.createdAt = Date()
		t.updatedAt = Date()
		do { try context.save(); dismiss() } catch { }
	}
}