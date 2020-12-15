//
//  LoginViewController.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 01.12.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation
import UIKit
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

class LoginViewController: UIViewController{
    let model = AccountModel() // Needed for downloading Account
    
    @IBOutlet weak var email_field: UITextField!
    @IBOutlet weak var password_field: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton){
        //Get version number
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
        let param = ["ios_app_ver": appVersion!, "email": email_field.text!, "passhash": MD5(string: password_field.text!)]
        model.downloadAccountData(parameters: param, url: URLServices.login)
    }
    
    func MD5(string: String) -> String {
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

extension LoginViewController: Downloadable{
    func didReceiveData(data: Any) {
        // The data model has been dowloaded at this point
        // Now, pass the data model to the Holidays table view controller
        DispatchQueue.main.sync {
            let model: Account = (data as! Account)
            self.email_field.text = model.full_name
             //let storyboard = UIStoryboard(name: "Main", bundle: nil)
             //let secondViewController = storyboard.instantiateViewController(withIdentifier: "holidaysID") as! HolidaysViewController
             //self.present(secondViewController, animated: true, completion: nil)
         }
    }
}
