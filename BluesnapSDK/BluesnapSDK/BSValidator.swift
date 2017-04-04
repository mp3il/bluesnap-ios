//
//  BSValidator.swift
//  BluesnapSDK
//
//  Created by Shevie Chen on 04/04/2017.
//  Copyright © 2017 Bluesnap. All rights reserved.
//

import Foundation

extension String {
    
    var isValidMonth : Bool {
        
        let validMonths = ["01","02","03","04","05","06","07","08","09","10","11","12"]
        return validMonths.contains(self)
    }
    
    var isValidEmail : Bool {
        // TBD
        return characters.count > 3
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
    
    var formatExp : String {
        
        var result : String
        if characters.count < 2 {
            result = self
        } else {
            let idx = index(startIndex, offsetBy: 2)
            result = substring(with: startIndex..<idx) + "/"
            result += substring(with: idx..<endIndex)
        }
        return result
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
}

