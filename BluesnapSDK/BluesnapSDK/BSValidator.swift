//
//  BSValidator.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 04/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

extension String {
    
    func removeWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    var isValidMonth : Bool {
        
        let validMonths = ["01","02","03","04","05","06","07","08","09","10","11","12"]
        return validMonths.contains(self)
    }

    var isValidEmail : Bool {
        let regex = try? NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.characters.count)) != nil
    }

    var isValidCCN : Bool {
        
        if characters.count < 6 {
            return false
        }
        
        var isOdd : Bool! = true
        var sum : Int! = 0;
        
        for character in characters.reversed() {
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
    
    var isValidName : Bool {
        
        if let p = self.characters.index(of: " ") {
            let firstName = substring(with: startIndex..<p).trimmingCharacters(in: .whitespaces)
            let lastName = substring(with: p..<endIndex).trimmingCharacters(in: .whitespaces)
            if firstName.characters.count < 2 || lastName.characters.count < 2 {
                return false
            }
        } else {
            return false
        }
        return true
    }
    
    var splitName : (firstName: String, lastName: String)? {
        
        if let p = self.characters.index(of: " ") {
            let firstName = substring(with: startIndex..<p).trimmingCharacters(in: .whitespaces)
            let lastName = substring(with: p..<endIndex).trimmingCharacters(in: .whitespaces)
            return (firstName, lastName)
        } else {
            return nil
        }
    }
    
    var last4 : String {
        
        let digits = self.removeNoneDigits
        if digits.characters.count >= 4 {
            let p = digits.characters.index(digits.endIndex, offsetBy: -4)
            return digits.substring(with: p..<digits.endIndex)
        } else {
            return ""
        }
    }
    
    var removeNoneAlphaCharacters : String {
        
        var result : String = "";
        for character in characters {
            if (character == " ") || (character >= "a" && character <= "z") || (character >= "A" && character <= "Z") {
                result.append(character)
            }
        }
        return result
    }
    
    var removeNoneEmailCharacters : String {
        
        var result : String = "";
        for character in characters {
            if (character == "-") ||
                (character == "_") ||
                (character == ".") ||
                (character == "@") ||
                (character >= "0" && character <= "9") ||
                (character >= "a" && character <= "z") ||
                (character >= "A" && character <= "Z") {
                result.append(character)
            }
        }
        return result
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
    
    func cutToMaxLength(maxLength: Int) -> String {
        if (characters.count < maxLength) {
            return self
        } else {
            let idx = index(startIndex, offsetBy: maxLength)
            return substring(with: startIndex..<idx)
        }
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
                    result += substring(with: idx2..<idx3) + " " + substring(from: idx3)
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
    
    var formatExp : String {
        
        var result: String
        let myLength = characters.count
        if (myLength > 2) {
            let idx1 = index(startIndex, offsetBy: 2)
            result = substring(to: idx1) + "/" + substring(from: idx1)
        } else {
            result = self
        }
        return result;
    }
    
    func getCCTypeByRegex() -> String? {
        
        // remove blanks
        let ccn = self.removeWhitespaces()
        
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

class BSValidator {
    
    
    // MARK: Constants
    
    internal static let ccnInvalidMessage = "Invalid card number"
    internal static let cvvInvalidMessage = "Invalid CVV"
    internal static let expMonthInvalidMessage = "Invalid expiration month"
    internal static let expPastInvalidMessage = "Expiration date is in the past"
    internal static let expInvalidMessage = "Invalid expiration date"
    internal static let nameInvalidMessage = "Enter a first and last name"
    internal static let emailInvalidMessage = "Invalid email"
    internal static let streetInvalidMessage = "Invalid street"
    internal static let cityInvalidMessage = "Invalid city"
    internal static let countryInvalidMessage = "Invalid country"
    internal static let stateInvalidMessage = "Invalid state"
    internal static let zipInvalidMessage = "Invalid code"

    static let defaultFieldColor = UIColor.black
    static let errorFieldColor = UIColor.red
    
    class func validateName(ignoreIfEmpty: Bool, input: BSInputLine, addressDetails: BSAddressDetails?) -> Bool {
        
        var result : Bool = true
        let newValue = input.getValue()?.trimmingCharacters(in: .whitespaces).capitalized ?? ""
        input.setValue(newValue)
        if newValue.characters.count == 0 && ignoreIfEmpty {
            // ignore
        } else if !newValue.isValidName {
            result = false
        }
        if result {
            input.hideError()
            if let addressDetails = addressDetails {
                addressDetails.name = newValue
            }
        } else {
            input.showError(nameInvalidMessage)
        }
        return result
    }
    
    class func validateEmail(ignoreIfEmpty: Bool, input: BSInputLine, addressDetails: BSAddressDetails?) -> Bool {
        
        let newValue = input.getValue()?.trimmingCharacters(in: .whitespaces) ?? ""
        var result : Bool = true
        if (ignoreIfEmpty && newValue.characters.count == 0) {
            // ignore
        } else if (!newValue.isValidEmail) {
            result = false
        } else {
            result = true
        }
        if result {
            input.hideError()
            if let addressDetails = addressDetails {
                addressDetails.email = newValue
            }
        } else {
            input.showError(emailInvalidMessage)
        }
        return result
    }
    
    class func validateAddress(ignoreIfEmpty : Bool, input: BSInputLine, addressDetails: BSAddressDetails?) -> Bool {
        
        let newValue = input.getValue()?.trimmingCharacters(in: .whitespaces) ?? ""
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
            if let addressDetails = addressDetails {
                addressDetails.address = newValue
            }
        } else {
            input.showError(streetInvalidMessage)
        }
        return result
    }
    
    class func validateCity(ignoreIfEmpty : Bool, input: BSInputLine, addressDetails: BSAddressDetails?) -> Bool {
        
        let newValue = input.getValue()?.trimmingCharacters(in: .whitespaces) ?? ""
        input.setValue(newValue)
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
            if let addressDetails = addressDetails {
                addressDetails.city = newValue
            }
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
        if (ignoreIfEmpty && newValue.characters.count == 0) {
            // ignore
        } else if (newValue.characters.count < 3) {
            result = false
        } else {
            result = true
        }
        if result {
            input.hideError()
            if let addressDetails = addressDetails {
                addressDetails.zip = newValue
            }
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
            let yy = newValue.substring(with: p ..< newValue.endIndex).removeNoneDigits
            if (mm.characters.count < 2) {
                ok = false
            } else if !mm.isValidMonth {
                ok = false
                msg = expMonthInvalidMessage
            } else if (yy.characters.count < 2) {
                ok = false
            } else if let month = Int(mm), let year = Int(yy) {
                var dateComponents = DateComponents()
                dateComponents.year = year + (getCurrentYear() / 100)*100
                dateComponents.month = month
                dateComponents.day = 1
                let expDate = Calendar.current.date(from: dateComponents)!
                ok = expDate > Date()
                msg = expPastInvalidMessage
            } else {
                ok = false
            }
        } else {
            ok = false
        }

        if (ok) {
            input.hideError()
        } else {
            input.showError(field: input.expTextField, errorText: msg)
        }
        return ok
    }
    
    class func getCurrentYear() -> Int! {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        return year
    }
    
    class func validateCvv(input: BSCcInputLine) -> Bool {
        
        var result : Bool = true;
        let newValue = input.cvvTextField.text ?? ""
        if newValue.characters.count < 3 {
            result = false
        }
        if result {
            input.hideError()
        } else {
            input.showError(field: input.cvvTextField, errorText: cvvInvalidMessage)
        }
        return result
    }
    
    class func validateCCN(input: BSCcInputLine) -> Bool {
        
        var result : Bool = true;
        let newValue : String! = input.ccnIsOpen ? (input.textField.text ?? "") : (input.ccn ?? "")
        if !newValue.isValidCCN {
            result = false
        }
        if result {
            input.hideError()
        } else {
            input.showError(field: input.textField, errorText: ccnInvalidMessage)
        }
        return result
    }
    
    class func nameEditingChanged(_ sender: BSInputLine) {
        
        var input : String = sender.getValue() ?? ""
        input = input.removeNoneAlphaCharacters.cutToMaxLength(maxLength: 100)
        sender.setValue(input)
    }
    
    class func emailEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = input.removeNoneEmailCharacters.cutToMaxLength(maxLength: 1200)
        sender.text = input
    }
    
    class func emailEditingChanged(_ sender: BSInputLine) {
        
        var input : String = sender.getValue() ?? ""
        input = input.removeNoneEmailCharacters.cutToMaxLength(maxLength: 1200)
        sender.setValue(input)
    }
    
    class func addressEditingChanged(_ sender: BSInputLine) {
        
        var input : String = sender.getValue() ?? ""
        input = input.cutToMaxLength(maxLength: 100)
        sender.setValue(input)
    }
    
    class func cityEditingChanged(_ sender: BSInputLine) {
        
        var input : String = sender.getValue() ?? ""
        input = input.removeNoneAlphaCharacters.cutToMaxLength(maxLength: 50)
        sender.setValue(input)
    }
    
    class func zipEditingChanged(_ sender: BSInputLine) {
        
        var input : String = sender.getValue() ?? ""
        input = input.cutToMaxLength(maxLength: 20)
        sender.setValue(input)
    }
    
    class func ccnEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = input.removeNoneDigits.cutToMaxLength(maxLength: 21).formatCCN
        sender.text = input
    }
    
    class func expEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = input.removeNoneDigits.cutToMaxLength(maxLength: 4).formatExp
        sender.text = input
    }
    
    class func cvvEditingChanged(_ sender: UITextField) {
        
        var input : String = sender.text ?? ""
        input = input.removeNoneDigits.cutToMaxLength(maxLength: 4)
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

}

