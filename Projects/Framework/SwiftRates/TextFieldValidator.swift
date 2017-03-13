//
//  TextFieldValidator.swift
//  TextFieldValidator
//
//  Created by Anurag Kulkarni on 26/08/15.
//  Copyright (c) 2015 Anurag Kulkarni. All rights reserved.
//

import UIKit

let numberCharacterSet = CharacterSet.decimalDigits

let alphabetCharacterSet : CharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

let specialSymbolsCharacterSet : CharacterSet = CharacterSet(charactersIn: "!~`@#$%^&*-+();:=_{}[],.<>?\\/|\"\'")

class TextFieldValidator: UITextField,UITextFieldDelegate {
    
    //** properties which will decide which kind of validation user wants
    
    var ParentDelegate : AnyObject?
    
    var checkForEmptyTextField : Bool = false
    
    var allowOnlyNumbers : Bool = false
    
    var allowOnlyAlphabets : Bool = false
    
    var restrictSpecialSymbolsOnly : Bool = false
    
    var checkForValidEmailAddress : Bool = false
    
    var restrictTextFieldToLimitedCharecters : Bool = false
    
    var setNumberOfCharectersToBeRestricted : Int = 0
    
    var allowToShowAlertView : Bool = false
    
    var alertControllerForNumberOnly = UIAlertController()
    
    var alertControllerForAlphabetsOnly = UIAlertController()
    
    var alertControllerForSpecialSymbols = UIAlertController()
    
    var alertControllerForInvalidEmailAddress = UIAlertController()
    
    
    
    //MARK: awakeFromNib
    
    // Setting the delegate to class
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
    }
    
    //MARK: validation methods
    
    // 01. This method will check if there are any blank textFields in class
    
    class func checkIfAllFieldsAreFilled(_ view:UIView) -> Bool{
        
        let subviews : NSArray = view.subviews as NSArray
        if(subviews.count == 0){
            return false
        }
        
        for currentObject in subviews{
            if let currentObject = currentObject as? UITextField {
                if(currentObject.text!.isEmpty){
                    TextFieldValidator.shaketextField(currentObject)
                }
            }
            self.checkIfAllFieldsAreFilled(currentObject as! UIView)
        }
        
        return true
    }
    
    
    // 02. This method will check if there are any white space in the textField.
    
    class  func checkForWhiteSpaceInTextField(_ inputString : String) -> String{
        
        let trimmedString = inputString.trimmingCharacters(in: CharacterSet.whitespaces)
        
        return trimmedString
    }
    
    // 03. This method will allow only numbers in the textField.
    
    func allowOnlyNumbersInTextField(_ string : String)->Bool{
        
        let numberCharacterSet = CharacterSet.decimalDigits
        let inputString = string
        let range = inputString.rangeOfCharacter(from: numberCharacterSet)
        print(inputString)
        // range will be nil if no numbers are found
        if let test = range {
            
            return true
        }
        else {
            return false
            // do your stuff
        }
        
    }
    
    // 04. This method will allow only alphabets in the textField.
    
    func allowOnlyAlphabetsInTextField(_ string : String)->Bool{
        
        let inputString = string
        let range = inputString.rangeOfCharacter(from: alphabetCharacterSet)
        print(inputString)
        // range will be nil if no alphabet are found
        if let test = range {
            
            return true
        }
        else {
            
            return false
            // do your stuff
        }
        
        
    }
    
    // 05. This method will restrict only special symbols in the textField.
    
    func restrictSpecialSymbols(_ string : String) -> Bool
    {
        let range = string.rangeOfCharacter(from: specialSymbolsCharacterSet.inverted)
        print(string)
        // range will be nil if no specialSymbol are found
        if let test = range {
            
            return true
        }
        else {
            
            return false
            // do your stuff
        }
        
    }
    
    
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if(checkForValidEmailAddress){
            let emailReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let range = textField.text!.range(of: emailReg, options:.regularExpression)
            let result = range != nil ? true : false
            print(result)
            if(result){
                ParentDelegate as! UIViewController
                ParentDelegate!.present(alertControllerForInvalidEmailAddress, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(allowOnlyNumbers){
            if(string == ""){
                return true
            }
            let flag : Bool = self.allowOnlyNumbersInTextField(string)
            if(flag){
                return true
            }
            else{
                if(allowToShowAlertView){
                    ParentDelegate as! UIViewController
                    ParentDelegate!.present(alertControllerForNumberOnly, animated: true, completion: nil)
                    return false
                }
                
                
            }
            
        }
        else if(allowOnlyAlphabets){
            if(string == ""){
                return true
            }
            let flag : Bool = self.allowOnlyAlphabetsInTextField(string)
            if(flag){
                return true
            }
            else{
                if(allowToShowAlertView){
                    ParentDelegate as! UIViewController
                    ParentDelegate!.present(alertControllerForAlphabetsOnly, animated: true, completion: nil)
                    return false
                }
                
            }
            
        }
        else if(restrictSpecialSymbolsOnly){
            if(string == ""){
                return true
            }
            let flag : Bool = self.restrictSpecialSymbols(string)
            if(flag){
                return true
            }
            else{
                
                if(allowToShowAlertView){
                    ParentDelegate as! UIViewController
                    ParentDelegate!.present(alertControllerForSpecialSymbols, animated: true, completion: nil)
                    return false
                }
                
            }
            
        }
        else if(restrictTextFieldToLimitedCharecters){
            
            let newLength = textField.text!.characters.count + string.characters.count - range.length
            return newLength <= setNumberOfCharectersToBeRestricted
        }
            
        else{
            return true
        }
        return false
    }
    
    //MARK: Setter methods
    func setFlagForAllowNumbersOnly(_ flagForNumbersOnly : Bool){
        allowOnlyNumbers = flagForNumbersOnly
    }
    func setFlagForAllowAlphabetsOnly(_ flagForAlphabetsOnly : Bool){
        allowOnlyAlphabets = flagForAlphabetsOnly
    }
    func setFlagForRestrictSpecialSymbolsOnly(_ RestrictSpecialSymbols : Bool){
        restrictSpecialSymbolsOnly = RestrictSpecialSymbols
    }
    func setFlagForcheckForValidEmailAddressOnly(_ flagForValidEmailAddress : Bool){
        checkForValidEmailAddress = flagForValidEmailAddress
    }
    
    func setFlagForLimitedNumbersOFCharecters(_ numberOfCharacters : Int,flagForLimitedNumbersOfCharacters : Bool){
        restrictTextFieldToLimitedCharecters = flagForLimitedNumbersOfCharacters
        setNumberOfCharectersToBeRestricted = numberOfCharacters
    }
    
    
    
    //MARK: show alert methods
    
    func showAlertForNumberOnly(_ title: String, message: String, buttonTitles : NSArray, buttonActions: NSArray){
        
        alertControllerForNumberOnly = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        for i in (0  ..< buttonActions.count)
        {
            let count = i
            let buttonAction = UIAlertAction(title: buttonTitles[count] as! String, style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                if(buttonActions.count > 0){
                    let methodName = buttonActions[count] as! String
                    print(methodName)
                    Timer.scheduledTimer(timeInterval: 0, target: self.ParentDelegate as! UIViewController, selector: Selector(methodName), userInfo: nil, repeats: false)
                }
            })
            alertControllerForNumberOnly.addAction(buttonAction)
        }
        
    }
    
    func showAlertForAlphabetsOnly(_ title: String, message: String, buttonTitles : NSArray, buttonActions: NSArray){
        
        alertControllerForAlphabetsOnly = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        for i in (0  ..< buttonActions.count){
            let count = i
            let buttonAction = UIAlertAction(title: buttonTitles[count] as! String, style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                
                if(buttonActions.count > 0){
                    let methodName = buttonActions[count] as! String
                    print(methodName)
                    Timer.scheduledTimer(timeInterval: 0, target: self.ParentDelegate as! UIViewController, selector: Selector(methodName), userInfo: nil, repeats: false)
                }
                
                
            })
            alertControllerForAlphabetsOnly.addAction(buttonAction)
        }
        
    }
    
    func showAlertForSpecialSymbolsOnly(_ title: String, message: String, buttonTitles : NSArray, buttonActions: NSArray){
        
        alertControllerForSpecialSymbols = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        for i in (0  ..< buttonActions.count){
            let count = i
            let buttonAction = UIAlertAction(title: buttonTitles[count] as! String, style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                
                if(buttonActions.count > 0){
                    let methodName = buttonActions[count] as! String
                    print(methodName)
                    Timer.scheduledTimer(timeInterval: 0, target: self.ParentDelegate as! UIViewController, selector: Selector(methodName), userInfo: nil, repeats: false)
                }
                
                
            })
            alertControllerForSpecialSymbols.addAction(buttonAction)
        }
    }
    
    func showAlertForinvalidEmailAddrress(_ title: String, message: String, buttonTitles : NSArray, buttonActions: NSArray){
        
        alertControllerForInvalidEmailAddress = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        for i in (0  ..< buttonActions.count){
            let count = i
            let buttonAction = UIAlertAction(title: buttonTitles[count] as! String, style: UIAlertActionStyle.default, handler: { (UIAlertAction) -> Void in
                
                if(buttonActions.count > 0){
                    let methodName = buttonActions[count] as! String
                    print(methodName)
                    Timer.scheduledTimer(timeInterval: 0, target: self.ParentDelegate as! UIViewController, selector: Selector(methodName), userInfo: nil, repeats: false)
                }
                
                
            })
            alertControllerForInvalidEmailAddress.addAction(buttonAction)
        }
        
    }
    
    //MARK: shake textField
    class  func shaketextField(_ textfield : UITextField){
        let shake:CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let from_point:CGPoint = CGPoint(x: textfield.center.x - 5, y: textfield.center.y)
        let from_value:NSValue = NSValue(cgPoint: from_point)
        
        let to_point:CGPoint = CGPoint(x: textfield.center.x + 5, y: textfield.center.y)
        let to_value:NSValue = NSValue(cgPoint: to_point)
        
        shake.fromValue = from_value
        shake.toValue = to_value
        textfield.layer.add(shake, forKey: "position")
        
        
    }
    
}
