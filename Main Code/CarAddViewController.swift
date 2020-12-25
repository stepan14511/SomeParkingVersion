//
//  CarAddViewController.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 20.12.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation
import UIKit

class CarAddViewController: UIViewController{
    let model = AccountModel()
    var vSpinner : UIView?
    
    var callbackClosure: (() -> Void)?
    var openLoginScreenClosure: (() -> Void)?
    var updateAccountClosure: (() -> Void)?
    @IBOutlet weak var doneButton: UIButton?
    @IBOutlet weak var platesTextField: UITextField?
    @IBOutlet weak var mainCardTextField: UITextField?
    @IBOutlet weak var additionalCardTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.delegate = self
        
        doneButton?.isEnabled = false
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any){
        doneButton?.isEnabled = false
        
        guard let email = AccountController.email,
              let passhash = AccountController.password_hash
        else{
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        
        guard let plates = platesTextField?.text, !plates.isEmpty,
           let mainCard = mainCardTextField?.text, !mainCard.isEmpty,
           let additionalCard = additionalCardTextField?.text, !additionalCard.isEmpty
        else{
            doneButton?.isEnabled = false
            return
        }
        
        showSpinner(onView: self.view)
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unable to get app version"
        
        let param = [
            "ios_app_ver": appVersion,
            "email": email,
            "passhash": passhash,
            "plates": plates,
            "main_card": mainCard,
            "additional_card": additionalCard
        ]
        model.downloadAccountData(parameters: param, url: URLServices.addCar)
        
    }
    
    @IBAction func checkForEnablingDoneButton(_ sender: Any){
        guard let _ = platesTextField,
              let _ = mainCardTextField,
              let _ = additionalCardTextField
        else{
            doneButton?.isEnabled = false
            return
        }
        
        if let plates = platesTextField?.text, !plates.isEmpty,
           let mainCard = mainCardTextField?.text, !mainCard.isEmpty,
           let additionalCard = additionalCardTextField?.text, !additionalCard.isEmpty{
            doneButton?.isEnabled = true
        }
        else{
            doneButton?.isEnabled = false
        }
        
        return
    }
}

extension CarAddViewController {
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        self.vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            self.vSpinner?.removeFromSuperview()
            self.vSpinner = nil
        }
    }
}

extension CarAddViewController: Downloadable{
    func didReceiveData(data param: Any?) {
        // The data model has been dowloaded at this point
        // Now, pass the data model to the Holidays table view controller
        DispatchQueue.main.sync{
            guard let data = param else{
                // Smthing strange, not server error
                return
            }
            
            guard let account = data as? ServerSuccess else{
                guard let error = data as? ServerError else{
                    return
                }
                
                // Server error
                if error.code == 2{
                    dismiss(animated: true, completion: openLoginScreenClosure)
                    return
                }
                return
            }
            
            removeSpinner()
            dismiss(animated: true, completion: updateAccountClosure)
        }
    }
}
