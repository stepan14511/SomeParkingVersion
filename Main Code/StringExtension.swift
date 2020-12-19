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

extension String {
    var digits: String {
        return String(filter(("0"..."9").contains))
    }
    
    func applyPatternOnNumbers(pattern: String = kPhonePattern, replacmentCharacter: Character = kPhonePatternReplaceChar) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(encodedOffset: index)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
    
    var isInt: Bool {
        return Int(self) != nil
    }
}
