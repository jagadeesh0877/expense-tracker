import SwiftUI

struct CurrencyPicker: View {
	@EnvironmentObject var fx: FxService
	@Binding var code: String
	
	var body: some View {
		Menu {
			ForEach(sortedCodes, id: \.self) { c in
				Button(c) { code = c }
			}
		} label: {
			HStack {
				Text(code)
				Image(systemName: "chevron.down")
			}
		}
	}
	
	private var sortedCodes: [String] { fx.currentRates.rates.keys.sorted() }
}