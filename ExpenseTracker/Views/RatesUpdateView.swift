import SwiftUI

struct RatesUpdateView: View {
	@EnvironmentObject var fx: FxService
	@State private var pastedJSON: String = ""
	@State private var codeToEdit: String = "USD"
	@State private var aedToValue: String = ""
	@State private var errorText: String? = nil
	
	var body: some View {
		Form {
			Section(header: Text("Current")) {
				Text("Base: \(fx.currentRates.base)")
				Text("As of: \(fx.currentRates.asOf.formatted())")
				Text("Last updated: \(fx.currentRates.lastUpdated.formatted())")
				DisclosureGroup("Rates (") { Text("Count: \(fx.currentRates.rates.count)") } label: { Text("Rates (\(fx.currentRates.rates.count))") }
			}
			Section(header: Text("Actions")) {
				Button("Fetch now") { Task { _ = await fx.refreshRates(reason: .manual) } }
			}
			Section(header: Text("Paste AED-base JSON"), footer: { if let errorText { Text(errorText).foregroundColor(.red) } else { EmptyView() } }) {
				TextEditor(text: $pastedJSON).frame(minHeight: 120)
				Button("Apply JSON") { applyJSON() }
			}
			Section(header: Text("Edit Pair (AED→X)")) {
				HStack {
					TextField("Code", text: $codeToEdit).textInputAutocapitalization(.characters).autocorrectionDisabled(true).frame(width: 80)
					TextField("Rate", text: $aedToValue).keyboardType(.decimalPad)
				}
				Button("Save Rate") { savePair() }
			}
		}
		.navigationTitle("FX Rates")
	}
	
	private func applyJSON() {
		errorText = nil
		guard let data = pastedJSON.data(using: .utf8) else { return }
		do { try fx.applyPastedJSON(data) } catch { errorText = error.localizedDescription }
	}
	
	private func savePair() {
		guard let rate = Double(aedToValue), !codeToEdit.isEmpty else { return }
		fx.updateRate(code: codeToEdit, aedToCurrency: rate)
	}
}