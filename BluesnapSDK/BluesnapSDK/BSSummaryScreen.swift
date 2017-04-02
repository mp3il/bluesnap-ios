
import UIKit

class BSSummaryScreen: UIViewController, UITextFieldDelegate {

	// MARK: - Public properties
	
	internal var rawValue: CGFloat = 0
	internal var toCurrency: String = "USD"
	
	// MARK: - Data
	
    @IBOutlet weak var nameUIText: UITextField!
	fileprivate var currencyManager = BSCurrencyManager()
	
	// MARK: - Outlets
    
    @IBOutlet weak var cardUIText: UITextField!
    @IBOutlet weak var valueLabel: UILabel!
	@IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var paySubmit: UIButton!
    
	// MARK: - UIViewController's methods
	
   // let validator = Validator()


    override func viewDidLoad() {
        super.viewDidLoad()
        cardUIText.delegate = self
        
//        validator.registerField(cardUIText, errorLabel: valueLabel,
//            rules: [RequiredRule(), CreditCardNumberRule()]
//        )
        
        paySubmit.setTitle(
            String(format:"Pay %8.2f %@", rawValue, toCurrency) ,
            for: UIControlState())
    }
    

    @IBAction func click(_ sender: UIButton) {
      //  validator.validate(self)
    }
    
    
    
    // ValidationDelegate methods
    func validationSuccessful() {
        // submit the form
    }
    
//    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
//        // turn the fields to red
//        for (field, error) in errors {
//            if let field = field as? UITextField {
//                field.layer.borderColor = UIColor.red.cgColor
//                field.layer.borderWidth = 1.0
//                error.errorLabel?.text = error.errorMessage // works if you added labels
//                error.errorLabel?.isHidden = false
//            } else {
//                if let field = field as? UITextField {
//                    field.layer.borderColor = UIColor.black.cgColor
//                    error.errorLabel?.isHidden = true
//                }
//            }
//        }
//    
//        
//        
//    }
    
    
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController!.isNavigationBarHidden = false
		
        paySubmit.setTitle(
            String(format:"Pay %8.2f %@", rawValue, toCurrency) ,
            for: UIControlState())
        
        //currencyLabel.text = toCurrency
		
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
    
    
    @IBAction func NameEditingChanged(_ sender: UITextField) {
        
        let input : String = sender.text ?? ""
        let ok = input.isAlphaNumeric;
        
        print(input)
        print(ok)
    }
    
    @IBAction func ccNumEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        //print(input)
        input = input.removeNoneDigits.formatCCN
        //print(input)
        sender.text = input
    }


}

extension String {
    
    var isAlphaNumeric : Bool {
 
        let allowedAlphaCharacters = "abcdefghijklmnopqrstuvwxyz "
        let alphaCharset = CharacterSet(charactersIn: allowedAlphaCharacters)
        return lowercased().rangeOfCharacter(from: alphaCharset.inverted) == nil
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
                    result += substring(with: idx2..<idx3) + " "
                    result += substring(from: idx3)
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

