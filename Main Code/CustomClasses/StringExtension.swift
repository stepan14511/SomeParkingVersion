//
//  StringExtension.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 18.12.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation

let kPhonePattern = "+# (###) ###-##-##"
let kPhonePatternReplaceChar: Character = "#"

let kCardNumbersPattern = "######"
let kCardNumbersPatternReplaceChar: Character = "#"

extension String {
    var digits: String {
        return String(filter(("0"..."9").contains))
    }
    
    // Это страшная функция, но она работает и я счастлив
    func applyPatternOnNumbers(pattern: String = kPhonePattern, replacementCharacter: Character = kPhonePatternReplaceChar, numbersRE: String = "[^0-9]") -> String {
        var pureNumber = self.replacingOccurrences( of: numbersRE, with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(encodedOffset: index)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
    
    var isInt: Bool {
        return Int(self) != nil
    }
    
    var isValidName: Bool{
        let regex = try! NSRegularExpression(pattern: "^[А-ЯЁA-Z \\-]{2,}$", options: .caseInsensitive)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
    
    var isValidPassword: Bool{
        let regex = try! NSRegularExpression(pattern: "^(?=.*[A-Z])(?=.*\\d)[A-Z\\d@$!%*#?&]{8,}$", options: .caseInsensitive)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
    
    var isEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    var isLegalPlates: Bool {
        let plates = self.removingWhitespaces()
        let regex = try! NSRegularExpression(pattern: "^[АВЕКМНОРСТУХABEKMHOPCTYX]{1}\\d{3}(?<!000)[АВЕКМНОРСТУХABEKMHOPCTYX]{2}\\d{2,3}(?<!000|00|0\\d\\d)$", options: .caseInsensitive)
        let range = NSRange(location: 0, length: plates.utf16.count)
        return regex.firstMatch(in: plates, options: [], range: range) != nil
    }
    
    func translatePlatesToRus() -> String {
        let engChars = ["a", "b", "e", "k", "m", "h", "o", "p", "c", "t", "y", "x"]
        let rusChars = ["а", "в", "е", "к", "м", "н", "о", "р", "с", "т", "у", "х"]
        var result: String = ""
        for character in self{
            if let index = engChars.firstIndex(of: String(character)){
                result += rusChars[index]
                continue
            }
            result += String(character)
        }
        return result
    }
    
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    // For data hashing
    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256()
        }
        return ""
    }
}

