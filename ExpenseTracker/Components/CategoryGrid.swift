import SwiftUI
import CoreData

struct CategoryGrid: View {
	@FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)]) private var items: FetchedResults<Category>
	@Binding var selected: Category?
	
	var body: some View {
		LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
			ForEach(items) { c in
				Button(action: { selected = c }) {
					VStack(spacing: 6) {
						Text(c.icon ?? "🧾").font(.title2)
						Text(c.name).font(.footnote).lineLimit(1)
					}
					.frame(maxWidth: .infinity)
					.padding()
					.background(RoundedRectangle(cornerRadius: 12).fill((selected == c) ? Color.brandRed.opacity(0.1) : Color.white))
					.overlay(RoundedRectangle(cornerRadius: 12).stroke((selected == c) ? Color.brandRed : Color.gray.opacity(0.2), lineWidth: 1))
				}
			}
		}
	}
}