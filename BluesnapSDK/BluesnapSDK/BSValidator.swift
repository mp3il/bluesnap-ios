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
    
 /*   var formatExp : String {
        
        var result : String
        if characters.count < 2 {
            result = self
        } else {
            let idx = index(startIndex, offsetBy: 2)
            result = substring(with: startIndex..<idx) + "/"
            result += substring(with: idx..<endIndex)
        }
        return result
    }*/
    
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
    
    func getCCType() -> String? {
        
        // remove blanks
        let ccn = self.removeWhitespaces()
        
        // Display the card type for the card Regex
        let cardTypesRegex = [
            "Elo": "^(40117[8-9]|431274|438935|451416|457393|45763[1-2]|504175|506699|5067[0-6][0-9]|50677[0-8]|509[0-9][0-9][0-9]|636368|636369|636297|627780).*",
            "HiperCard": "^(606282|637095).*",
            "Cencosud": "^603493.*",
            "Naranja": "^589562.*",
            "TarjetaShopping": "^(603488|(27995[0-9])).*",
            "ArgenCard": "^(501105).*",
            "Cabal": "^((627170)|(589657)|(603522)|(604((20[1-9])|(2[1-9][0-9])|(3[0-9]{2})|(400)))).*",
            "Solo": "^(6334|6767).*",
            "Visa": "^4.+",
            "MasterCard": "^(5(([1-5])|(0[1-5]))|2(([2-6])|(7(1|20)))|6((0(0[2-9]|1[2-9]|2[6-9]|[3-5]))|(2((1(0|2|3|[5-9]))|20|7[0-9]|80))|(60|3(0|[3-9]))|(4[0-2]|[6-8]))).+",
            "AmericanExpress": "^3(24|4[0-9]|7|56904|379(41|12|13)).+",
            "Discover": "^(3[8-9]|(6((01(1|300))|4[4-9]|5))).+",
            "MaestroUK": "^6759.+|560000227571480302|5200000000000049|560000841211092515|6331101234567892|560000000000000193|560000000000000193|6331101250353227|6331100610194313|6331100266977839|560000511607577094",
            "DinersClub": "^(3(0([0-5]|9|55)|6)).*",
            "JCB": "^(2131|1800|35).*",
            "ChinaUnionPay": "(^62(([4-6]|8)[0-9]{13,16}|2[2-9][0-9]{12,15}))$",
            "CarteBleue": "^((3(6[1-4]|77451))|(4(059(?!34)|150|201|561|562|533|556|97))|(5(0[1-4]|13|30066|341[0-1]|587[0-2]|6|8))|(6(27244|390|75[1-6]|799999998))).*"
        ];
        for (cardType, regexp) in cardTypesRegex {
            if let _ = ccn.range(of:regexp, options: .regularExpression) {
                return cardType
            }
        }
        return nil
    }

}

