import Foundation

class BSCurrencyStorage {
	
	// MARK: - Constants
	
	fileprivate let entityName = ""
	
	// MARK: - Data
	
	fileprivate var data = Array<BSCurrencyModel>()
	
	// MARK: - Data fetching
	
	init() {
		
		// Fake data
		let item1 = BSCurrencyModel()
		item1.code = "USD"
		item1.rate = 25.55
		
		let item2 = BSCurrencyModel()
		item2.code = "EUR"
		item2.rate = 28.5
		
		let item3 = BSCurrencyModel()
		item3.code = "CAD"
		item3.rate = 15.6
		
		let item4 = BSCurrencyModel()
		item4.code = "UAH"
		item4.rate = 85.6
		
		data.append(item1)
		data.append(item2)
		data.append(item3)
		data.append(item4)
	}
	
	func fetchData() -> [AnyObject]? {
		return data
	}
	
	func fetchTypesCount() -> Int {
		return data.count
	}
	
	func hasData() -> Bool {
		return data.count > 0
	}
	
	// MARK: - Save
	
	func save() {
	}
	
	// MARK: - Storing
	
	func store(_ data: Array<AnyObject?>) {
	}
	
	fileprivate func store(_ data: AnyObject!) {
	}
	
}
