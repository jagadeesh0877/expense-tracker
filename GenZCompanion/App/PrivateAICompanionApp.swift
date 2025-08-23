import SwiftUI
import StoreKit

@main
struct PrivateAICompanionApp: App {
	@StateObject private var subscriptionManager = SubscriptionManager()
	@StateObject private var modelManager = ModelManager()

	var body: some Scene {
		WindowGroup {
			RootView()
				.environmentObject(subscriptionManager)
				.environmentObject(modelManager)
		}
	}
}

struct RootView: View {
	@EnvironmentObject private var subscriptionManager: SubscriptionManager

	var body: some View {
		TabView {
			VoiceNotesView()
				.tabItem { Label("Voice", systemImage: "mic.circle.fill") }

			PDFSummarizerView()
				.tabItem { Label("PDF", systemImage: "doc.text.fill") }

			TextRewriterView()
				.tabItem { Label("Rewrite", systemImage: "pencil.and.list.clipboard") }

			UpgradeView()
				.tabItem { Label("Upgrade", systemImage: "star.circle.fill") }
		}
		.tint(.accent)
		.onAppear { subscriptionManager.start() }
	}
}