//
//  LoginViewController.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 01.12.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController{
    private let model = AccountModel() // Needed for downloading Account
    
    // Spinner vars
    var vSpinner : UIView?
    private var spinnerStartTime: Date = Date()
    
    @IBOutlet weak var email_field: UITextField!
    @IBOutlet weak var password_field: UITextField!
    @IBOutlet var loginButton: UIButton?
    
    var openMainViewClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpDismissKeyboardOutsideTouch()
        
        model.delegate = self
        
        email_field.text = AccountController.email
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton? = nil){
        
        guard let email = email_field.text, email.isEmail else {
            return
        }
        AccountController.email = email
        AccountController.password_hash = nil
        AccountController.account = nil
        AccountController.saveDataToMemory()
        
        guard let password = password_field.text, !password.isEmpty else {
            return
        }
        AccountController.password_hash = password
        
        loadAccountFromServer()
    }
    
    func loadAccountFromServer(){
        if loginButton != nil { showSpinner(onView: loginButton!) }
        
        //Get version number
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unable to get app version"
        
        let param = ["ios_app_ver": appVersion, "email": AccountController.email!, "passhash": AccountController.password_hash!]
        model.downloadAccountData(parameters: param, url: URLServices.login)
    }
    
    @IBAction func cancelButtonPressed(){
        dismiss(animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == email_field{
            password_field.becomeFirstResponder()
        }
        if textField == password_field{
            loginButtonPressed()
        }
        return true
    }
}

extension LoginViewController {
    
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

extension LoginViewController: Downloadable{
    func didReceiveData(data param: Any?) {
        // The data model has been dowloaded at this point
        // Now, pass the data model to the Holidays table view controller
        DispatchQueue.main.sync{
            removeSpinner()
            
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
                if error.code == 2{
                    password_field.layer.borderWidth = 1
                    password_field.layer.cornerRadius = 5
                    password_field.layer.borderColor = UIColor.red.cgColor
                }
                return
            }
            
            AccountController.account = account
            AccountController.saveDataToMemory()
            
            dismiss(animated: true, completion: openMainViewClosure)
        }
    }
}
