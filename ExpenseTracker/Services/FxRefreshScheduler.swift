import Foundation
import BackgroundTasks

enum FxRefreshScheduler {
	static let identifier = "com.expensetracker.fxrefresh"
	
	static func register() {
		BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil) { task in
			let fx = FxService.shared
			// Use gated refresh to ensure at most one attempt per local day
			fx.refreshIfNeeded(reason: .backgroundTask)
			scheduleDailyRefresh()
			task.setTaskCompleted(success: true)
		}
	}
	
	static func scheduleDailyRefresh() {
		let request = BGAppRefreshTaskRequest(identifier: identifier)
		request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60 * 18)
		do { try BGTaskScheduler.shared.submit(request) } catch { }
	}
}