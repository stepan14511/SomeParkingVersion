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
    
    @IBOutlet weak var email_field: UITextField!
    @IBOutlet weak var password_field: UITextField!
    
    override func viewDidLoad() {
        model.delegate = self
        
        print(AccountController.email ?? "nil")
        print(AccountController.password_hash ?? "nil")
        print(AccountController.account ?? "nil")
        email_field.text = AccountController.email
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton){
        guard let email = email_field.text, !email.isEmpty else {
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
    
    @IBAction func registrationButtonPressed(_ sender: UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "registration") as! RegistrationViewController
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    func loadAccountFromServer(){
        //Get version number
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        let param = ["ios_app_ver": appVersion!, "email": AccountController.email!, "passhash": AccountController.password_hash!]
        model.downloadAccountData(parameters: param, url: URLServices.login)
    }
}

extension LoginViewController: Downloadable{
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
            AccountController.saveDataToMemory()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondViewController = storyboard.instantiateViewController(withIdentifier: "main") as! MainViewController
            secondViewController.modalPresentationStyle = .fullScreen
            secondViewController.modalTransitionStyle = .flipHorizontal
            self.present(secondViewController, animated: true, completion: nil)
        }
    }
}