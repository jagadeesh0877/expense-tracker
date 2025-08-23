import Foundation

enum AIModel: String, CaseIterable {
	case whisperSmall = "whisper-small.q5" // example
	case summarizerLlama3 = "llama3-8b-int4.mlmodelc"
	case rewriterMini = "phi3-mini-int4.mlmodelc"

	var suggestedSizeMB: Int {
		switch self {
		case .whisperSmall: return 120
		case .summarizerLlama3: return 800 // compiled CoreML can be large; plan on-demand
		case .rewriterMini: return 120
		}
	}
}

final class ModelManager: ObservableObject {
	@Published private(set) var installed: Set<AIModel> = []
	private let fileManager = FileManager.default

	init() {
		loadInstalled()
	}

	func isInstalled(_ model: AIModel) -> Bool {
		installed.contains(model)
	}

	func localURL(for model: AIModel) -> URL {
		let dir = applicationSupportURL().appendingPathComponent("Models", isDirectory: true)
		return dir.appendingPathComponent(model.rawValue)
	}

	func ensureInstalled(_ model: AIModel) async throws {
		if isInstalled(model) { return }
		// For MVP, try to move from app bundle if present; otherwise mark missing.
		let bundleURL = Bundle.main.url(forResource: model.rawValue, withExtension: nil)
		let target = localURL(for: model)
		try fileManager.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
		if let bundleURL {
			try copyIfNeeded(from: bundleURL, to: target)
			markInstalled(model)
		} else {
			// Placeholder: trigger background download after install (requires connectivity)
			throw NSError(domain: "ModelManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Model not bundled: \(model.rawValue)"])
		}
	}

	private func copyIfNeeded(from: URL, to: URL) throws {
		if fileManager.fileExists(atPath: to.path) { return }
		try fileManager.copyItem(at: from, to: to)
	}

	private func applicationSupportURL() -> URL {
		let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
		let base = urls[0].appendingPathComponent("GenZCompanion", isDirectory: true)
		try? fileManager.createDirectory(at: base, withIntermediateDirectories: true)
		return base
	}

	private func loadInstalled() {
		var set: Set<AIModel> = []
		for model in AIModel.allCases {
			if fileManager.fileExists(atPath: localURL(for: model).path) { set.insert(model) }
		}
		installed = set
	}

	private func markInstalled(_ model: AIModel) {
		installed.insert(model)
	}
}