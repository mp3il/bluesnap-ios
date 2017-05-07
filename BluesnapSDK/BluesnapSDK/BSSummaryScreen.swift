
import UIKit

class BSSummaryScreen: UIViewController {

	// MARK: - Public properties
	
    internal var paymentDetails : BSPaymentDetails!
    internal var bsToken: BSToken!
    internal var purchaseFunc: (BSPaymentDetails!)->Void = {
        paymentDetails in
        print("Payment Details were submitted")
    }

    
    // MARK: private properties
    
    fileprivate var withShipping = false
    fileprivate var shippingScreen: BSShippingViewController!
    
    // MARK: Constants
    
    fileprivate let nameInvalidMessage = "Please fill Card holder name"
    fileprivate let ccnInvalidMessage = "Please fill a valid Credirt Card number"
    fileprivate let cvvInvalidMessage = "Please fill a valid CVV number"
    fileprivate let expInvalidMessage = "Please fill a valid exiration date"
    fileprivate let doValidations = true;
    fileprivate let ccImages = [
        "americanexpress": "amex",
        //"cartebleue": "visa",
        "cirrus": "cirrus",
        "dinersclub": "dinersclub",
        "discover": "discover",
        "jcb": "jcb",
        "maestro": "maestro",
        "mastercard": "mastercard",
        "unionpay": "unionpay",
        "visa": "visa"]

	// MARK: - Data
	
    fileprivate var payButtonText : String?
	
	// MARK: - Outlets
    
    @IBOutlet weak var payButton: UIButton!
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
    @IBOutlet weak var ccIconImage: UIImageView!

    
	// MARK: - UIViewController's methods


    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController!.isNavigationBarHidden = false

        self.withShipping = paymentDetails.getShippingDetails() != nil
        updateTexts()
	}
    
    
    // MARK: private methods
    
    private func updateTexts() {
        
        let toCurrency = paymentDetails.getCurrency() ?? ""
        let subtotalAmount = paymentDetails.getAmount() ?? 0.0
        let taxAmount = (paymentDetails.getTaxAmount() ?? 0.0)
        let amount = subtotalAmount + taxAmount
        let currencyCode = (toCurrency == "USD" ? "$" : toCurrency)
        payButtonText = String(format:"Pay %@ %.2f", currencyCode, CGFloat(amount))
        if (self.withShipping) {
            payButton.setTitle("Shipping ->", for: UIControlState())
        } else {
            payButton.setTitle(payButtonText, for: UIControlState())
        }
        subtotalUILabel.text = String(format:" %@ %.2f", currencyCode, CGFloat(subtotalAmount))
        taxAmountUILabel.text = String(format:" %@ %.2f", currencyCode, CGFloat(taxAmount))
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
        let last2Digits = self.ExpYYUiTextField.text ?? ""
        return "\(first2Digits)\(last2Digits)"
    }
    
    private func getExpDateAsMMYYYY() -> String! {
        
        let mm = self.ExpMMUiTextField.text ?? ""
        let yyyy = getExpYearAsYYYY()
        return "\(mm)/\(yyyy!)"
    }

    private func submitPaymentFields() -> BSResultCcDetails? {
        
        var result : BSResultCcDetails?
        
        let ccn = self.cardUiTextField.text ?? ""
        let cvv = self.cvvUiTextField.text ?? ""
        let exp = self.getExpDateAsMMYYYY() ?? ""
        do {
            result = try BSApiManager.submitCcDetails(bsToken: self.bsToken, ccNumber: ccn, expDate: exp, cvv: cvv)
            self.paymentDetails.setCcDetails(ccDetails: result)
            // return to previous screen
            _ = navigationController?.popViewController(animated: true)
            // execute callback
            purchaseFunc(paymentDetails)
            
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
            NSLog("Unexpected error submitting Payment Fields to BS")
        }
        return result
    }
    
    private func gotoShippingScreen() {
        
        if (self.shippingScreen == nil) {
            if let storyboard = storyboard {
                self.shippingScreen = storyboard.instantiateViewController(withIdentifier: "ShippingDetailsScreen") as! BSShippingViewController
                if let shippingDetails = paymentDetails.getShippingDetails() {
                    shippingDetails.name = self.nameUiTextyField.text ?? ""
                }
                self.shippingScreen.paymentDetails = self.paymentDetails
                self.shippingScreen.submitPaymentFields = submitPaymentFields
            }
        }
        self.shippingScreen.payText = self.payButtonText
        self.navigationController?.pushViewController(self.shippingScreen, animated: true)
    }
    
    
    private func updateCcIcon(ccType : String?) {

        // change the image in ccIconImage
        var imageName : String?
        if let ccType = ccType?.lowercased() {
            imageName = ccImages[ccType]
        }
        if imageName == nil {
            imageName = "default"
            NSLog("ccTypew \(ccType) does not have an icon")
        }
        if let myBundle = Bundle(identifier: BSViewsManager.bundleIdentifier) {
            if let image = UIImage(named: "cc_\(imageName!)", in: myBundle, compatibleWith: nil) {
                self.ccIconImage.image = image
            }
        }
    }
    
    // MARK: menu actions
    
    fileprivate var popupMenuViewController : BSPopupMenuViewController?
    
    @IBAction func MenuClick(_ sender: UIBarButtonItem) {
        
        if popupMenuViewController != nil {
            //closeMenu()
            return
        }
        
        if let storyboard = storyboard, popupMenuViewController == nil {
            popupMenuViewController = storyboard.instantiateViewController(withIdentifier: "bsPopupMenu") as? BSPopupMenuViewController
            if let popupMenuViewController = popupMenuViewController {
                popupMenuViewController.paymentDetails = self.paymentDetails
                popupMenuViewController.bsToken = self.bsToken
                popupMenuViewController.closeFunc = self.closeMenu
                popupMenuViewController.view.frame = self.view.frame
                self.addChildViewController(popupMenuViewController)
                self.view.addSubview(popupMenuViewController.view)
                popupMenuViewController.didMove(toParentViewController: self)
            }
        }
   }
    
    private func closeMenu() {
        
        if let _ = popupMenuViewController {
            self.popupMenuViewController!.view.removeFromSuperview()
            self.popupMenuViewController = nil
        }
    }

    // MARK: button actions
    
    @IBAction func clickPay(_ sender: UIButton) {
        
        if (validateForm()) {
            
            if (withShipping) {
                gotoShippingScreen()
            } else {
                if let result = submitPaymentFields() {
                    // call callback
                    print("Should close window here and call the callback; result: \(result)")
                }
            }
        } else {
            //return false
        }
    }
    

    // MARK: Validation methods
    
    func validateForm() -> Bool {
        
        let ok1 = validateName(ignoreIfEmpty: false)
        let ok2 = validateCCN(ignoreIfEmpty: false)
        let ok3 = validateExpMM(ignoreIfEmpty: false)
        let ok4 = validateExpYY(ignoreIfEmpty: false)
        let ok5 = validateCvv(ignoreIfEmpty: false)
        return ok1 && ok2 && ok3 && ok4 && ok5
    }
    
    func validateCvv(ignoreIfEmpty : Bool) -> Bool {
        
        var ok : Bool = true;
        if (doValidations) {
            let newValue = cvvUiTextField.text ?? ""
            if newValue.characters.count == 0 && ignoreIfEmpty {
                // ignore
            } else if newValue.characters.count < 3 {
                ok = false
            }
        }
        if ok {
            cvvErrorUiLabel.isHidden = true
        } else {
            cvvErrorUiLabel.text = cvvInvalidMessage
            cvvErrorUiLabel.isHidden = false
        }
        return ok
    }
    
    func validateName(ignoreIfEmpty : Bool) -> Bool {
        
        var ok : Bool = true;
        let newValue = nameUiTextyField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if (doValidations) {
            nameUiTextyField.text = newValue
            if newValue.characters.count == 0 && ignoreIfEmpty {
                // ignore
            } else if !newValue.isValidName {
                ok = false
            }
        }
        if ok {
            nameErrorUiLabel.isHidden = true
            paymentDetails.name = newValue
        } else {
            nameErrorUiLabel.text = nameInvalidMessage
            nameErrorUiLabel.isHidden = false
        }
        return ok
    }
    
    func validateCCN(ignoreIfEmpty : Bool) -> Bool {
        
        var ok : Bool = true;
        let newValue = cardUiTextField.text ?? ""
        if (doValidations) {
            if newValue.characters.count == 0 && ignoreIfEmpty {
                // ignore
            } else if !newValue.isValidCCN {
                ok = false
            }
        }
        if ok {
            ccnErrorUiLabel.isHidden = true
            let cardType = newValue.getCCType()
            NSLog("cardType= \(cardType)")
            updateCcIcon(ccType: cardType)
        } else {
            ccnErrorUiLabel.text = ccnInvalidMessage
            ccnErrorUiLabel.isHidden = false
        }
        return ok
    }
    
    func validateExpMM(ignoreIfEmpty : Bool) -> Bool {
        
        var ok : Bool = true
        if (doValidations) {
            let inputMM = ExpMMUiTextField.text ?? ""
            if inputMM.characters.count == 0 && ignoreIfEmpty {
                // ignore
            } else if (inputMM.characters.count < 2) {
                ok = false
            } else if !inputMM.isValidMonth {
                ok = false
            }
        }
        if (ok) {
            expErrorUiLabel.isHidden = true
        } else {
            expErrorUiLabel.text = expInvalidMessage
            expErrorUiLabel.isHidden = false
        }
        return ok
    }
    
    func validateExpYY(ignoreIfEmpty : Bool) -> Bool {

        var ok : Bool = true
        if (doValidations) {
            let inputYY = ExpYYUiTextField.text ?? ""
            if inputYY.characters.count == 0 && ignoreIfEmpty {
                // ignore
            } else if (inputYY.characters.count < 2) {
                ok = false
            } else {
                let currentYearYY = self.getCurrentYear() % 100
                ok = currentYearYY <= Int(inputYY)!
            }
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
        _ = validateName(ignoreIfEmpty: true)
    }
    
    @IBAction func cvvEditingDidEnd(_ sender: UITextField) {
        _ = validateCvv(ignoreIfEmpty: true)
    }
    
    @IBAction func expYYEditingDidEnd(_ sender: UITextField) {
        _ = validateExpYY(ignoreIfEmpty: true)
    }
    
    @IBAction func expMMEditingDidEnd(_ sender: UITextField) {
        _ = validateExpMM(ignoreIfEmpty: true)
    }

    @IBAction func cardEditingDidEnd(_ sender: UITextField) {
        _ = validateCCN(ignoreIfEmpty: true)
    }

}

