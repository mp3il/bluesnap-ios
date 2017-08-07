//
//  ShippingViewController.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 03/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

class BSShippingViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: internal properties
    internal var activityIndicator : UIActivityIndicatorView?

    // MARK: private properties
    fileprivate var paymentRequest : BSCcPaymentRequest!
    fileprivate var payText : String!
    fileprivate var subTotalText : String?
    fileprivate var taxText : String?
    fileprivate var submitPaymentFields : () -> Void = { print("This will be overridden by payment screen") }
    fileprivate var countryManager : BSCountryManager!
    fileprivate var zipTopConstraintOriginalConstant : CGFloat?
    fileprivate var firstTime : Bool = true

    // MARK: outlets
        
    @IBOutlet weak var payUIButton: UIButton!
    @IBOutlet weak var nameInputLine: BSInputLine!
    @IBOutlet weak var streetInputLine: BSInputLine!
    @IBOutlet weak var zipInputLine: BSInputLine!
    @IBOutlet weak var cityInputLine: BSInputLine!
    @IBOutlet weak var stateInputLine: BSInputLine!
    @IBOutlet weak var phoneInputLine: BSInputLine!
    @IBOutlet weak var zipTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var subtotalUILabel: UILabel!
    @IBOutlet weak var taxAmountUILabel: UILabel!
    @IBOutlet weak var taxDetailsView: UIView!

    // MARK: init
    
    func initScreen(paymentRequest : BSCcPaymentRequest!, payText : String!, subTotalText : String?, taxText : String?, submitPaymentFields : @escaping () -> Void, countryManager : BSCountryManager!, firstTime: Bool) {
        
        self.paymentRequest = paymentRequest
        self.payText = payText
        self.subTotalText = subTotalText
        self.taxText = taxText
        self.submitPaymentFields = submitPaymentFields
        self.countryManager = countryManager
        self.firstTime = firstTime
    }
    
    // MARK: Keyboard functions
    
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
    
    @IBAction func editingDidBegin(_ sender: BSBaseTextInput) {
        
        fieldBottom = Int(sender.frame.origin.y + sender.frame.height)
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
    
    func registerTapToHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        
        self.nameInputLine.dismissKeyboard()
        self.zipInputLine.dismissKeyboard()
        self.streetInputLine.dismissKeyboard()
        self.cityInputLine.dismissKeyboard()
    }

    // MARK: - UIViewController's methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTapToHideKeyboard()
        activityIndicator = BSViewsManager.createActivityIndicator(view: self.view)
        if let zipTopConstraint = self.zipTopConstraint {
            zipTopConstraintOriginalConstant = zipTopConstraint.constant
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if let shippingDetails = self.paymentRequest.getShippingDetails() {
            nameInputLine.setValue(shippingDetails.name)
            phoneInputLine.setValue(shippingDetails.phone)
            streetInputLine.setValue(shippingDetails.address)
            cityInputLine.setValue(shippingDetails.city)
            zipInputLine.setValue(shippingDetails.zip)
            if (shippingDetails.country == "") {
                shippingDetails.country = Locale.current.regionCode ?? ""
            }
            let countryCode = paymentRequest.getShippingDetails()?.country ?? ""
            updateZipByCountry(countryCode: countryCode)
            updateFlagImage(countryCode: countryCode)
            updateState()
            payUIButton.setTitle(payText, for: UIControlState())
            if subTotalText == nil {
                self.taxDetailsView.isHidden = true
            } else {
                self.taxDetailsView.isHidden = false
                self.taxAmountUILabel.text = self.taxText
                self.subtotalUILabel.text = self.subTotalText
            }
        }
        if firstTime {
            firstTime = false
            nameInputLine.hideError()
            phoneInputLine.hideError()
            streetInputLine.hideError()
            zipInputLine.hideError()
            cityInputLine.hideError()
            stateInputLine.hideError()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        //adjustToPageRotate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
    }
    
    // MARK: Payment click
    
    @IBAction func SubmitClick(_ sender: Any) {        
        if (validateForm()) {
            
            BSViewsManager.startActivityIndicator(activityIndicator: self.activityIndicator, blockEvents: true)
            submitPaymentFields()
            
        } else {
            //return false
        }
    }
    
    
    // MARK: Validation methods
    
    func validateForm() -> Bool {
        
        let ok1 = validateName(ignoreIfEmpty: false)
        let ok2 = validateStreet(ignoreIfEmpty: false)
        let ok3 = validateCity(ignoreIfEmpty: false)
        let ok4 = validateZip(ignoreIfEmpty: false)
        let ok5 = validateState(ignoreIfEmpty: false)
        let ok6 = validatePhone(ignoreIfEmpty: true)
        return ok1 && ok2 && ok3 && ok4 && ok5 && ok6
    }
    
    func validateName(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateName(ignoreIfEmpty: ignoreIfEmpty, input: nameInputLine, addressDetails: paymentRequest.getShippingDetails())
        return result
    }
    
    func validateStreet(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateStreet(ignoreIfEmpty: ignoreIfEmpty, input: streetInputLine, addressDetails: paymentRequest.getShippingDetails())
        return result
    }
    
    func validateCity(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateCity(ignoreIfEmpty: ignoreIfEmpty, input: cityInputLine, addressDetails: paymentRequest.getShippingDetails())
        return result
    }
    
    func validateZip(ignoreIfEmpty : Bool) -> Bool {
        
        if (zipInputLine.isHidden) {
            if let shippingDetails = paymentRequest.getShippingDetails() {
                shippingDetails.zip = ""
            }
            zipInputLine.setValue("")
            return true
        }
        
        let result = BSValidator.validateZip(ignoreIfEmpty: ignoreIfEmpty, input: zipInputLine, addressDetails: paymentRequest.getShippingDetails())
        return result
    }
    
    func validateState(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validateState(ignoreIfEmpty: ignoreIfEmpty, input: stateInputLine, addressDetails: paymentRequest.getShippingDetails())
        return result
    }
    
    func validatePhone(ignoreIfEmpty : Bool) -> Bool {
        
        let result : Bool = BSValidator.validatePhone(ignoreIfEmpty: ignoreIfEmpty, input: phoneInputLine, addressDetails: paymentRequest.getShippingDetails())
        return result
    }

    
    // MARK: real-time formatting and Validations on text fields
    
    @IBAction func nameEditingChanged(_ sender: BSInputLine) {
        BSValidator.nameEditingChanged(sender)
    }
    
    @IBAction func nameEditingDidEnd(_ sender: BSInputLine) {
        _ = validateName(ignoreIfEmpty: true)
    }
    
    @IBAction func streetEditingChanged(_ sender: BSInputLine) {
        BSValidator.addressEditingChanged(sender)
    }
    
    @IBAction func streetEditingDidEnd(_ sender: BSInputLine) {
        _ = validateStreet(ignoreIfEmpty: true)
    }
    
    @IBAction func streetEditingDidBegin(_ sender: BSInputLine) {
        
        editingDidBegin(sender)
        if streetInputLine.getValue() == "" {
            streetInputLine.fieldKeyboardType = .numbersAndPunctuation
        } else {
            streetInputLine.fieldKeyboardType = .default
        }
    }
    
    @IBAction func cityEditingChanged(_ sender: BSInputLine) {
        BSValidator.cityEditingChanged(sender)
    }
    
    @IBAction func cityEditingDidEnd(_ sender: BSInputLine) {
        _ = validateCity(ignoreIfEmpty: true)
    }
    
    @IBAction func zipEditingChanged(_ sender: BSInputLine) {
        BSValidator.zipEditingChanged(sender)
    }
    
    @IBAction func zipEditingDidEnd(_ sender: BSInputLine) {
        _ = validateZip(ignoreIfEmpty: true)
    }
    
    // enter state field - open the state screen
    @IBAction func stateTouchUpInside(_ sender: BSInputLine) {
        
        BSViewsManager.showStateList(
            inNavigationController: self.navigationController,
            animated: true,
            countryManager: countryManager,
            addressDetails: paymentRequest.getShippingDetails()!,
            updateFunc: updateWithNewState)
    }

    @IBAction func flagTouchUpInside(_ sender: BSInputLine) {
        
        let selectedCountryCode = paymentRequest.getShippingDetails()?.country ?? ""
        BSViewsManager.showCountryList(
            inNavigationController: self.navigationController,
            animated: true,
            countryManager: countryManager,
            selectedCountryCode: selectedCountryCode,
            updateFunc: updateWithNewCountry)
    }
    
    @IBAction func phoneEditingChanged(_ sender: BSInputLine) {
        BSValidator.phoneEditingChanged(sender)
    }
    
    @IBAction func phoneEditingDidEnd(_ sender: BSInputLine) {
        _ = validatePhone(ignoreIfEmpty: true)
    }
    
    // MARK: private functions
    
    /*private func adjustToPageRotate() {
        
        DispatchQueue.main.async{
            
            self.nameInputLine.deviceDidRotate()
            self.streetInputLine.deviceDidRotate()
            self.zipInputLine.deviceDidRotate()
            self.cityInputLine.deviceDidRotate()
            self.stateInputLine.deviceDidRotate()
            
            self.viewDidLayoutSubviews()
        }
    }*/
    
    
    private func updateWithNewCountry(countryCode : String, countryName : String) {
        
        if let shippingDetails = paymentRequest.getShippingDetails() {
            shippingDetails.country = countryCode
            updateZipByCountry(countryCode: countryCode)
        }
        updateFlagImage(countryCode: countryCode)
    }
    
    private func updateFlagImage(countryCode : String) {
        
        // load the flag image
        if let image = BSViewsManager.getImage(imageName: countryCode.uppercased()) {
            nameInputLine.image = image
        }
    }
    
    private func updateZipByCountry(countryCode: String) {
        
        let hideZip = self.countryManager.countryHasNoZip(countryCode: countryCode)
        
        self.zipInputLine.labelText = BSValidator.getZipLabelText(countryCode: countryCode, forBilling: false)
        self.zipInputLine.fieldKeyboardType = BSValidator.getZipKeyboardType(countryCode: countryCode)
        self.phoneInputLine.fieldKeyboardType = .phonePad
        zipInputLine.isHidden = hideZip
        zipInputLine.hideError()
        updateZipFieldLocation()
    }
    
    private func updateState() {
        
        BSValidator.updateState(addressDetails: paymentRequest.getShippingDetails()!, countryManager: countryManager, stateInputLine: stateInputLine)
    }
    
    private func updateWithNewState(stateCode : String, stateName : String) {
        
        if let shippingDetails = paymentRequest.getShippingDetails() {
            shippingDetails.state = stateCode
        }
        self.stateInputLine.setValue(stateName)
    }
    
    private func updateZipFieldLocation() {
        
        if !zipInputLine.isHidden {
            zipTopConstraint.constant = zipTopConstraintOriginalConstant ?? 1
        } else {
            zipTopConstraint.constant = -1 * phoneInputLine.frame.height
        }
    }

    // MARK: Prevent rotation, support only Portrait mode
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

}
