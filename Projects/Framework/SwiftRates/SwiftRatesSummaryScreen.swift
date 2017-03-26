//
//  SwiftRatesSummaryViewController.swift
//  SwiftRates
//
//

import UIKit

class SwiftRatesSummaryScreen: UIViewController, UITextFieldDelegate {

	// MARK: - Public properties
	
	internal var rawValue: CGFloat = 0
	internal var toCurrency: String = "USD"
	
	// MARK: - Data
	
    @IBOutlet weak var nameUIText: UITextField!
	fileprivate var currencyManager = SwiftRatesCurrencyManager()
	
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
			if error == nil {
				for item in data! {
					let currency = item as! SwiftRatesCurrency
					if currency.code == self!.toCurrency {
						//self!.valueLabel.text = String(self!.rawValue * currency.rate)
						break
					}
				}
			}
		}
	}

}
