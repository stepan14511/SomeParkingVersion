//
//  AccountController.swift
//  SideMenu
//
//  Created by Stepan Kuznetsov on 15.12.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation
import CommonCrypto

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
                _password_hash = pass.sha256()
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
    
    static func getCarById(id: Int?) -> Car?{
        guard let id = id else{ return nil }
        
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
    
    static func getCarByPlates(plates: String?) -> Car?{
        guard let plates = plates else{ return nil }
        
        guard let cars = AccountController.account?.cars else{
            return nil
        }
        
        for car in cars{
            if car.plates == plates{
                return car
            }
        }
        return nil
    }
}
