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
    
    // Spinner vars
    var vSpinner : UIView?
    private var spinnerStartTime: Date = Date()
    
    @IBOutlet weak var surname_field: UITextField!
    @IBOutlet weak var name_field: UITextField!
    @IBOutlet weak var patronymic_field: UITextField!
    @IBOutlet weak var email_field: UITextField!
    @IBOutlet weak var phone_field: UITextField!
    @IBOutlet weak var password_field: UITextField!
    @IBOutlet weak var passwordEye: UIButton?
    @IBOutlet weak var errorLabel: UILabel?
    
    var openMainViewClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setUpDismissKeyboardOutsideTouch()
        model.delegate = self
        
        errorLabel?.isHidden = true
    }
    
    @IBAction func registrationButtonPressed(_ sender: UIButton?){
        let charset = CharacterSet.lowercaseLetters
        
        guard let surname = surname_field.text, surname.isValidName else {
            return
        }
        
        guard let name = name_field.text, name.isValidName else {
            return
        }
        
        var patronymic: String? = patronymic_field.text
        
        if patronymic?.rangeOfCharacter(from: charset) == nil {
            patronymic = nil
        }
        
        guard let email = email_field.text, email.isEmail else {
            return
        }
        guard let phone = phone_field.text, phone.count == 18 else {
            return
        }
        guard var password = password_field.text, password.isValidPassword else {
            return
        }
        AccountController.password_hash = password
        password = AccountController.password_hash!
        
        // Create request to server to register new user and then if success save it's data to memory and load main view
        registerAccountOnServer(surname, name, patronymic, email, phone, password)
    }
    
    func registerAccountOnServer(_ surname: String, _ name: String, _ patronymic: String?, _ email: String, _ phone: String, _ password_hash: String){
        
        errorLabel?.isHidden = true
        showSpinner(onView: self.view)
        
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
    
    @IBAction func cancelButtonPressed(){
        dismiss(animated: true, completion: nil)
    }
}

// For UI changes during input
extension RegistrationViewController{
    
    @IBAction func surnameTextFieldChanging(_ sender: Any){
        surname_field.layer.borderWidth = 0
    }
    
    @IBAction func surnameTextFieldEditingEnded(_ sender: Any){
        guard let surname = surname_field?.text,
              surname.isValidName else{
            
            surname_field.layer.borderWidth = 1
            surname_field.layer.cornerRadius = 5
            surname_field.layer.borderColor = UIColor.red.cgColor
            return
        }
    }
    
    @IBAction func nameTextFieldChanging(_ sender: Any){
        name_field.layer.borderWidth = 0
    }
    
    @IBAction func nameTextFieldEditingEnded(_ sender: Any){
        guard let name = name_field?.text,
              name.isValidName else{
            
            name_field.layer.borderWidth = 1
            name_field.layer.cornerRadius = 5
            name_field.layer.borderColor = UIColor.red.cgColor
            return
        }
    }
    
    @IBAction func emailTextFieldChanging(_ sender: Any){
        email_field.layer.borderWidth = 0
    }
    
    @IBAction func emailTextFieldEditingEnded(_ sender: Any){
        guard let email = email_field?.text,
              email.isEmail else{
            
            email_field.layer.borderWidth = 1
            email_field.layer.cornerRadius = 5
            email_field.layer.borderColor = UIColor.red.cgColor
            return
        }
    }
    
    @IBAction func phoneTextFieldChanging(_ sender: UITextField){
        phone_field.layer.borderWidth = 0
        
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
    
    @IBAction func phoneTextFieldEditingEnded(_ sender: Any){
        if let phone = phone_field.text{
            if(phone.count <= 4){
                phone_field.text = nil
            }
        }
        
        guard let phone = phone_field.text,
           phone.count == 18 else{
            phone_field.layer.borderWidth = 1
            phone_field.layer.cornerRadius = 5
            phone_field.layer.borderColor = UIColor.red.cgColor
            return
        }
    }
    
    
    @IBAction func passwordTextFieldChanging(_ sender: Any){
        password_field.layer.borderWidth = 0
    }
    
    @IBAction func passwordTextFieldEditingEnded(_ sender: Any){
        guard let password = password_field.text,
              password.isValidPassword
              else {
            
            password_field.layer.borderWidth = 1
            password_field.layer.cornerRadius = 5
            password_field.layer.borderColor = UIColor.red.cgColor
            return
        }
    }
    
    @IBAction func passwordEyePressed(_ sender: Any){
        password_field.becomeFirstResponder()
        password_field.isSecureTextEntry.toggle()

        //  IDK, some smart staff from stackoverflow (https://stackoverflow.com/a/48115361/8074254)
        if let existingText = password_field.text, password_field.isSecureTextEntry {
            /* When toggling to secure text, all text will be purged if the user
             continues typing unless we intervene. This is prevented by first
             deleting the existing text and then recovering the original text. */
            password_field.deleteBackward()

            if let textRange = password_field.textRange(from: password_field.beginningOfDocument, to: password_field.endOfDocument) {
                password_field.replace(textRange, withText: existingText)
            }
        }

        /* Reset the selected text range since the cursor can end up in the wrong
         position after a toggle because the text might vary in width */
        if let existingSelectedTextRange = password_field.selectedTextRange {
            password_field.selectedTextRange = nil
            password_field.selectedTextRange = existingSelectedTextRange
        }
        
        if passwordEye != nil{
            if password_field.isSecureTextEntry{
                if #available(iOS 13.0, *) {
                    passwordEye?.imageView?.image = UIImage(systemName: "eye.splash")
                } else {
                    // TODO: Fallback on earlier versions
                }
            }
            else{
                if #available(iOS 13.0, *) {
                    passwordEye?.imageView?.image = UIImage(systemName: "eye")
                } else {
                    // TODO: Fallback on earlier versions
                }
            }
        }
    }
}

extension RegistrationViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == surname_field{
            name_field.becomeFirstResponder()
        }
        if textField == name_field{
            patronymic_field.becomeFirstResponder()
        }
        if textField == patronymic_field{
            email_field.becomeFirstResponder()
        }
        if textField == email_field{
            phone_field.becomeFirstResponder()
        }
        if textField == phone_field{
            password_field.becomeFirstResponder()
        }
        if textField == password_field{
            registrationButtonPressed(nil)
        }
        return true
    }
}

extension RegistrationViewController {
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
            self.spinnerStartTime = Date()
        }
        
        self.vSpinner = spinnerView
    }
    
    func removeSpinner() {
        let timeNow = Date()
        let secondMore = timeNow.addingTimeInterval(1.0)
        let interval = DateInterval(start: spinnerStartTime, end: timeNow)
        let second = DateInterval(start: timeNow, end: secondMore)
        
        if interval >= second{
            DispatchQueue.main.async {
                self.vSpinner?.removeFromSuperview()
                self.vSpinner = nil
            }
        }
        else{
            let difference: Double = Double(second.compare(interval).rawValue)
            DispatchQueue.main.asyncAfter(deadline: .now() + difference) {
                self.vSpinner?.removeFromSuperview()
                self.vSpinner = nil
            }
        }
    }
}

extension RegistrationViewController: Downloadable{
    func didReceiveData(data param: Any?) {
        // The data model has been dowloaded at this point
        // Now, pass the data model to the Holidays table view controller
        DispatchQueue.main.sync{
            guard let data = param else{
                // Smthing strange, not server error
                //email_field.text = "Not server error"
                return
            }
            
            guard let account = data as? Account else{
                guard let error = data as? ServerError else{
                    // This is literally impossible, but why not to leave it here)
                    //email_field.text = "Not server error"
                    return
                }
                
                // Server error
                //email_field.text = error.message
                
                let boldText = error.message
                let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 11)]
                let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)

                let normalText = error.subMessage
                let normalString = NSMutableAttributedString(string: " " + (normalText ?? ""))

                attributedString.append(normalString)
                errorLabel?.attributedText = attributedString
                errorLabel?.isHidden = false
                
                if error.code == 3{ // Email is already used
                    email_field.layer.borderWidth = 1
                    email_field.layer.cornerRadius = 5
                    email_field.layer.borderColor = UIColor.red.cgColor
                }
                if error.code == 4{ // Phone is already used
                    phone_field.layer.borderWidth = 1
                    phone_field.layer.cornerRadius = 5
                    phone_field.layer.borderColor = UIColor.red.cgColor
                }
                removeSpinner()
                return
            }
            
            AccountController.account = account
            AccountController.email = account.email
            AccountController.saveDataToMemory()
            
            dismiss(animated: true, completion: openMainViewClosure)
        }
    }
}
