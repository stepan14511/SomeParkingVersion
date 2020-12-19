//
//  PopolnitViewController.swift
//  Example
//
//  Created by Stepan Kuznetsov on 30.10.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//
import UIKit

class PopolnitViewController: UIViewController{
    private let model = AccountModel() // Needed for downloading Account
    
    @IBOutlet weak var changePaymentSystemView: UIView?
    @IBOutlet weak var paymentAmountTextField: UITextField?
    
    var callbackClosure: (() -> Void)?
    
    override func viewDidLoad() {
        model.delegate = self
        
        // Setting changePaymentSystem tap recogniser
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.changePaymentSystemPressed))
        self.changePaymentSystemView!.addGestureRecognizer(gesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        callbackClosure?()
    }
    
    @objc func changePaymentSystemPressed(sender : UITapGestureRecognizer) {
        //TODO: Open new view with change of payment system
    }
    
    @IBAction func pay(_ sender: UIButton){
        guard let paymentAmount = paymentAmountTextField?.text,
              paymentAmount.isInt,
              let email = AccountController.email,
              let passhash = AccountController.password_hash else{
            return
        }
        
        //Get version number
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else{
            return
        }
        
        let param =
            [
                "ios_app_ver": appVersion,
                "email": email,
                "passhash": passhash,
                "payment_amount": paymentAmount
            ]
        
        model.downloadAccountData(parameters: param, url: URLServices.payment)
    }
    
    @IBAction func Exit(){
        dismiss(animated: true, completion: nil)
    }
    
}

extension PopolnitViewController: Downloadable{
    func didReceiveData(data param: Any?) {
        // The data model has been dowloaded at this point
        // Now, pass the data model to the Holidays table view controller
        DispatchQueue.main.sync{
            guard let data = param else{
                // Smthing strange, not server error
                return
            }
            
            guard let account = data as? Account else{
                guard let error = data as? ServerError else{
                    // This is literally impossible, but why not to leave it here)
                    return
                }
                
                // Server error
                if(error.code == 2){
                    AccountController.password_hash = nil
                    AccountController.account = nil
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let secondViewController = storyboard.instantiateViewController(withIdentifier: "login") as! LoginViewController
                    secondViewController.modalPresentationStyle = .fullScreen
                    secondViewController.modalTransitionStyle = .flipHorizontal
                    self.present(secondViewController, animated: true, completion: nil)
                }
                return
            }
            
            AccountController.account = account
            AccountController.saveDataToMemory()
            
            dismiss(animated: true, completion: nil)
        }
    }
}
