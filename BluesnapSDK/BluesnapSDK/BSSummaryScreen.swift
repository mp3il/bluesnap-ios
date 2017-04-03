
import UIKit

class BSSummaryScreen: UIViewController {

	// MARK: - Public properties
	
	internal var rawValue: CGFloat = 0
	internal var toCurrency: String = "USD"
	
	// MARK: - Data
	
 	fileprivate var currencyManager = BSCurrencyManager()
	
	// MARK: - Outlets
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var nameUiTextyField: UITextField!
    @IBOutlet weak var cardUiTextField: UITextField!
    @IBOutlet weak var expUiTextField: UITextField!
    @IBOutlet weak var cvvUiTextField: UITextField!
    @IBOutlet weak var ccnErrorUiLabel: UILabel!
    @IBOutlet weak var nameErrorUiLabel: UILabel!
    @IBOutlet weak var expErrorUiLabel: UILabel!
    @IBOutlet weak var cvvErrorUiLabel: UILabel!
    
	// MARK: - UIViewController's methods


    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBAction func click(_ sender: UIButton) {
      
        if (validateForm()) {
            print("ready to submit!")
        }
        
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController!.isNavigationBarHidden = false
		
        let currencyCode = (toCurrency == "USD" ? "$" : toCurrency)
        payButton.setTitle(
            String(format:"Pay %@ %.2f", currencyCode, rawValue) ,
            for: UIControlState())
        
		// Get data
		currencyManager.fetchData {[weak self] (data: [AnyObject]?, error: NSError?) -> Void in
			if error == nil && data != nil {
				for item in data! {
					let currency = item as! BSCurrencyModel
					if currency.code == self!.toCurrency {
						//self!.valueLabel.text = String(self!.rawValue * currency.rate)
						break
					}
				}
			}
		}
	}
    
    // MARK: Validation methods
    
    func validateForm() -> Bool {
        
        let ok1 = validateName()
        let ok2 = validateCCN()
        let ok3 = validateExp()
        let ok4 = validateCvv()
        return ok1 && ok2 && ok3 && ok4
    }
    
    func validateCvv() -> Bool {
        
        if (cvvUiTextField.text!.characters.count < 3) {
            cvvErrorUiLabel.text = "Please fill a valid CVV number"
            cvvErrorUiLabel.isHidden = false
            return false
        } else {
            cvvErrorUiLabel.isHidden = true
            return true
        }
    }
    
    func validateName() -> Bool {
        
        nameErrorUiLabel.isHidden = true
        if (nameUiTextyField.text!.characters.count < 4) {
            nameErrorUiLabel.text = "Please fill Card holder name"
            nameErrorUiLabel.isHidden = false
            return false
        }
        return true
    }
    
    func validateCCN() -> Bool {
        
        ccnErrorUiLabel.isHidden = true
        // TODO: need to add lohn check as well
        if (cardUiTextField.text!.characters.count < 7) {
            ccnErrorUiLabel.text = "Please fill a valid Credirt Card number"
            ccnErrorUiLabel.isHidden = false
            return false
        }
        return true
    }
    
    func validateExp() -> Bool {
        var ok = true
        let input = expUiTextField.text!
        if (input.characters.count < 5) {
            ok = false
        } else {
            let idx = input.index(input.startIndex, offsetBy: 2)
            let monthStr = input.substring(with: input.startIndex..<idx)
            if !monthStr.isValidMonth {
                ok = false
            }
        }
        if (ok) {
            expErrorUiLabel.isHidden = true
        } else {
            expErrorUiLabel.text = "Please fill a valid exiration date"
            expErrorUiLabel.isHidden = false
        }
        return ok
    }

    
    // MARK: real-time formatting and Validations on text fields
    
    @IBAction func nameEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = input.removeNoneAlphaCharacters.cutToMaxLength(maxLength: 100)
        sender.text = input
    }
    
    @IBAction func ccnEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = input.removeNoneDigits.cutToMaxLength(maxLength: 21).formatCCN
        sender.text = input
    }
    
    @IBAction func expEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = input.removeNoneDigits.cutToMaxLength(maxLength: 4).formatExp
        sender.text = input
    }
    
    @IBAction func cvvEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = input.removeNoneDigits.cutToMaxLength(maxLength: 4)
        sender.text = input
    }
    
    @IBAction func nameEditingDidEnd(_ sender: UITextField) {
        _ = validateName()
    }
    
    @IBAction func cvvEditingDidEnd(_ sender: UITextField) {
        _ = validateCvv()
    }
    
    @IBAction func expEditingDidEnd(_ sender: UITextField) {
        _ = validateExp()
    }
    
    @IBAction func cardEditingDidEnd(_ sender: UITextField) {
        _ = validateCCN()
    }
   


}

extension String {
    
    var isValidMonth : Bool {
        
        let validMonths = ["01","02","03","04","05","06","07","08","09","10","11","12"]
        return validMonths.contains(self)
    }
    
    var removeNoneAlphaCharacters : String {
        
        var result : String = "";
        for character in characters {
            if (character == " ") || (character >= "a" && character <= "z") || (character >= "A" && character <= "Z") {
                result.append(character)
            }
        }
        return result
    }
    
    var removeNoneDigits : String {
        
        var result : String = "";
        for character in characters {
            if (character >= "0" && character <= "9") {
                result.append(character)
            }
        }
        return result
    }

    func cutToMaxLength(maxLength: Int) -> String {
        if (characters.count < maxLength) {
            return self
        } else {
            let idx = index(startIndex, offsetBy: maxLength)
            return substring(with: startIndex..<idx)
        }
    }
    
    var formatExp : String {
        
        var result : String
        if characters.count < 2 {
            result = self
        } else {
            let idx = index(startIndex, offsetBy: 2)
            result = substring(with: startIndex..<idx) + "/"
            result += substring(with: idx..<endIndex)
        }
        return result
    }
    
    var formatCCN : String {

        var result: String
        let myLength = characters.count
        if (myLength > 4) {
            let idx1 = index(startIndex, offsetBy: 4)
            result = substring(to: idx1) + " "
            if (myLength > 8) {
                let idx2 = index(idx1, offsetBy: 4)
                result += substring(with: idx1..<idx2) + " "
                if (myLength > 12) {
                    let idx3 = index(idx2, offsetBy: 4)
                    result += substring(with: idx2..<idx3) + " " + substring(from: idx3)
                } else {
                    result += substring(from:idx2)
                }
            } else {
                result += substring(from: idx1)
            }
        } else {
            result = self
        }
        return result;
    }
}

