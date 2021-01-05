//
//  AccountController.swift
//  SideMenu
//
//  Created by Stepan Kuznetsov on 15.12.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

protocol AccountUser: class {
    func accountDownloaded(serverError: ServerError?)
}

class AccountController{
    static private var _password_hash: String?
    
    static let account_key: String = "account_data"
    static let email_key: String = "email"
    static let password_hash_key: String = "password_hash"
    
    static var email: String?
    static var account: Account?
    static var password_hash: String?{
        set{ // Just push raw password, it will be hashed itself
            if let pass = newValue{
                _password_hash = MD5(string: pass)
            }
            else{
                _password_hash = nil
            }
            
        }
        get{ return _password_hash }
    }
    
    static func saveDataToMemory(){
        // Save email
        guard let email = self.email else{
            self.email = nil
            self.password_hash = nil
            self.account = nil
            UserDefaults.standard.removeObject(forKey: email_key)
            UserDefaults.standard.removeObject(forKey: password_hash_key)
            UserDefaults.standard.removeObject(forKey: account_key)
            return
        }
        UserDefaults.standard.set(email, forKey:email_key)
        
        // Save password HASH
        guard let password = self.password_hash else{
            self.password_hash = nil
            self.account = nil
            UserDefaults.standard.removeObject(forKey: password_hash_key)
            UserDefaults.standard.removeObject(forKey: account_key)
            return
        }
        UserDefaults.standard.set(password, forKey:password_hash_key)
        
        // Save account
        guard let account = self.account else{
            self.account = nil
            UserDefaults.standard.removeObject(forKey: account_key)
            return
        }
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(account) {
            UserDefaults.standard.set(encoded, forKey: account_key)
        }
        else{
            self.account = nil
            UserDefaults.standard.removeObject(forKey: account_key)
        }
        
        UserDefaults.standard.synchronize()
    }
    
    // Loads all data from memory.
    // Returns TRUE if there are all email, pass and account there
    // Returns FALSE if only email and pass is there
    // Returns NIL if either email or pass is missing
    static func loadDataFromMemory() -> Bool?{
        // Get email
        guard let email = UserDefaults.standard.string(forKey:email_key) else{
            self.email = nil
            self.password_hash = nil
            self.account = nil
            return nil
        }
        self.email = email
        
        // Get password hash
        guard let password_hash = UserDefaults.standard.string(forKey:password_hash_key) else{
            self.password_hash = nil
            self.account = nil
            return nil
        }
        self._password_hash = password_hash
        
        // Get account
        guard let data = UserDefaults.standard.value(forKey:account_key) as? Data else{
            account = nil
            return false
        }
        
        let decoder = JSONDecoder()
        guard let decoded = try? decoder.decode(Account.self, from: data) else {
            account = nil
            return false
        }
        self.account = decoded
        
        return true
    }
    
    static func getCarById(id: Int) -> Car?{
        guard let cars = AccountController.account?.cars else{
            return nil
        }
        
        for car in cars{
            if car.id == id{
                return car
            }
        }
        return nil
    }
    
    static private func MD5(string: String) -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
        messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        
        // Convert to string and return
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}
