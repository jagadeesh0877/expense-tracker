import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
	@EnvironmentObject var settings: Settings
	@EnvironmentObject var toast: ToastManager
	@Environment(\.managedObjectContext) private var context
	@State private var exportURL: URL?
	@State private var showingImporter = false
	@State private var importData: Data?
	
	var body: some View {
		ZStack(alignment: .bottom) {
			NavigationView {
				Form {
					Section(header: Text("Currency"), footer: Text("Base currency is fixed to AED across the app.")) {
						HStack { Text("Base currency"); Spacer(); Text("AED").foregroundColor(.secondary) }
					}
					Section(header: Text("Preferences")) {
						Picker("Week starts on", selection: $settings.weekStartsOn) {
							Text("Sunday").tag("sun")
							Text("Monday").tag("mon")
						}
						Toggle("Privacy mode", isOn: $settings.privacyMode)
						Picker("Density", selection: $settings.density) {
							Text("Compact").tag("compact")
							Text("Cozy").tag("cozy")
						}
						Slider(value: $settings.fontScale, in: 0.9...1.3, step: 0.05) { Text("Font scale") }
					}
					Section(header: Text("Rates")) {
						NavigationLink(destination: RatesUpdateView()) { Text("FX Rates") }
					}
					Section(header: Text("Data")) {
						Button("Export JSON") { export() }
						Button("Import JSON (merge)") { showingImporter = true }
						Button(role: .destructive, action: clearAll) { Text("Clear all data") }
					}
				}
				.navigationTitle("Settings")
			}
			ToastView().environmentObject(toast).padding(.bottom, 16)
		}
		.fileImporter(isPresented: $showingImporter, allowedContentTypes: [UTType.json]) { result in
			if case let .success(url) = result, let data = try? Data(contentsOf: url) {
				importData = data
				if let data = importData, let summary = try? ExportImportService.importData(context: context, data: data, merge: true) {
					ToastManager.shared.show(.init(style: .success, title: "Imported", message: "Inserted: \(summary.inserted), Updated: \(summary.updated)"))
				}
			}
		}
	}
	
	private func export() {
		do {
			let data = try ExportImportService.exportAll(context: context)
			let url = FileManager.default.temporaryDirectory.appendingPathComponent("ExpenseTracker-export.json")
			try data.write(to: url)
			exportURL = url
			ToastManager.shared.show(.init(style: .info, title: "Exported", message: url.lastPathComponent))
		} catch {
			ToastManager.shared.show(.init(style: .error, title: "Export failed"))
		}
	}
	
	private func clearAll() {
		do { try ExportImportService.clearAll(context: context); ToastManager.shared.show(.init(style: .success, title: "Cleared")) } catch { }
	}
}