//
//  BSBaseTextInput.swift
//  BluesnapSDK
//
//  Base control with one text field, one image button showing on a white
//  strip with a shadow. The field can be editable or not.
//
//  Created by Shevie Chen on 22/05/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import UIKit

@IBDesignable
class BSBaseTextInput: UIControl, UITextFieldDelegate {

    // MARK: Configurable properties
    

    // Text input configurable properties
    
    @IBInspectable var isEditable: String? // because of xCode bug, bool doesn't work. So if there is no value - the field is editable, if you put ANYHTING in it - it will be disabled.
    @IBInspectable var placeHolder: String = "" {
        didSet {
            textField.placeholder = placeHolder
        }
    }
    @IBInspectable var textColor: UIColor = UIColor.black{
        didSet {
            setElementAttributes()
        }
    }
    @IBInspectable var fieldBkdColor: UIColor = UIColor.white {
        didSet {
            setElementAttributes()
        }
    }
    @IBInspectable var fieldKeyboardType : UIKeyboardType = UIKeyboardType.default {
        didSet {
            setKeyboardType()
        }
    }
    @IBInspectable var fontName : String = "Helvetica Neue" {
        didSet {
            self.setFont()
        }
    }
    @IBInspectable var fieldFontSize : CGFloat = 17 {
        didSet {
            self.setFont()
        }
    }
    @IBInspectable var fieldCornerRadius : CGFloat = 0 {
        didSet {
            resizeElements()
        }
    }
    @IBInspectable var fieldBorderWidth : CGFloat = 0 {
        didSet {
            setElementAttributes()
        }
    }
    @IBInspectable var fieldBorderColor: UIColor? {
        didSet {
            setElementAttributes()
        }
    }
    
    // image configurable properties
    
    @IBInspectable var image: UIImage? {
        didSet {
            imageButton.imageView?.image = image
        }
    }
    
    // Size and margin size configurable properties: set the sizes according to your design width and height, 
    // they will be resized at runtime using horizontal and vertical ratio between this size and the actual screen size
    
    @IBInspectable var designWidth : CGFloat = 335 {
        didSet {
            resizeElements()
        }
    }
    @IBInspectable var designHeight : CGFloat = 43 {
        didSet {
            resizeElements()
        }
    }
    
    @IBInspectable var leftMargin : CGFloat = 16 {
        didSet {
            resizeElements()
        }
    }
    @IBInspectable var middleMargin : CGFloat = 8 {
        didSet {
            resizeElements()
        }
    }
    @IBInspectable var rightMargin : CGFloat = 16 {
        didSet {
            resizeElements()
        }
    }
    @IBInspectable var fieldHeight : CGFloat = 20 {
        didSet {
            resizeElements()
        }
    }
    
    @IBInspectable var imageWidth : CGFloat = 21 {
        didSet {
            resizeElements()
        }
    }
    @IBInspectable var imageHeight : CGFloat = 15 {
        didSet {
            resizeElements()
        }
    }

    // Error message properties
    
    @IBInspectable var errorText: String = "Please supply a valid value"
    @IBInspectable var errorHeight : CGFloat = 12
    @IBInspectable var errorFontSize : CGFloat = 10
    @IBInspectable var errorColor : UIColor = UIColor.red

    // background, border and shadow configurable properties
    
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            drawBoundsAndShadow()
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor(red: 248, green: 248, blue: 248, alpha: 1) {
        didSet {
            drawBoundsAndShadow()
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0.5 {
        didSet {
            drawBoundsAndShadow()
        }
    }
    private var customBackgroundColor = UIColor.white
    @IBInspectable override var backgroundColor: UIColor? {
        didSet {
            customBackgroundColor = backgroundColor!
            super.backgroundColor = UIColor.clear
        }
    }
    @IBInspectable var shadowDarkColor: UIColor = UIColor.lightGray {
        didSet {
            setElementAttributes()
        }
    }
    @IBInspectable var shadowRadius: CGFloat = 15.0 {
        didSet {
            setElementAttributes()
        }
    }
    @IBInspectable var shadowOpacity: CGFloat = 0.5 {
        didSet {
            setElementAttributes()
        }
    }
    
    // MARK: Other public properties
    
    public var fieldBorderStyle : UITextBorderStyle = .none
    
    // MARK: UI elements
    
    internal var textField : UITextField = UITextField()
    internal var imageButton : UIButton!
    internal var errorLabel : UILabel?
    internal var fieldCoverButton : UIButton?
    
    // MARK: private properties
    
    var shouldSetupConstraints = true
    var designMode = false
    internal var errorField : UITextField?
    
    var actualFieldFontSize : CGFloat = 17
    var actualLeftMargin : CGFloat = 16
    var actualMiddleMargin : CGFloat = 8
    var actualRightMargin : CGFloat = 16
    var actualFieldHeight : CGFloat = 20
    var actualImageWidth : CGFloat = 21
    var actualImageHeight : CGFloat = 15
    var actualErrorHeight : CGFloat = 12
    var actualErrorFontSize : CGFloat = 10


    //internal var hRatio : CGFloat = 1.0
    //internal var vRatio : CGFloat = 1.0

    // MARK: public functions
    
    public func getValue() -> String! {
        
        return textField.text
    }
    
    public func setValue(_ newValue: String!) {
        
        textField.text = newValue
    }
    
    public func showError(_ errorText : String?) {
        
        showError(field: self.textField, errorText: errorText)
    }
    
    public func hideError() {
        
        hideError(textField)
    }
    
    public func showError(field: UITextField!, errorText : String?) {
        
        self.errorText = errorText ?? ""
        self.errorField = field
        field.textColor = self.errorColor
        
        buildErrorLabel()
        if let errorLabel = errorLabel {
            if errorText != nil {
                errorLabel.text = self.errorText
                errorLabel.isHidden = false
                resizeError()
            }
        }
    }
    
    public func hideError(_ field: UITextField?) {
        
        if field == nil || errorField == field {
            if let errorLabel = errorLabel {
                errorLabel.isHidden = true
                errorField?.textColor = self.textColor
            }
        }
    }    
    
    // MARK: TextFieldDelegate functions

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    // MARK: Internal functions
    
    // called at design time (StoryBoard)
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        designMode = true
        buildElements()
    }
    
    // called at runtime
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        designMode = false
        buildElements()
        NotificationCenter.default.addObserver(
            self,
            selector:  #selector(deviceDidRotate),
            name: .UIDeviceOrientationDidChange,
            object: nil
        )
    }
    
    override func draw(_ rect: CGRect) {
        
        _ = initRatios()
        resizeElements()
        drawBoundsAndShadow()
    }
    
    func deviceDidRotate() {
        draw(CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    private func drawBoundsAndShadow() {
        
        // set rounded corners
        
        customBackgroundColor.setFill()
        UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).fill()
        
        // set shadow
        
        let borderRect = bounds.insetBy(dx: borderWidth/2, dy: borderWidth/2)
        let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: cornerRadius - borderWidth/2)
        borderColor.setStroke()
        borderPath.lineWidth = borderWidth
        borderPath.stroke()
        //UIColor.clear.setStroke()
        //self.layer.shouldRasterize = true
    }
    
    private func shouldCoverTextField()-> Bool {
        return self.isEditable != nil
    }
    
    internal func initRatios() -> (hRatio: CGFloat, vRatio: CGFloat) {
                
        // To make sure we fit in the givemn size, we set all widths and horizontal margins
        // according to this ratio.
        let hRatio = self.frame.width / self.designWidth
        let vRatio = self.frame.height / self.designHeight
        
        actualRightMargin = (rightMargin * hRatio).rounded()
        actualLeftMargin = (leftMargin * hRatio).rounded()
        actualMiddleMargin = (middleMargin * hRatio).rounded()
        actualImageWidth = (imageWidth * hRatio).rounded()
        actualImageHeight = (imageHeight * vRatio).rounded()
        actualFieldFontSize = (fieldFontSize * vRatio).rounded()
        actualFieldHeight = (fieldHeight * vRatio).rounded()
        actualErrorFontSize = (errorFontSize*vRatio).rounded()
        actualErrorHeight = (errorHeight * vRatio).rounded()
        
        //NSLog("width=\(self.frame.width), hRatio=\(hRatio), height=\(self.frame.height), vRatio=\(vRatio)")
        
        return (hRatio: hRatio, vRatio: vRatio)
    }
    
    internal func buildElements() {

        // init stuff on the items that needs to run only once (as opposed to sizes that may change)
        self.addSubview(textField)
        
        textField.addTarget(self, action: #selector(BSInputLine.textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(BSInputLine.textFieldDidEndEditing(_:)), for: .editingDidEnd)
        textField.addTarget(self, action: #selector(BSInputLine.textFieldEditingChanged(_:)), for: .editingChanged)
        textField.delegate = self
        
        self.imageButton = UIButton(type: UIButtonType.custom)
        self.addSubview(imageButton)
        imageButton.addTarget(self, action: #selector(BSBaseTextInput.imageTouchUpInside(_:)), for: .touchUpInside)
        imageButton.contentVerticalAlignment = .fill
        imageButton.contentHorizontalAlignment = .center
        
        setElementAttributes()
    }
    
    internal func setKeyboardType() {
        
        textField.keyboardType = fieldKeyboardType
        if fieldKeyboardType == .numberPad {
            self.setNumericKeyboard()
        } else {
            self.removeNumericKeyboard()
        }
    }
    
    // set the attributes that are not affected by resizing
    internal func setElementAttributes() {
        
        // set stuff for shadow
        layer.shadowColor = shadowDarkColor.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = Float(shadowOpacity)
        super.backgroundColor = UIColor.clear
        
        setKeyboardType()
        textField.backgroundColor = self.fieldBkdColor
        textField.textColor = self.textColor
        textField.returnKeyType = UIReturnKeyType.done
        
        textField.borderStyle = fieldBorderStyle
        textField.layer.borderWidth = fieldBorderWidth
 
        if let fieldBorderColor = self.fieldBorderColor {
            self.textField.layer.borderColor = fieldBorderColor.cgColor
        }
    }
    
    override func prepareForInterfaceBuilder() {
        
        super.prepareForInterfaceBuilder()
        setElementAttributes()
        resizeElements()
    }
    
    internal func setFont() {
        
        if let fieldFont : UIFont = UIFont(name: self.fontName, size: actualFieldFontSize) {
            textField.font = fieldFont
        }
    }
    
    internal func resizeElements() {
        
        if designMode {
            // re-calculate the actual sizes
            _ = initRatios()
        }
        
        setFont()
        
        if image == nil {
            imageButton.isHidden = true
        } else {
            imageButton.isHidden = false
            imageButton.setImage(image, for: UIControlState.normal)
            imageButton.frame = getImageRect()
        }
        
        let actualFieldWidth : CGFloat = getFieldWidth()
        let fieldX = getFieldX()
        let fieldY = (self.frame.height-actualFieldHeight)/2
        textField.frame = CGRect(x: fieldX, y: fieldY, width: actualFieldWidth, height: actualFieldHeight)
        
        buildFieldCoverButton()
        if let fieldCoverButton = fieldCoverButton {
            if shouldCoverTextField() == true {
                fieldCoverButton.frame = CGRect(x: fieldX, y: fieldY, width: actualFieldWidth, height: actualFieldHeight)
            }
        }
        
        resizeError()
        
        if fieldCornerRadius != 0 {
            self.textField.layer.cornerRadius = fieldCornerRadius
        }
    }
    
    internal func getImageRect() -> CGRect {
        return CGRect(x: self.frame.width-actualRightMargin-actualImageWidth, y: (self.frame.height-actualImageHeight)/2, width: actualImageWidth, height: actualImageHeight)
    }
    
    internal func getFieldWidth() -> CGFloat {
        
        let actualFieldWidth : CGFloat = self.frame.width - (image != nil ? actualImageWidth : 0) - actualLeftMargin - actualRightMargin - actualMiddleMargin
        return actualFieldWidth
    }
    
    internal func getFieldX() -> CGFloat {
        
        return actualLeftMargin
    }
    
    private func buildFieldCoverButton() {
        
        if shouldCoverTextField() == false {
            if let fieldCoverButton = fieldCoverButton {
                fieldCoverButton.isHidden = true
                textField.isUserInteractionEnabled = true
            }
        } else {
            if fieldCoverButton == nil {
                fieldCoverButton = UIButton()
                if let fieldCoverButton = fieldCoverButton {
                    fieldCoverButton.backgroundColor = UIColor.clear
                    //fieldCoverButton.alpha = 0.3
                    self.addSubview(fieldCoverButton)
                    fieldCoverButton.addTarget(self, action: #selector(BSInputLine.fieldCoverButtonTouchUpInside(_:)), for: .touchUpInside)
                }
            }
            if let fieldCoverButton = fieldCoverButton {
                fieldCoverButton.isHidden = false
                textField.isUserInteractionEnabled = false
                
                // remove later
                //fieldCoverButton.backgroundColor = UIColor.yellow
                //fieldCoverButton.alpha = 0.5
            }
        }
    }
    
    internal func buildErrorLabel() {
        
        if errorLabel == nil {
            errorLabel = UILabel()
            self.addSubview(errorLabel!)
        }
        if let errorLabel = errorLabel {
            errorLabel.backgroundColor = UIColor.clear
            errorLabel.textColor = self.errorColor
            errorLabel.isHidden = true
            errorLabel.textAlignment = .left
        }
    }
    
    internal func resizeError() {
        if let errorLabel = errorLabel {
            if !errorLabel.isHidden {
                if let labelFont : UIFont = UIFont(name: self.fontName, size: actualErrorFontSize) {
                    errorLabel.font = labelFont
                }
                errorLabel.frame = CGRect(x: textField.frame.minX, y: self.frame.height-actualErrorHeight, width: textField.frame.width, height: actualErrorHeight)
            }
        }
    }
    
    override func updateConstraints() {
        
        //NSLog("updateConstraints, shouldSetupConstraints=\(shouldSetupConstraints)")
        if (shouldSetupConstraints) {
            // AutoLayout constraints
            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }
    
    // MARK:- ---> Action methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        hideError(textField)
        sendActions(for: UIControlEvents.editingDidBegin)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        sendActions(for: UIControlEvents.editingDidEnd)
    }
    func textFieldEditingChanged(_ textField: UITextField) {
        
        sendActions(for: UIControlEvents.editingChanged)
    }
    
    func imageTouchUpInside(_ sender: Any) {
        
        sendActions(for: UIControlEvents.touchUpInside)
    }
    
    func fieldCoverButtonTouchUpInside(_ sender: Any) {
        
        sendActions(for: UIControlEvents.touchUpInside)
    }

    // MARK: Numeric Keyboard "done" button enhancement
    
    internal func createDoneButtonForKeyboard() -> UIToolbar {
        
        let viewForDoneButtonOnKeyboard = UIToolbar()
        viewForDoneButtonOnKeyboard.sizeToFit()
        let btnDoneOnKeyboard = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneBtnfromKeyboardClicked))
        viewForDoneButtonOnKeyboard.semanticContentAttribute = .forceRightToLeft
        viewForDoneButtonOnKeyboard.items = [btnDoneOnKeyboard]
        return viewForDoneButtonOnKeyboard
     }

    @IBAction func doneBtnfromKeyboardClicked (sender: Any) {
        //Hide Keyboard by endEditing
        self.endEditing(true)
    }
    
    internal func setNumericKeyboard() {
        
        let viewForDoneButtonOnKeyboard = createDoneButtonForKeyboard()
        self.textField.inputAccessoryView = viewForDoneButtonOnKeyboard
    }
    
    internal func removeNumericKeyboard() {
        
        self.textField.inputAccessoryView = nil
    }


}
