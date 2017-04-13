//
//  BSCurrencyManager.swift
//  BS
//
//

import Foundation

class BSCurrencyManager : NSObject {
	
	// MARK: - Properties
	/*
	fileprivate let request = BSCurrencyRequest()
	fileprivate let parser = BSCurrencyParser()
	fileprivate let storage = BSCurrencyStorage()
	
	// MARK: - Last Time
	
	fileprivate let lastTimeRequestKey = "lastTimeRequest"
	fileprivate var lastTimeRequest: Date!
	
	// MARK: - User defaults
	
	fileprivate let userDefaults: UserDefaults! = UserDefaults()
	
	// MARK: - Initialization
	
	override init() {
		super.init()
		
		if let date = userDefaults.object(forKey: lastTimeRequestKey) as? Date {
			lastTimeRequest = date
        } else {
            // supply default = current date
            lastTimeRequest = Date()
        }
	}
	
	// MARK: - Data Fetching
	
	func fetchData(_ offlineCompletion: @escaping ([AnyObject]?, NSError?) -> Void) {
        
        DispatchQueue.global(qos: .default).async {
			var data: [AnyObject]?
            
			if self.storage.hasData() {
				data = self.storage.fetchData()
			}
			DispatchQueue.main.async {
				offlineCompletion(data, nil)
			}
		}
	}
	
	func fetchData(_ offlineCompletion: @escaping ([AnyObject]?, NSError?) -> Void, onlineCompletion: @escaping ([AnyObject]?, NSError?) -> Void) {
		
		fetchData(offlineCompletion)
		
		DispatchQueue.global(qos: .default).async {
			
			var data: [AnyObject]?
			
			if self.lastTimeRequest == nil || Date().timeIntervalSince(self.lastTimeRequest) > 5 * 60 {
				
				self.lastTimeRequest = Date()
				self.userDefaults.set(self.lastTimeRequest, forKey: self.lastTimeRequestKey)
				self.userDefaults.synchronize()
				
//				let semaphore = dispatch_semaphore_create(0)
//				
//				self.request.request({ (data: NSData!, error: NSError!) -> Void in
//					if error == nil {
//						let data = self.parser.parse(data)
//						if data.count > 0 {
//							self.storage.store(data)
//						}
//					}
//					
//					dispatch_semaphore_signal(semaphore)
//				})
//				
//				dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//				
//				self.storage.save()
				
				data = self.storage.fetchData()
				
				DispatchQueue.main.async {
					onlineCompletion(data, nil)
				}
			}
		}
	}
	
	func fetchTypesCount() -> Int {
		return storage.fetchTypesCount()
	}
    
    
    static func luhnCheck(_ cardNumber: String) -> Bool {
        var sum = 0
        let reversedCharacters = cardNumber.characters.reversed().map { String($0) }
        for (idx, element) in reversedCharacters.enumerated() {
            guard let digit = Int(element) else { return false }
            switch ((idx % 2 == 1), digit) {
            case (true, 9): sum += 9
            case (true, 0...8): sum += (digit * 2) % 9
            default: sum += digit
            }
        }
        return sum % 10 == 0
    }*/
	
}
