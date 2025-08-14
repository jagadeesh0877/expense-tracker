import Foundation

enum Formatters {
	static let currencyAED: NumberFormatter = {
		let nf = NumberFormatter()
		nf.numberStyle = .currency
		nf.currencyCode = FxRates.baseCurrencyCode
		nf.maximumFractionDigits = 2
		return nf
	}()
	
	static let currencyAny: NumberFormatter = {
		let nf = NumberFormatter()
		nf.numberStyle = .currency
		nf.maximumFractionDigits = 2
		return nf
	}()
	
	static let dateMedium: DateFormatter = {
		let df = DateFormatter()
		df.dateStyle = .medium
		df.timeStyle = .none
		return df
	}()
}