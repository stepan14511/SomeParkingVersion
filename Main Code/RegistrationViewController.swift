//
//  RegistrationViewController.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 18.12.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation
import UIKit

class RegistrationViewController: UIViewController{
    private let model = AccountModel() // Needed for downloading Account
    
    @IBOutlet weak var surname_field: UITextField!
    @IBOutlet weak var name_field: UITextField!
    @IBOutlet weak var patronymic_field: UITextField!
    @IBOutlet weak var email_field: UITextField!
    @IBOutlet weak var phone_field: UITextField!
    @IBOutlet weak var password_field: UITextField!
    
    var openMainViewClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.delegate = self
    }
    
    @IBAction func registrationButtonPressed(_ sender: UIButton){
        let charset = CharacterSet.lowercaseLetters
        
        guard let surname = surname_field.text, !surname.isEmpty else {
            return
        }
        
        guard let name = name_field.text, !name.isEmpty else {
            return
        }
        
        var patronymic: String? = patronymic_field.text
        
        if patronymic?.rangeOfCharacter(from: charset) == nil {
            patronymic = nil
        }
        
        guard let email = email_field.text, !email.isEmpty else {
            return
        }
        guard let phone = phone_field.text, phone.count == 18 else {
            return
        }
        guard var password = password_field.text, !password.isEmpty else {
            return
        }
        AccountController.password_hash = password
        password = AccountController.password_hash!
        
        // Create request to server to register new user and then if success save it's data to memory and load main view
        registerAccountOnServer(surname, name, patronymic, email, phone, password)
    }
    
    func registerAccountOnServer(_ surname: String, _ name: String, _ patronymic: String?, _ email: String, _ phone: String, _ password_hash: String){
        //Get version number
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        var param =
            [
                "ios_app_ver": appVersion!,
                "surname": surname,
                "name": name,
                "email": email,
                "phone": phone,
                "passhash": password_hash
            ]
        if let patronymic_copy = patronymic{
            param["patronymic"] = patronymic_copy
        }
        model.downloadAccountData(parameters: param, url: URLServices.registration)
    }
    
    @IBAction func phoneFieldTextChanged(_ sender: UITextField){
        
        guard var text = sender.text, text.count > 3 else{
            sender.text = "+7 "
            return
        }
        text = text.applyPatternOnNumbers()
        if text.count > 18{
            text = String(text.prefix(18))
        }
        sender.text = text
        if text.count < 3{
            sender.text = "+7 "
        }
    }
    
    @IBAction func phoneFieldTextIsEmpty(_ sender: Any){
        if let phone = phone_field.text{
            if(phone.count <= 4){
                phone_field.text = nil
            }
        }
    }
    
    @IBAction func cancelButtonPressed(){
        dismiss(animated: true, completion: nil)
    }
}

extension RegistrationViewController: Downloadable{
    func didReceiveData(data param: Any?) {
        // The data model has been dowloaded at this point
        // Now, pass the data model to the Holidays table view controller
        DispatchQueue.main.sync{
            guard let data = param else{
                // Smthing strange, not server error
                email_field.text = "Not server error"
                return
            }
            
            guard let account = data as? Account else{
                guard let error = data as? ServerError else{
                    // This is literally impossible, but why not to leave it here)
                    email_field.text = "Not server error"
                    return
                }
                
                // Server error
                email_field.text = error.message
                return
            }
            
            AccountController.account = account
            AccountController.email = account.email
            AccountController.saveDataToMemory()
            
            dismiss(animated: true, completion: openMainViewClosure)
        }
    }
}
