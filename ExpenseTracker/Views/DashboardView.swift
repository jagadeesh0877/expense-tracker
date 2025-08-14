import SwiftUI
import Charts

struct DashboardView: View {
	@EnvironmentObject var budgetService: BudgetService
	@EnvironmentObject var fx: FxService
	@EnvironmentObject var settings: Settings
	@EnvironmentObject var toast: ToastManager
	@Environment(\.managedObjectContext) private var context
	@State private var showingAdd = false
	@State private var streakDays = 0
	
	private var sampleDaily: [(Date, Double)] {
		let cal = Calendar.current
		let start = cal.date(from: cal.dateComponents([.year, .month], from: Date()))!
		return (0..<min(15, cal.range(of: .day, in: .month, for: Date())?.count ?? 30)).map { i in
			let d = cal.date(byAdding: .day, value: i, to: start)!
			return (d, Double.random(in: 10...150))
		}
	}
	
	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			ScrollView {
				VStack(spacing: 16) {
					VStack(alignment: .leading, spacing: 6) {
						Text("Dashboard").font(.largeTitle.bold())
						HStack(spacing: 8) {
							Image(systemName: "flame.fill")
								.foregroundColor(.brandRed)
							Text("Streak: \(streakDays) days").font(.subheadline).foregroundColor(.secondary)
						}
					}
					.frame(maxWidth: .infinity, alignment: .leading)
					.padding(.horizontal)
					
					HStack(spacing: 12) {
						KPIView(title: "MTD Spend", value: budgetService.monthToDateSpendBase)
						KPIView(title: "Base", value: 0)
					}
					.padding(.horizontal)
					
					GroupBox("Budgets") {
						BudgetBar(spent: (budgetService.monthToDateSpendBase as NSDecimalNumber).doubleValue, budget: 1000)
							.frame(height: 14)
					}
					.padding(.horizontal)
					
					GroupBox("Daily Spend") {
						Chart(sampleDaily, id: \.0) { (day, amount) in
							AreaMark(x: .value("Day", day), y: .value("AED", amount))
								.foregroundStyle(LinearGradient(colors: [Color.brandRed.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom))
							LineMark(x: .value("Day", day), y: .value("AED", amount))
								.foregroundStyle(Color.brandRed)
						}
						.frame(height: 180)
					}
					.padding(.horizontal)
				}
			}
			.background(Color.surface)
			Button(action: { showingAdd = true }) {
				Image(systemName: "plus")
					.font(.title2.bold())
					.padding()
					.background(Circle().fill(Color.brandRed))
					.foregroundColor(.white)
			}
			.padding()
			.overlay(ToastView().environmentObject(toast).padding(.bottom, 16), alignment: .bottom)
		}
		.sheet(isPresented: $showingAdd) { AddEditExpenseView() }
		.onAppear { Seeder.seedDefaultCategoriesIfNeeded(context: context) }
	}
}

private struct KPIView: View {
	let title: String
	let value: Decimal
	var body: some View {
		VStack(alignment: .leading) {
			Text(title).font(.caption).foregroundColor(.secondary)
			Text(Formatters.currencyAED.string(from: value as NSDecimalNumber) ?? "-")
				.font(.title3.bold())
		}
		.padding()
		.background(RoundedRectangle(cornerRadius: 12).fill(Color.white).shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2))
	}
}