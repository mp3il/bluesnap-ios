
import UIKit

class BSSummaryScreen: UIViewController, UITextFieldDelegate {

	// MARK: - Public properties
	
    internal var paymentDetails : BSPaymentDetails!
    internal var fullBilling = false
    internal var bsToken: BSToken!
    internal var purchaseFunc: (BSPaymentDetails!)->Void = {
        paymentDetails in
        print("purchaseFunc should be overridden")
    }
    internal var countryManager = BSCountryManager()
    
    // MARK: private properties
    
    fileprivate var withShipping = false
    fileprivate var shippingScreen: BSShippingViewController!
    fileprivate var previousCcn : String?
    fileprivate var cardType : String?
    
    // MARK: Constants
    
    fileprivate let nameInvalidMessage = "Please fill Card holder name"
    fileprivate let ccnInvalidMessage = "Please fill a valid Credit Card number"
    fileprivate let cvvInvalidMessage = "Please fill a valid CVV number"
    fileprivate let expInvalidMessage = "Please fill a valid exiration date"
    fileprivate let doValidations = true;
    fileprivate let ccImages = [
        "amex": "amex",
        //"cartebleue": "visa",
        "cirrus": "cirrus",
        "diners": "dinersclub",
        "discover": "discover",
        "jcb": "jcb",
        "maestr_uk": "maestro",
        "mastercard": "mastercard",
        "china_union_pay": "unionpay",
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
    
    @IBOutlet weak var subtotalUILabel: UILabel!
    @IBOutlet weak var taxAmountUILabel: UILabel!
    @IBOutlet weak var taxDetailsView: UIView!

    @IBOutlet weak var ccIconImage: UIImageView!

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var streetField: UITextField!
    @IBOutlet weak var zipLabel: UILabel!
    @IBOutlet weak var zipField: UITextField!
    @IBOutlet weak var countryFlagButton: UIButton!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var stateField: UITextField!
    
    @IBOutlet weak var nameErrorUiLabel: UILabel!
    @IBOutlet weak var ccnErrorUiLabel: UILabel!
    @IBOutlet weak var expErrorUiLabel: UILabel!
    @IBOutlet weak var cvvErrorUiLabel: UILabel!
    @IBOutlet weak var emailError: UILabel!
    @IBOutlet weak var streetError: UILabel!
    @IBOutlet weak var zipError: UILabel!
    @IBOutlet weak var cityError: UILabel!
    @IBOutlet weak var stateError: UILabel!
    
    @IBOutlet weak var shippingSameAsBillingLabel: UILabel!
    @IBOutlet weak var shippingSameAsBillingSwitch: UISwitch!
    
    fileprivate var firstTime : Bool! = true
    
    
    // MARK: for scrolling to prevent keyboard hiding
    
    let scrollOffset : Int = -64 // this is the Y of scrollView

    var movedUp = false
    var fieldBottom : Int?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fieldsView: UIView!

    override func viewDidLayoutSubviews()
    {
        let scrollViewBounds = scrollView.bounds
        //let containerViewBounds = fieldsView.bounds
        
        var scrollViewInsets = UIEdgeInsets.zero
        scrollViewInsets.top = scrollViewBounds.size.height/2.0;
        scrollViewInsets.top -= fieldsView.bounds.size.height/2.0;
        
        scrollViewInsets.bottom = scrollViewBounds.size.height/2.0
        scrollViewInsets.bottom -= fieldsView.bounds.size.height/2.0;
        scrollViewInsets.bottom += 1
        
        scrollView.contentInset = scrollViewInsets
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        fieldBottom = Int(textField.frame.origin.y + textField.frame.height)
    }
    
    // Do we need this?
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        return false
    }
    
    private func scrollForKeyboard(direction: Int) {
        
        self.movedUp = (direction > 0)
        let y = 200*direction
        let point : CGPoint = CGPoint(x: 0, y: y)
        self.scrollView.setContentOffset(point, animated: false)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        var moveUp = false
        if let fieldBottom = fieldBottom {
            let userInfo = notification.userInfo as! [String: NSObject] as NSDictionary
            let keyboardFrame = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! CGRect
            let keyboardHeight = Int(keyboardFrame.height)
            let viewHeight : Int = Int(self.view.frame.height)
            let offset = fieldBottom + keyboardHeight - scrollOffset
            //print("fieldBottom:\(fieldBottom), keyboardHeight:\(keyboardHeight), offset:\(offset), viewHeight:\(viewHeight)")
            if (offset > viewHeight) {
                moveUp = true
            }
        }
        
        if !self.movedUp && moveUp {
            scrollForKeyboard(direction: 1)
        } else if self.movedUp && !moveUp {
            scrollForKeyboard(direction: 0)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if self.movedUp {
            scrollForKeyboard(direction: 0)
        }
    }
    
    
	// MARK: - UIViewController's methods

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		self.navigationController!.isNavigationBarHidden = false

        self.withShipping = paymentDetails.getShippingDetails() != nil
        
        let hideShippingSameAsBilling : Bool = !self.withShipping || !self.fullBilling
        shippingSameAsBillingLabel.isHidden = hideShippingSameAsBilling
        shippingSameAsBillingSwitch.isHidden = hideShippingSameAsBilling
        // set the "shipping same as billing" to be true if no shipping name is supplied
        shippingSameAsBillingSwitch.isOn = self.paymentDetails.getShippingDetails()?.name ?? "" == ""
        
        updateTexts()
        
        taxDetailsView.isHidden = self.paymentDetails.getTaxAmount() == 0
        
        if self.firstTime == true {
            self.firstTime = false
            if let billingDetails = paymentDetails.getBillingDetails() {
                self.nameUiTextyField.text = billingDetails.name
                if fullBilling {
                    self.emailField.text = billingDetails.email
                    self.zipField.text = billingDetails.zip
                    self.streetField.text = billingDetails.address
                    self.cityField.text = billingDetails.city
                }
            }
            // this is for debug, should bve removed
            self.cardUiTextField.text = "4111 1111 1111 1111"
            self.ExpMMUiTextField.text = "11"
            self.ExpYYUiTextField.text = "20"
            self.cvvUiTextField.text = "444"
        }

        hideShowFields()
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }

    // MARK: private methods
    
    private func hideShowFields() {
        
        let hideFields = !self.fullBilling
        emailLabel.isHidden = hideFields
        emailField.isHidden = hideFields
        streetLabel.isHidden = hideFields
        streetField.isHidden = hideFields
        updateZipByCountry(countryCode: self.paymentDetails.getBillingDetails().country ?? "")
        //countryFlagButton.isHidden = hideFields
        cityLabel.isHidden = hideFields
        cityField.isHidden = hideFields
        updateState()
        
        // hide all errors
        nameErrorUiLabel.isHidden = true
        ccnErrorUiLabel.isHidden = true
        expErrorUiLabel.isHidden = true
        cvvErrorUiLabel.isHidden = true
        emailError.isHidden = true
        streetError.isHidden = true
        zipError.isHidden = true
        cityError.isHidden = true
        stateError.isHidden = true
        
        //let cardType = cardUiTextField.text?.getCCType() ?? ""
        //updateCcIcon(ccType: cardType)
    }
    
    private func updateState() {
        
        if (fullBilling) {
            BSValidator.updateState(addressDetails: paymentDetails.getBillingDetails(), countryManager: countryManager, stateUILabel: stateLabel, stateUITextField: stateField, stateErrorUILabel: stateError)
        } else {
            stateLabel.isHidden = true
            stateField.isHidden = true
        }
    }
    
    
    private func updateTexts() {
        
        let toCurrency = paymentDetails.getCurrency() ?? ""
        let subtotalAmount = paymentDetails.getAmount() ?? 0.0
        let taxAmount = (paymentDetails.getTaxAmount() ?? 0.0)
        let amount = subtotalAmount + taxAmount
        let currencyCode = (toCurrency == "USD" ? "$" : toCurrency)
        payButtonText = String(format:"Pay %@ %.2f", currencyCode, CGFloat(amount))
        updatePayButtonText()
        subtotalUILabel.text = String(format:" %@ %.2f", currencyCode, CGFloat(subtotalAmount))
        taxAmountUILabel.text = String(format:" %@ %.2f", currencyCode, CGFloat(taxAmount))
    }
    
    private func updatePayButtonText() {
        
        if (self.withShipping && !self.shippingSameAsBillingSwitch.isOn) {
            payButton.setTitle("Shipping >", for: UIControlState())
        } else {
            payButton.setTitle(payButtonText, for: UIControlState())
        }
   }
    
    private func getExpYearAsYYYY() -> String! {
        
        let yearStr = String(BSValidator.getCurrentYear())
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
            _ = navigationController?.popViewController(animated: false)
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
            } else if (error == BSCcDetailErrors.expiredToken) {
                // should be popup here
                showAlert("Your session has expired, please go back and try again")
            } else {
                // should be popup here
                showAlert("An error occurred, please try again")
            }
        } catch {
            NSLog("Unexpected error submitting Payment Fields to BS")
            showAlert("An error occurred, please try again")
        }
        return result
    }
    
    private func showAlert(_ message : String) {
        let alert = BSViewsManager.createErrorAlert(title: "Oops", message: message)
        present(alert, animated: true, completion: nil)
    }
    
    private func gotoShippingScreen() {
        
        if (self.shippingScreen == nil) {
            if let storyboard = storyboard {
                self.shippingScreen = storyboard.instantiateViewController(withIdentifier: "ShippingDetailsScreen") as! BSShippingViewController
                self.shippingScreen.paymentDetails = self.paymentDetails
                self.shippingScreen.submitPaymentFields = submitPaymentFields
                self.shippingScreen.countryManager = self.countryManager
            }
        }
        self.shippingScreen.payText = self.payButtonText
        self.navigationController?.pushViewController(self.shippingScreen, animated: true)
    }
    
    
    private func updateCcIcon(ccType : String?) {

        self.cardType = ccType

        // change the image in ccIconImage
        var imageName : String?
        if let ccType = ccType?.lowercased() {
            imageName = ccImages[ccType]
        }
        if imageName == nil {
            imageName = "default"
            NSLog("ccTypew \(ccType) does not have an icon")
        }
        if let image = BSViewsManager.getImage(imageName: "cc_\(imageName!)") {
            self.ccIconImage.image = image
        }
    }
    
    private func updateWithNewCountry(countryCode : String, countryName : String) {
        
        paymentDetails.getBillingDetails().country = countryCode
        updateZipByCountry(countryCode: countryCode)
        updateState()

        // load the flag image
        if let image = BSViewsManager.getImage(imageName: countryCode.uppercased()) {
            self.countryFlagButton.imageView?.image = image
        }
    }
    
    private func updateZipByCountry(countryCode : String) {
        
        let hideZip = self.countryManager.countryHasNoZip(countryCode: countryCode)
        if countryCode.lowercased() == "us" {
            self.zipLabel.text = "Billing Zip"
            self.zipField.keyboardType = .numberPad
        } else {
            self.zipLabel.text = "Postal Code"
            self.zipField.keyboardType = .numbersAndPunctuation
        }
        self.zipLabel.isHidden = hideZip
        self.zipField.isHidden = hideZip
        self.zipError.isHidden = true
    }
    
    private func updateWithNewState(stateCode : String, stateName : String) {
        
        paymentDetails.getBillingDetails().state = stateCode
        self.stateField.text = stateName
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
    
    @IBAction func shippingSameAsBillingValueChanged(_ sender: Any) {
        
        updatePayButtonText()
    }
    
    @IBAction func clickPay(_ sender: UIButton) {
        
        if (validateForm()) {
            
            if (withShipping && (!shippingSameAsBillingSwitch.isOn || shippingSameAsBillingSwitch.isHidden)) {
                gotoShippingScreen()
            } else {
                let _ = submitPaymentFields()
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
        var okExp : Bool = true
        if ok3 && ok4 {
            okExp = BSValidator.validateExp(monthTextField: self.ExpMMUiTextField, yearTextField: self.ExpYYUiTextField, errorLabel: self.expErrorUiLabel, errorMessage: expInvalidMessage)
        }
        var result = ok1 && ok2 && ok3 && ok4 && ok5 && okExp
        
        if fullBilling {
            let ok1 = validateEmail(ignoreIfEmpty: false)
            let ok2 = validateCity(ignoreIfEmpty: false)
            let ok3 = validateAddress(ignoreIfEmpty: false)
            let ok4 = validateCity(ignoreIfEmpty: false)
            let ok5 = validateCountryAndZip(ignoreIfEmpty: false)
            let ok6 = validateState(ignoreIfEmpty: false)
            result = result && ok1 && ok2 && ok3 && ok4 && ok5 && ok6
        } else if !zipField.isHidden {
            let ok = validateCountryAndZip(ignoreIfEmpty: false)
            result = result && ok
        }
        
        if result && shippingSameAsBillingSwitch.isOn && !shippingSameAsBillingSwitch.isHidden {
            // copy billing details to shipping
            if let shippingDetails = self.paymentDetails.getShippingDetails(), let billingDetails = self.paymentDetails.getBillingDetails() {
                shippingDetails.address = billingDetails.address
                shippingDetails.city = billingDetails.city
                shippingDetails.country = billingDetails.country
                shippingDetails.email = billingDetails.email
                shippingDetails.name = billingDetails.name
                shippingDetails.state = billingDetails.state
                shippingDetails.zip = billingDetails.zip
            }
        }

        return result
    }
    
    func validateCvv(ignoreIfEmpty : Bool) -> Bool {
        
        let result = BSValidator.validateCvv(ignoreIfEmpty: ignoreIfEmpty, textField: cvvUiTextField, errorLabel: cvvErrorUiLabel)
        return result
    }
    
    func validateName(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateName(ignoreIfEmpty: ignoreIfEmpty, textField: nameUiTextyField, errorLabel: nameErrorUiLabel, errorMessage: nameInvalidMessage, addressDetails: paymentDetails.getBillingDetails())
        return result
    }
    
    func validateCCN(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateCCN(ignoreIfEmpty: ignoreIfEmpty, textField: cardUiTextField, errorLabel: ccnErrorUiLabel, errorMessage: ccnInvalidMessage)
        //if result == true {
        //    let cardType = cardUiTextField.text?.getCCType() ?? ""
        //    updateCcIcon(ccType: cardType)
        //}
        return result
    }
    
    func validateExpMM(ignoreIfEmpty : Bool) -> Bool {
        
        let result = BSValidator.validateExpMM(ignoreIfEmpty: ignoreIfEmpty, textField: ExpMMUiTextField, errorLabel: expErrorUiLabel, errorMessage: expInvalidMessage)
        return result
    }
    
    func validateExpYY(ignoreIfEmpty : Bool) -> Bool {

        let result = BSValidator.validateExpYY(ignoreIfEmpty: ignoreIfEmpty, textField: ExpYYUiTextField, errorLabel: expErrorUiLabel, errorMessage: expInvalidMessage)
        return result
    }
    
    func validateEmail(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateEmail(ignoreIfEmpty: ignoreIfEmpty, textField: emailField, errorLabel: emailError, addressDetails: paymentDetails.getBillingDetails())
        return result
    }
    
    func validateAddress(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateAddress(ignoreIfEmpty: ignoreIfEmpty, textField: streetField, errorLabel: streetError, addressDetails: paymentDetails.getBillingDetails())
        return result
    }
    
    func validateCity(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateCity(ignoreIfEmpty: ignoreIfEmpty, textField: cityField, errorLabel: cityError, addressDetails: paymentDetails.getBillingDetails())
        return result
    }
    
    func validateCountryAndZip(ignoreIfEmpty : Bool) -> Bool {
        
        if (zipField.isHidden) {
            paymentDetails.getBillingDetails().zip = ""
            zipField.text = ""
            return true
        }

        var result : Bool = true
        if fullBilling {
            result = BSValidator.validateCountry(ignoreIfEmpty: ignoreIfEmpty, errorLabel: zipError, addressDetails: paymentDetails.getBillingDetails())
        }
        if result == true {
            // make zip optional for cards other than visa/discover
            var ignoreEmptyZip = ignoreIfEmpty
            let ccType = self.cardType?.lowercased() ?? ""
            if !ignoreIfEmpty && !fullBilling && ccType != "visa" && ccType != "discover" {
                ignoreEmptyZip = true
            }
            result = BSValidator.validateZip(ignoreIfEmpty: ignoreEmptyZip, textField: zipField, errorLabel: zipError, addressDetails: paymentDetails.getBillingDetails())
        }
        return result
    }
    
    func validateState(ignoreIfEmpty : Bool) -> Bool {

        let result : Bool = BSValidator.validateState(ignoreIfEmpty: ignoreIfEmpty, textField: stateField, errorLabel: stateError, addressDetails: paymentDetails.getBillingDetails())
        return result
    }
    
    // MARK: real-time formatting and Validations on text fields
    
    @IBAction func nameEditingChanged(_ sender: UITextField) {
        
        BSValidator.nameEditingChanged(sender)
    }
    
    @IBAction func ccnEditingChanged(_ sender: UITextField) {
        
        BSValidator.ccnEditingChanged(sender)
    }
    
    @IBAction func expEditingChanged(_ sender: UITextField) {
        
        BSValidator.expEditingChanged(sender)
    }
    
    @IBAction func cvvEditingChanged(_ sender: UITextField) {
        
        BSValidator.cvvEditingChanged(sender)
    }
    
    @IBAction func emailEditingChanged(_ sender: UITextField) {
        BSValidator.emailEditingChanged(sender)
    }
    
    @IBAction func addressEditingChanged(_ sender: UITextField) {
        BSValidator.addressEditingChanged(sender)
    }
    
    @IBAction func cityEditingChanged(_ sender: UITextField) {
        BSValidator.cityEditingChanged(sender)
    }
    
    @IBAction func zipEditingChanged(_ sender: UITextField) {
        BSValidator.zipEditingChanged(sender)
    }
    
    @IBAction func stateEditingChanged(_ sender: UITextField) {
        sender.text = "" // prevent typing - open pop-up insdtead
        self.statetouchDown(sender)
    }
    
    
    // open the country screen
    @IBAction func changeCountry(_ sender: Any) {
        
        let selectedCountryCode = paymentDetails.getBillingDetails().country ?? ""
        BSViewsManager.showCountryList(
            inNavigationController: self.navigationController,
            animated: true,
            countryManager: countryManager,
            selectedCountryCode: selectedCountryCode,
            updateFunc: updateWithNewCountry)
    }
    
    // enter state field - open the state screen
    @IBAction func statetouchDown(_ sender: Any) {
        
        self.stateField.resignFirstResponder()
        
        BSViewsManager.showStateList(
            inNavigationController: self.navigationController,
            animated: true,
            countryManager: countryManager,
            addressDetails: paymentDetails.getBillingDetails(),
            updateFunc: updateWithNewState)
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
        if validateCCN(ignoreIfEmpty: true) {
            if let ccn = self.cardUiTextField.text {
                if previousCcn != ccn {
                    previousCcn = ccn
                    // get issuing country and card type from server
                    do {
                        let result = try BSApiManager.submitCcn(bsToken: bsToken, ccNumber: ccn)
                        if let issuingCountry = result?.ccIssuingCountry {
                            self.updateWithNewCountry(countryCode: issuingCountry, countryName: "")
                        }
                        if let cardType = result?.ccType {
                            updateCcIcon(ccType: cardType)
                        }
                    } catch let error as BSCcDetailErrors {
                        if (error == BSCcDetailErrors.invalidCcNumber) {
                            ccnErrorUiLabel.text = ccnInvalidMessage
                            ccnErrorUiLabel.isHidden = false
                        } else {
                            showAlert("An error occurred")
                        }
                    } catch {
                        NSLog("Unexpected error submitting CCN to BS")
                        showAlert("An error occurred")
                    }
                }
            }
        }
    }

    @IBAction func emailEditingDidEnd(_ sender: UITextField) {
        _ = validateEmail(ignoreIfEmpty: true)
    }
    
    @IBAction func addressEditingDidEnd(_ sender: UITextField) {
        _ = validateAddress(ignoreIfEmpty: true)
    }
    
    @IBAction func cityEditingDidEnd(_ sender: UITextField) {
        _ = validateCity(ignoreIfEmpty: true)
    }
    
    @IBAction func zipEditingDidEnd(_ sender: UITextField) {
        _ = validateCountryAndZip(ignoreIfEmpty: true)
    }

}

