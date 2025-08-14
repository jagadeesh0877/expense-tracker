import SwiftUI

struct TransactionsView: View {
	@Environment(\.managedObjectContext) private var context
	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]) private var items: FetchedResults<Transaction>
	@State private var showingAdd = false
	@EnvironmentObject var toast: ToastManager
	@StateObject private var vm = TransactionsViewModel()
	@State private var lastDeletedSnapshot: (id: UUID, date: Date, category: Category?, amountOriginal: NSDecimalNumber, currencyCode: String, amountInBase: NSDecimalNumber, note: String?, createdAt: Date, updatedAt: Date)?
	
	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			List {
				ForEach(vm.filtered(vm.sorted(items))) { t in
					HStack {
						VStack(alignment: .leading) {
							Text(t.category?.name ?? "Uncategorized").font(.headline)
							Text(Formatters.dateMedium.string(from: t.date)).font(.caption).foregroundColor(.secondary)
						}
						Spacer()
						Text(Formatters.currencyAny.string(from: t.amountOriginal) ?? "-")
					}
					.swipeActions { Button(role: .destructive) { delete(transaction: t) } label: { Label("Delete", systemImage: "trash") } }
				}
			}
			.searchable(text: $vm.query)
			.toolbar { ToolbarItem(placement: .navigationBarTrailing) { sortMenu } }
			.navigationTitle("Transactions")
			Button(action: { showingAdd = true }) {
				Image(systemName: "plus")
					.font(.title2.bold())
					.padding()
					.background(Circle().fill(Color.brandRed))
					.foregroundColor(.white)
			}
			.padding()
			ToastView().environmentObject(toast).padding(.bottom, 60)
		}
		.sheet(isPresented: $showingAdd) { AddEditExpenseView() }
	}
	
	private var sortMenu: some View {
		Menu {
			Button("Date desc") { vm.sortKey = "dateDesc" }
			Button("Date asc") { vm.sortKey = "dateAsc" }
			Button("Amount desc") { vm.sortKey = "amountDesc" }
			Button("Amount asc") { vm.sortKey = "amountAsc" }
		} label: { Image(systemName: "arrow.up.arrow.down") }
	}
	
	private func delete(transaction: Transaction) {
		lastDeletedSnapshot = (transaction.id, transaction.date, transaction.category, transaction.amountOriginal, transaction.currencyCode, transaction.amountInBase, transaction.note, transaction.createdAt, transaction.updatedAt)
		context.delete(transaction)
		do { try context.save(); showUndoToast() } catch { }
	}
	
	private func showUndoToast() {
		ToastManager.shared.show(.init(style: .warning, title: "Deleted", message: "Tap to undo", duration: 4) {
			undoDelete()
		})
	}
	
	private func undoDelete() {
		guard let snap = lastDeletedSnapshot else { return }
		let t = Transaction(context: context)
		t.id = snap.id
		t.date = snap.date
		t.category = snap.category
		t.amountOriginal = snap.amountOriginal
		t.currencyCode = snap.currencyCode
		t.amountInBase = snap.amountInBase
		t.note = snap.note
		t.createdAt = snap.createdAt
		t.updatedAt = snap.updatedAt
		try? context.save()
	}
}

extension Transaction: Identifiable {}