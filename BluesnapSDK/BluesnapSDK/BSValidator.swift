//
//  BSValidator.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 04/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

public class BSValidator {
    
    
    // MARK: Constants
    
    static let ccnInvalidMessage = "Invalid card number"
    static let cvvInvalidMessage = "Invalid CVV"
    static let expMonthInvalidMessage = "Invalid month"
    static let expPastInvalidMessage = "Date is in the past"
    static let expInvalidMessage = "Invalid date"
    static let nameInvalidMessage = "Enter a first and last name"
    static let emailInvalidMessage = "Invalid email"
    static let streetInvalidMessage = "Invalid street"
    static let cityInvalidMessage = "Invalid city"
    static let countryInvalidMessage = "Invalid country"
    static let stateInvalidMessage = "Invalid state"
    static let zipInvalidMessage = "Invalid code"

    static let defaultFieldColor = UIColor.black
    static let errorFieldColor = UIColor.red
    
    // MARK: validation functions (check UI field and hide/show errors as necessary)
    
    class func validateName(ignoreIfEmpty: Bool, input: BSInputLine, addressDetails: BSAddressDetails?) -> Bool {
        
        var result : Bool = true
        let newValue = input.getValue()?.trimmingCharacters(in: .whitespaces).capitalized ?? ""
        input.setValue(newValue)
        if let addressDetails = addressDetails {
            addressDetails.name = newValue
        }
        if newValue.characters.count == 0 && ignoreIfEmpty {
            // ignore
        } else if !isValidName(newValue) {
            result = false
        }
        if result {
            input.hideError()
        } else {
            input.showError(nameInvalidMessage)
        }
        return result
    }
    
    class func validateEmail(ignoreIfEmpty: Bool, input: BSInputLine, addressDetails: BSAddressDetails?) -> Bool {
        
        let newValue = input.getValue()?.trimmingCharacters(in: .whitespaces) ?? ""
        if let addressDetails = addressDetails {
            addressDetails.email = newValue
        }
        var result : Bool = true
        if (ignoreIfEmpty && newValue.characters.count == 0) {
            // ignore
        } else if (!isValidEmail(newValue)) {
            result = false
        } else {
            result = true
        }
        if result {
            input.hideError()
        } else {
            input.showError(emailInvalidMessage)
        }
        return result
    }
    
    class func validateAddress(ignoreIfEmpty : Bool, input: BSInputLine, addressDetails: BSAddressDetails?) -> Bool {
        
        let newValue = input.getValue()?.trimmingCharacters(in: .whitespaces) ?? ""
        if let addressDetails = addressDetails {
            addressDetails.address = newValue
        }
        var result : Bool = true
        if (ignoreIfEmpty && newValue.characters.count == 0) {
            // ignore
        } else if (newValue.characters.count < 3) {
            result = false
        } else {
            result = true
        }
        if result {
            input.hideError()
        } else {
            input.showError(streetInvalidMessage)
        }
        return result
    }
    
    class func validateCity(ignoreIfEmpty : Bool, input: BSInputLine, addressDetails: BSAddressDetails?) -> Bool {
        
        let newValue = input.getValue()?.trimmingCharacters(in: .whitespaces) ?? ""
        input.setValue(newValue)
        if let addressDetails = addressDetails {
            addressDetails.city = newValue
        }
        var result : Bool = true
        if (ignoreIfEmpty && newValue.characters.count == 0) {
            // ignore
        } else if (newValue.characters.count < 3) {
            result = false
        } else {
            result = true
        }
        if result {
            input.hideError()
        } else {
            input.showError(cityInvalidMessage)
        }
        return result
    }
    
    class func validateCountry(ignoreIfEmpty : Bool, input: BSInputLine, addressDetails: BSAddressDetails?) -> Bool {
        
        let newValue = addressDetails?.country ?? ""
        var result : Bool = true
        if (ignoreIfEmpty && newValue.characters.count == 0) {
            // ignore
        } else if (newValue.characters.count < 2) {
            result = false
        } else {
            result = true
        }
        if result {
            input.hideError()
        } else {
            input.showError(countryInvalidMessage)
        }
        return result
    }

    class func validateZip(ignoreIfEmpty : Bool, input: BSInputLine, addressDetails: BSAddressDetails?) -> Bool {
        
        var result : Bool = true
        let newValue1 : String = input.getValue() ?? ""
        let newValue : String = newValue1.trimmingCharacters(in: .whitespaces)
        if let addressDetails = addressDetails {
            addressDetails.zip = newValue
        }
        if (ignoreIfEmpty && newValue.characters.count == 0) {
            // ignore
        } else if (newValue.characters.count < 3) {
            result = false
        } else {
            result = true
        }
        if result {
            input.hideError()
        } else {
            input.showError(zipInvalidMessage)
        }
        return result
    }

    class func validateState(ignoreIfEmpty : Bool, input: BSInputLine, addressDetails: BSAddressDetails?) -> Bool {
        
        let newValue = addressDetails?.state ?? ""
        var result : Bool = true
        if ((ignoreIfEmpty || input.isHidden) && newValue.characters.count == 0) {
            // ignore
        } else if (newValue.characters.count < 2) {
            result = false
        } else {
            result = true
        }
        if result {
            input.hideError()
        } else {
            input.showError(stateInvalidMessage)
        }
        return result
    }
    
    class func validateExp(input: BSCcInputLine) -> Bool {
        
        var ok : Bool = true
        var msg : String = expInvalidMessage
        
        let newValue = input.expTextField.text ?? ""
        if let p = newValue.characters.index(of: "/") {
            let mm = newValue.substring(with: newValue.startIndex..<p)
            let yy = BSStringUtils.removeNoneDigits(newValue.substring(with: p ..< newValue.endIndex))
            if (mm.characters.count < 2) {
                ok = false
            } else if !isValidMonth(mm) {
                ok = false
                msg = expMonthInvalidMessage
            } else if (yy.characters.count < 2) {
                ok = false
            } else if let month = Int(mm), let year = Int(yy) {
                var dateComponents = DateComponents()
                let currYear : Int! = getCurrentYear()
                dateComponents.year = year + (currYear / 100)*100
                dateComponents.month = month
                dateComponents.day = 1
                let expDate = Calendar.current.date(from: dateComponents)!
                if dateComponents.year! > currYear + 10 {
                    ok = false
                } else {
                    ok = expDate > Date()
                    msg = expPastInvalidMessage
                }
            } else {
                ok = false
            }
        } else {
            ok = false
        }

        if (ok) {
            input.hideExpError()
        } else {
            input.showExpError(msg)
        }
        return ok
    }
    
    class func validateCvv(input: BSCcInputLine, cardType: String) -> Bool {
        
        var result : Bool = true;
        let newValue = input.getCvv() ?? ""
        if newValue.characters.count != getCvvLength(cardType: cardType) {
            result = false
        }
        if result {
            input.hideCvvError()
        } else {
            input.showCvvError(cvvInvalidMessage)
        }
        return result
    }
    
    class func validateCCN(input: BSCcInputLine) -> Bool {
        
        var result : Bool = true;
        let newValue : String! = input.getValue()
        if !isValidCCN(newValue) {
            result = false
        }
        if result {
            input.hideError()
        } else {
            input.showError(ccnInvalidMessage)
        }
        return result
    }
    
    // MARK: field editing changed methods (to limit characters and sizes)
    
    class func nameEditingChanged(_ sender: BSInputLine) {
        
        var input : String = sender.getValue() ?? ""
        input = BSStringUtils.removeNoneAlphaCharacters(input)
        input = BSStringUtils.cutToMaxLength(input, maxLength: 100)
        sender.setValue(input)
    }
    
    class func emailEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = BSStringUtils.removeNoneEmailCharacters(input)
        input = BSStringUtils.cutToMaxLength(input, maxLength: 120)
        sender.text = input
    }
    
    class func emailEditingChanged(_ sender: BSInputLine) {
        
        var input : String = sender.getValue() ?? ""
        input = BSStringUtils.removeNoneEmailCharacters(input)
        input = BSStringUtils.cutToMaxLength(input, maxLength: 120)
        sender.setValue(input)
    }
    
    class func addressEditingChanged(_ sender: BSInputLine) {
        
        var input : String = sender.getValue() ?? ""
        input = BSStringUtils.cutToMaxLength(input, maxLength: 100)
        sender.setValue(input)
    }
    
    class func cityEditingChanged(_ sender: BSInputLine) {
        
        var input : String = sender.getValue() ?? ""
        input = BSStringUtils.removeNoneAlphaCharacters(input)
        input = BSStringUtils.cutToMaxLength(input, maxLength: 50)
        sender.setValue(input)
    }
    
    class func zipEditingChanged(_ sender: BSInputLine) {
        
        var input : String = sender.getValue() ?? ""
        input = BSStringUtils.cutToMaxLength(input, maxLength: 20)
        sender.setValue(input)
    }
    
    class func ccnEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = BSStringUtils.removeNoneDigits(input)
        input = BSStringUtils.cutToMaxLength(input, maxLength: 21)
        input = formatCCN(input)
        sender.text = input
    }
    
    class func expEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = BSStringUtils.removeNoneDigits(input)
        input = BSStringUtils.cutToMaxLength(input, maxLength: 4)
        input = formatExp(input)
        sender.text = input
    }
    
    class func cvvEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = BSStringUtils.removeNoneDigits(input)
        input = BSStringUtils.cutToMaxLength(input, maxLength: 4)
        sender.text = input
    }
    
    class func updateState(addressDetails: BSAddressDetails!, countryManager: BSCountryManager, stateInputLine: BSInputLine) {
        
        let selectedCountryCode = addressDetails.country ?? ""
        let selectedStateCode = addressDetails.state ?? ""
        var hideState : Bool = true
        stateInputLine.setValue("")
        if countryManager.countryHasStates(countryCode: selectedCountryCode) {
            hideState = false
            if let stateName = countryManager.getStateName(countryCode: selectedCountryCode, stateCode: selectedStateCode){
                stateInputLine.setValue(stateName)
            }
        } else {
            addressDetails.state = nil
        }
        stateInputLine.isHidden = hideState
        stateInputLine.hideError()
    }

    // MARK: Basic validation functions
    
    
    open class func isValidMonth(_ str: String) -> Bool {
        
        let validMonths = ["01","02","03","04","05","06","07","08","09","10","11","12"]
        return validMonths.contains(str)
    }
    
    open class func isValidEmail(_ str: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: str)
    }
    
    open class func isValidCCN(_ str: String) -> Bool {
        
        if str.characters.count < 6 {
            return false
        }
        
        var isOdd : Bool! = true
        var sum : Int! = 0;
        
        for character in str.characters.reversed() {
            if (character == " ") {
                // ignore
            } else if (character >= "0" && character <= "9") {
                var digit : Int! = Int(String(character))!
                isOdd = !isOdd
                if (isOdd == true) {
                    digit = digit * 2
                }
                if digit > 9 {
                    digit = digit - 9
                }
                sum = sum + digit
            } else {
                return false
            }
        }
        return sum % 10 == 0
    }
    
    open class func isValidName(_ str: String) -> Bool {
        
        if let p = str.characters.index(of: " ") {
            let firstName = str.substring(with: str.startIndex..<p).trimmingCharacters(in: .whitespaces)
            let lastName = str.substring(with: p..<str.endIndex).trimmingCharacters(in: .whitespaces)
            if firstName.characters.count < 2 || lastName.characters.count < 2 {
                return false
            }
        } else {
            return false
        }
        return true
    }
    
    
    open class func getCvvLength(cardType: String) -> Int {
        var cvvLength = 3
        if cardType.lowercased() == "amex" {
            cvvLength = 4
        }
        return cvvLength
    }

    
    // MARK: formatting functions
    
    class func getCurrentYear() -> Int! {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        return year
    }
    
    class func getCcLengthByCardType(_ cardType: String) -> Int! {
        
        var maxLength : Int = 16
        if cardType == "amex" {
            maxLength = 15
        } else if cardType == "dinersclub" {
            maxLength = 14
        }
        return maxLength
    }
    
    
    // MARK:
    
    open class func formatCCN(_ str: String) -> String {
        
        var result: String
        let myLength = str.characters.count
        if (myLength > 4) {
            let idx1 = str.index(str.startIndex, offsetBy: 4)
            result = str.substring(to: idx1) + " "
            if (myLength > 8) {
                let idx2 = str.index(idx1, offsetBy: 4)
                result += str.substring(with: idx1..<idx2) + " "
                if (myLength > 12) {
                    let idx3 = str.index(idx2, offsetBy: 4)
                    result += str.substring(with: idx2..<idx3) + " " + str.substring(from: idx3)
                } else {
                    result += str.substring(from:idx2)
                }
            } else {
                result += str.substring(from: idx1)
            }
        } else {
            result = str
        }
        return result
    }
    
    open class func formatExp(_ str: String) -> String {
        
        var result: String
        let myLength = str.characters.count
        if (myLength > 2) {
            let idx1 = str.index(str.startIndex, offsetBy: 2)
            result = str.substring(to: idx1) + "/" + str.substring(from: idx1)
        } else {
            result = str
        }
        return result
    }
    
    open class func getCCTypeByRegex(_ str: String) -> String? {
        
        // remove blanks
        let ccn = BSStringUtils.removeWhitespaces(str)
        
        // Display the card type for the card Regex
        let cardTypesRegex = [
            //"elo": "^(40117[8-9]|431274|438935|451416|457393|45763[1-2]|504175|506699|5067[0-6][0-9]|50677[0-8]|509[0-9][0-9][0-9]|636368|636369|636297|627780).*",
            //"HiperCard": "^(606282|637095).*",
            //"Cencosud": "^603493.*",
            //"Naranja": "^589562.*",
            //"TarjetaShopping": "^(603488|(27995[0-9])).*",
            //"ArgenCard": "^(501105).*",
            //"Cabal": "^((627170)|(589657)|(603522)|(604((20[1-9])|(2[1-9][0-9])|(3[0-9]{2})|(400)))).*",
            //"Solo": "^(6334|6767).*",
            "visa": "^4.+",
            "mastercard": "^(5(([1-5])|(0[1-5]))|2(([2-6])|(7(1|20)))|6((0(0[2-9]|1[2-9]|2[6-9]|[3-5]))|(2((1(0|2|3|[5-9]))|20|7[0-9]|80))|(60|3(0|[3-9]))|(4[0-2]|[6-8]))).+",
            "amex": "^3(24|4[0-9]|7|56904|379(41|12|13)).+",
            "discover": "^(3[8-9]|(6((01(1|300))|4[4-9]|5))).+",
            "maestro": "^6759.+|560000227571480302|5200000000000049|560000841211092515|6331101234567892|560000000000000193|560000000000000193|6331101250353227|6331100610194313|6331100266977839|560000511607577094",
            "dinersclub": "^(3(0([0-5]|9|55)|6)).*",
            "jcb": "^(2131|1800|35).*",
            "unionpay": "(^62(([4-6]|8)[0-9]{13,16}|2[2-9][0-9]{12,15}))$"
            //,"CarteBleue": "^((3(6[1-4]|77451))|(4(059(?!34)|150|201|561|562|533|556|97))|(5(0[1-4]|13|30066|341[0-1]|587[0-2]|6|8))|(6(27244|390|75[1-6]|799999998))).*"
        ];
        for (cardType, regexp) in cardTypesRegex {
            if let _ = ccn.range(of:regexp, options: .regularExpression) {
                return cardType
            }
        }
        return nil
    }

}

