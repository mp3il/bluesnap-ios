
import UIKit

class BSSummaryScreen: UIViewController {

	// MARK: - Public properties
	
    internal var purchaseData : PurchaseData?
    
    // MARK: private properties
    
    var withShipping = false
    var shippingScreen: BSShippingViewController!
    
    // MARK: Constants
    
    let privacyPolicyURL = "http://home.bluesnap.com/ecommerce/legal/privacy-policy/"
    let refundPolicyURL = "http://home.bluesnap.com/ecommerce/legal/refund-policy/"
    let termsURL = "http://home.bluesnap.com/ecommerce/legal/terms-and-conditions/"
	
	// MARK: - Data
	
 	fileprivate var currencyManager = BSCurrencyManager()
    fileprivate var payButtonText : String?
	
	// MARK: - Outlets
    
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var shippingButton: UIButton!
    @IBOutlet weak var nameUiTextyField: UITextField!
    @IBOutlet weak var cardUiTextField: UITextField!
    @IBOutlet weak var expUiTextField: UITextField!
    @IBOutlet weak var cvvUiTextField: UITextField!
    @IBOutlet weak var ccnErrorUiLabel: UILabel!
    @IBOutlet weak var nameErrorUiLabel: UILabel!
    @IBOutlet weak var expErrorUiLabel: UILabel!
    @IBOutlet weak var cvvErrorUiLabel: UILabel!
    @IBOutlet weak var subtotalUILabel: UILabel!
    @IBOutlet weak var taxAmountUILabel: UILabel!
    @IBOutlet weak var menuWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuCurrencyButton: UIButton!

    
	// MARK: - UIViewController's methods


    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController!.isNavigationBarHidden = false
		
        payButton.isHidden = self.withShipping
        shippingButton.isHidden = !self.withShipping

        let toCurrency = purchaseData!.getCurrency()
        let subtotalAmount = purchaseData!.getAmount()
        let taxAmount = purchaseData!.getTaxAmount()
        let amount = subtotalAmount + taxAmount
        self.withShipping = purchaseData!.getShippingDetails() != nil
        
        let currencyCode = (toCurrency == "USD" ? "$" : toCurrency)
        payButtonText = String(format:"Pay %@ %.2f", currencyCode, CGFloat(amount))
        payButton.setTitle(payButtonText, for: UIControlState())
        subtotalUILabel.text = String(format:"%@ %.2f", currencyCode, CGFloat(subtotalAmount))
        taxAmountUILabel.text = String(format:"%@ %.2f", currencyCode, CGFloat(taxAmount))
        
        
        // hide menu
        menuWidthConstraint.constant = 0

        // Get data
		currencyManager.fetchData {[weak self] (data: [AnyObject]?, error: NSError?) -> Void in
			if error == nil && data != nil {
				for item in data! {
					let currency = item as! BSCurrencyModel
					if currency.code == toCurrency {
						//self!.valueLabel.text = String(self!.rawValue * currency.rate)
						break
					}
				}
			}
		}
	}

    // MARK: menu actions
        
    @IBAction func menuCurrecyAction(_ sender: Any) {
        
        print("in currency menu option")
    }
    
    @IBAction func MenuClick(_ sender: UIBarButtonItem) {
        
        // hide/show the menu
        if (menuWidthConstraint.constant <= 0) {
            let title = "Currency - " + purchaseData!.currency
            menuCurrencyButton.setTitle(title, for: UIControlState())
            menuWidthConstraint.constant = 150
        } else {
            menuWidthConstraint.constant = 0
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // if navigating to the web view - set the right URL
        if segue.identifier != nil {
            let id = segue.identifier!
            var url : String?
            if id == "webViewPrivacyPolicy" {
                url = privacyPolicyURL
            } else if id == "webViewRefundPolicy" {
                url = refundPolicyURL
            } else if id == "webViewTerms" {
                url = termsURL
            }
            if url != nil {
                let controller = segue.destination as! BSWebViewController
                controller.url = url!
            }
        }
    }

    // MARK: button actions
    
    @IBAction func clickPay(_ sender: UIButton) {
        
        if (validateForm()) {
            print("ready to submit!")
        } else {
            //return false
        }
        
    }
    
    @IBAction func clickShipping(_ sender: UIButton) {
        
        if (validateForm()) {
            print("ready to go to shipping!")
            if (self.shippingScreen == nil) {
                self.shippingScreen = storyboard!.instantiateViewController(withIdentifier: "ShippingDetailsScreen") as! BSShippingViewController
                purchaseData!.getShippingDetails()!.name = self.nameUiTextyField.text!
                self.shippingScreen.purchaseData = self.purchaseData
            }
            self.shippingScreen.payText = self.payButtonText
            self.navigationController?.pushViewController(self.shippingScreen, animated: true)
        } else {
            //return false
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

