import SwiftUI
import BackgroundTasks

@main
struct ExpenseTrackerApp: App {
	@Environment(\.scenePhase) private var scenePhase
	
	@StateObject private var persistenceService = PersistenceService.shared
	@StateObject private var toastManager = ToastManager.shared
	@StateObject private var settings = Settings.shared
	@StateObject private var fxService = FxService.shared
	@StateObject private var budgetService = BudgetService.shared
	
	init() {
		FxRefreshScheduler.register()
	}
	
	var body: some Scene {
		WindowGroup {
			RootOverlay {
				RootView()
			}
			.environment(\.managedObjectContext, persistenceService.viewContext)
			.environmentObject(toastManager)
			.environmentObject(settings)
			.environmentObject(fxService)
			.environmentObject(budgetService)
			.onAppear { budgetService.recalc(context: persistenceService.viewContext) }
		}
		.onChange(of: scenePhase) { newPhase in
			switch newPhase {
			case .active:
				fxService.refreshIfNeeded(reason: .appLaunchOrForeground)
				FxRefreshScheduler.scheduleDailyRefresh()
				budgetService.recalc(context: persistenceService.viewContext)
			default:
				break
			}
		}
	}
}

private struct RootView: View {
	var body: some View {
		TabView {
			DashboardView()
				.tabItem { Label("Dashboard", systemImage: "chart.pie") }
			TransactionsView()
				.tabItem { Label("Transactions", systemImage: "list.bullet") }
			CategoriesView()
				.tabItem { Label("Categories", systemImage: "square.grid.2x2") }
			SettingsView()
				.tabItem { Label("Settings", systemImage: "gearshape") }
		}
		.accentColor(Color.brandRed)
	}
}