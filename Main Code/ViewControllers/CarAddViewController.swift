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
    
    var openLoginScreenClosure: (() -> Void)?
    var successCallBackClosure: (() -> Void)?
    
    @IBOutlet weak var doneButton: UIButton?
    @IBOutlet weak var platesTextField: UITextField?
    @IBOutlet weak var mainCardTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpDismissKeyboardOutsideTouch()
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
        
        guard var plates = platesTextField?.text, plates.isLegalPlates,
           let mainCard = mainCardTextField?.text, !mainCard.isEmpty
        else{
            doneButton?.isEnabled = false
            return
        }
        
        plates = plates.removingWhitespaces()
        plates = plates.lowercased()
        plates = plates.translatePlatesToRus()
        
        showSpinner(onView: self.view)
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unable to get app version"
        
        let param = [
            "ios_app_ver": appVersion,
            "email": email,
            "passhash": passhash,
            "plates": plates,
            "main_card": mainCard
        ]
        model.downloadAccountData(parameters: param, url: URLServices.addCar)
        
    }
    
    @IBAction func checkForEnablingDoneButton(_ sender: Any){
        guard let _ = platesTextField,
              let _ = mainCardTextField
        else{
            doneButton?.isEnabled = false
            return
        }
        
        if let plates = platesTextField?.text, plates.isLegalPlates,
           let mainCard = mainCardTextField?.text, !mainCard.isEmpty{
            doneButton?.isEnabled = true
        }
        else{
            doneButton?.isEnabled = false
        }
        
        return
    }
}

// Reaction to user input
extension CarAddViewController{
    @IBAction func platesTextFieldChanging(_ sender: Any){
        platesTextField?.layer.borderWidth = 0
        
        guard var text = platesTextField?.text else{
            return
        }
        if text.count > 9{
            text = String(text.prefix(9))
        }
        
        platesTextField?.text = text
    }
    
    @IBAction func platesTextFieldEditingEnded(_ sender: Any){
        guard let plates = platesTextField?.text,
              plates.isLegalPlates else{
            
            platesTextField?.layer.borderWidth = 1
            platesTextField?.layer.cornerRadius = 5
            platesTextField?.layer.borderColor = UIColor.red.cgColor
            return
        }
    }
    
    @IBAction func mainCardTextFieldChanging(_ sender: Any){
        mainCardTextField?.layer.borderWidth = 0
        
        var mainCard = mainCardTextField?.text ?? ""
        
        // Apply text formatting.
        mainCard = mainCard.applyPatternOnNumbers(pattern: kCardNumbersPattern, replacementCharacter: kCardNumbersPatternReplaceChar)
        if mainCard.count > 6 { mainCard = String(mainCard.prefix(6)) }
        mainCardTextField?.text = mainCard
    }
    
    @IBAction func mainCardTextFieldEditingEnded(_ sender: Any){
        if mainCardTextField?.text?.count ?? 0 < 1{
            mainCardTextField?.layer.borderWidth = 1
            mainCardTextField?.layer.cornerRadius = 5
            mainCardTextField?.layer.borderColor = UIColor.red.cgColor
        }
    }
}

extension CarAddViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == platesTextField, platesTextField != nil{
            mainCardTextField?.becomeFirstResponder()
        }
        return true
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
            
            guard let _ = data as? ServerSuccess else{
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
            dismiss(animated: true, completion: successCallBackClosure)
        }
    }
}
