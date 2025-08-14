import SwiftUI
import CoreData

struct CategoriesView: View {
	@Environment(\.managedObjectContext) private var context
	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]) private var items: FetchedResults<Category>
	@State private var showingAdd = false
	@EnvironmentObject var toast: ToastManager
	@State private var newName: String = ""
	@State private var newIcon: String = ""
	
	var body: some View {
		ZStack(alignment: .bottom) {
			List {
				ForEach(items) { c in
					HStack {
						Text(c.icon ?? "").frame(width: 28)
						Text(c.name)
						Spacer()
						if let budget = c.monthlyBudgetBase {
							Text(Formatters.currencyAED.string(from: budget) ?? "-")
						}
					}
					.swipeActions(edge: .trailing) {
						Button(role: .destructive) { delete(c) } label: { Label("Delete", systemImage: "trash") }
					}
				}
			}
			.navigationTitle("Categories")
			.toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button(action: { showingAdd = true }) { Image(systemName: "plus") } } }
			.sheet(isPresented: $showingAdd) { addSheet }
			ToastView().environmentObject(toast).padding(.bottom, 16)
		}
	}
	
	private var addSheet: some View {
		NavigationView {
			Form {
				TextField("Name", text: $newName)
				TextField("Icon (emoji or SF symbol)", text: $newIcon)
			}
			.navigationTitle("New Category")
			.toolbar {
				ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showingAdd = false } }
				ToolbarItem(placement: .confirmationAction) { Button("Add") { add() }.disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) }
			}
		}
	}
	
	private func add() {
		let c = Category(context: context)
		c.id = UUID()
		c.name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
		c.icon = newIcon.isEmpty ? nil : newIcon
		c.monthlyBudgetBase = 0
		do { try context.save(); showingAdd = false; newName = ""; newIcon = "" } catch { }
	}
	
	private func delete(_ c: Category) {
		context.delete(c)
		do { try context.save() } catch { }
	}
}

extension Category: Identifiable {}