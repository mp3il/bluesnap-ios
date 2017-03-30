
import Foundation

class BSCurrencyRequest {
	
	// MARK: - Constants
	
	fileprivate let apiKey = ""
	fileprivate let server = ""
	
	// MARK: - Request method
	
	func request(_ completion: @escaping (Data?, NSError?) -> Void) {
        //let token = BSToken()
    
        
		let myUrl = URL(string: server + "/" + "" + "/" + apiKey + "/")
		//var request = URLRequest(url: url!)
		
		//let userAgent = ""
		//request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
		//request.setValue(token, forKey: )
        let request = URLRequest(url:myUrl!)
        
       // let task1 = URLSession.shared.dataTask(with: request as URLRequest) { }

        
        let task =  URLSession.shared.dataTask(with: request as URLRequest , completionHandler: { (data, response, error) -> Void in
			if error != nil {
				completion(nil, nil)
                print("Error -> \(error)")
			}
			else {
				completion(data, nil)
			}
		}) 
		task.resume()
	}
	
}
