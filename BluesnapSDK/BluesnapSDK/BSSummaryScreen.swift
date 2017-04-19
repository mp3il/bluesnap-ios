
import UIKit

class BSSummaryScreen: UIViewController {

	// MARK: - Public properties
	
    internal var purchaseData : PurchaseData?
    internal var bsToken: BSToken?
    
    // MARK: private properties
    
    fileprivate var withShipping = false
    fileprivate var shippingScreen: BSShippingViewController!
    
    // MARK: Constants
    
    fileprivate let privacyPolicyURL = "http://home.bluesnap.com/ecommerce/legal/privacy-policy/"
    fileprivate let refundPolicyURL = "http://home.bluesnap.com/ecommerce/legal/refund-policy/"
    fileprivate let termsURL = "http://home.bluesnap.com/ecommerce/legal/terms-and-conditions/"
    fileprivate let nameInvalidMessage = "Please fill Card holder name"
    fileprivate let ccnInvalidMessage = "Please fill a valid Credirt Card number"
    fileprivate let cvvInvalidMessage = "Please fill a valid CVV number"
    fileprivate let expInvalidMessage = "Please fill a valid exiration date"
    
	
	// MARK: - Data
	
    fileprivate var payButtonText : String?
	
	// MARK: - Outlets
    
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var shippingButton: UIButton!
    @IBOutlet weak var nameUiTextyField: UITextField!
    @IBOutlet weak var cardUiTextField: UITextField!
    @IBOutlet weak var ExpYYUiTextField: UITextField!
    @IBOutlet weak var ExpMMUiTextField: UITextField!
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

        self.withShipping = purchaseData!.getShippingDetails() != nil
        payButton.isHidden = self.withShipping
        shippingButton.isHidden = !self.withShipping
        updateTexts()
        
        // hide menu
        menuWidthConstraint.constant = 0
	}
    
    
    // MARK: private methods
    
    private func updateTexts() {
        
        let toCurrency = purchaseData!.getCurrency()!
        let subtotalAmount = purchaseData!.getAmount()!
        let taxAmount = purchaseData!.getTaxAmount()! + purchaseData!.getTaxPercent()!*subtotalAmount/100.0
        let amount = subtotalAmount + taxAmount
        let currencyCode = (toCurrency == "USD" ? "$" : toCurrency)
        payButtonText = String(format:"Pay %@ %.2f", currencyCode, CGFloat(amount))
        payButton.setTitle(payButtonText, for: UIControlState())
        subtotalUILabel.text = String(format:" %@ %.2f", currencyCode, CGFloat(subtotalAmount))
        taxAmountUILabel.text = String(format:" %@ %.2f", currencyCode, CGFloat(taxAmount))
    }
    
    private func updateViewWithNewCurrency(oldCurrency : BSCurrency?, newCurrency : BSCurrency?, bsCurrencies : BSCurrencies?) {
        
        purchaseData!.changeCurrency(oldCurrency: oldCurrency, newCurrency: newCurrency!, bsCurrencies: bsCurrencies!)
        updateTexts()
    }
    
    private func getCurrentYear() -> Int! {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        return year
    }
    
    private func getExpYearAsYYYY() -> String! {
        
        let yearStr = String(getCurrentYear())
        let p = yearStr.index(yearStr.startIndex, offsetBy: 2)
        let first2Digits = yearStr.substring(with: yearStr.startIndex..<p)
        let last2Digits = self.ExpYYUiTextField.text!
        return "\(first2Digits)\(last2Digits)"
    }
    
    private func getExpDateAsMMYYYY() -> String! {
        
        let mm = self.ExpMMUiTextField.text!
        let yyyy = getExpYearAsYYYY()
        return "\(mm)/\(yyyy)"
    }

    
    // MARK: menu actions
        
    @IBAction func menuCurrecyAction(_ sender: Any) {
        
        //print("in currency menu option")
        BlueSnapSDK.showCurrencyList(
            inNavigationController: self.navigationController,
            animated: true,
            bsToken: bsToken,
            selectedCurrencyCode: purchaseData!.getCurrency(),
            updateFunc: updateViewWithNewCurrency)

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
            
            let ccn = self.cardUiTextField.text!
            let cvv = self.cvvUiTextField.text!
            let exp = self.getExpDateAsMMYYYY()!
            do {
                let result = try BSApiManager.submitCcDetails(bsToken: self.bsToken, ccNumber: ccn, expDate: exp, cvv: cvv)
                self.purchaseData?.setCcDetails(ccDetails: result)
                
            } catch let error as BSCcDetailErrors {
                if (error == BSCcDetailErrors.invalidCcNumber) {
                    ccnErrorUiLabel.text = ccnInvalidMessage
                    ccnErrorUiLabel.isHidden = false
                } else if (error == BSCcDetailErrors.invalidExpDate) {
                    expErrorUiLabel.text = expInvalidMessage
                    expErrorUiLabel.isHidden = false
                } else if (error == BSCcDetailErrors.invalidCvv) {
                    cvvErrorUiLabel.text = cvvInvalidMessage
                    cvvErrorUiLabel.isHidden = false
                }
            } catch {
                print("Unexpected error")
            }

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
        let ok3 = validateExpMM()
        let ok4 = validateExpYY()
        let ok5 = validateCvv()
        return ok1 && ok2 && ok3 && ok4 && ok5
    }
    
    func validateCvv() -> Bool {
        
        if (cvvUiTextField.text!.characters.count < 3) {
            cvvErrorUiLabel.text = cvvInvalidMessage
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
            nameErrorUiLabel.text = nameInvalidMessage
            nameErrorUiLabel.isHidden = false
            return false
        }
        return true
    }
    
    func validateCCN() -> Bool {
        
        ccnErrorUiLabel.isHidden = true
        // TODO: need to add lohn check as well
        if (cardUiTextField.text!.characters.count < 7) {
            ccnErrorUiLabel.text = ccnInvalidMessage
            ccnErrorUiLabel.isHidden = false
            return false
        }
        return true
    }
    
    func validateExpMM() -> Bool {
        var ok = true
        let inputMM = ExpMMUiTextField.text!
        if (inputMM.characters.count < 2) {
            ok = false
        } else if !inputMM.isValidMonth {
            ok = false
        }
        if (ok) {
            expErrorUiLabel.isHidden = true
        } else {
            expErrorUiLabel.text = expInvalidMessage
            expErrorUiLabel.isHidden = false
        }
        return ok
    }
    
    func validateExpYY() -> Bool {
        var ok = true
        let inputYY = ExpYYUiTextField.text!
        if (inputYY.characters.count < 2) {
            ok = false
        } else {
            let currentYearYY = self.getCurrentYear() % 100
            ok = currentYearYY <= Int(inputYY)!
        }
        if (ok) {
            expErrorUiLabel.isHidden = true
        } else {
            expErrorUiLabel.text = expInvalidMessage
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
        input = input.removeNoneDigits.cutToMaxLength(maxLength: 2)
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
    
    @IBAction func expYYEditingDidEnd(_ sender: UITextField) {
        _ = validateExpYY()
    }
    
    @IBAction func expMMEditingDidEnd(_ sender: UITextField) {
        _ = validateExpMM()
    }

    @IBAction func cardEditingDidEnd(_ sender: UITextField) {
        _ = validateCCN()
    }

}

