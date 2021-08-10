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
    var isSkippable: Bool = false
    
    @IBOutlet weak var doneButton: UIButton?
    @IBOutlet weak var cancelButton: UIButton?
    @IBOutlet weak var platesTextField: UITextField?
    @IBOutlet weak var mainCardTextField: UITextField?
    @IBOutlet weak var additionalCardTextField: UITextField?
    @IBOutlet var movingCardObjects: [UIView]?
    var lastKeyboardHeight: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpDismissKeyboardOutsideTouch()
        setupMovingCard()
        model.delegate = self
        
        doneButton?.isEnabled = false
        
        cancelButton?.setTitle(isSkippable ? "Пропустить" : "Отменить", for: .normal)
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
        platesTextField?.text = plates
        
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
              let _ = mainCardTextField,
              let _ = additionalCardTextField
        else{
            doneButton?.isEnabled = false
            return
        }
        
        if let plates = platesTextField?.text, plates.isLegalPlates,
           let mainCard = mainCardTextField?.text, !mainCard.isEmpty,
           let additionalCard = additionalCardTextField?.text, !additionalCard.isEmpty{
            doneButton?.isEnabled = true
        }
        else{
            doneButton?.isEnabled = false
        }
        
        return
    }
    
    func successfulAdding(car_id: Int){
        let storyboard = UIStoryboard(name: "Tariffs", bundle: nil)
        guard let newViewController = storyboard.instantiateViewController(withIdentifier: "car_lot") as? CarLotPickerViewController else { dismiss(animated: true, completion: successCallBackClosure)
            return
        }
        newViewController.openLoginScreenClosure = {self.dismiss(animated: true, completion: self.openLoginScreenClosure)}
        newViewController.updateViewAfterDataChangeClosure = successCallBackClosure
        newViewController.car_id = car_id
        newViewController.isSkippable = true
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
}

// Moving card to be above keyboard
extension CarAddViewController{
    func setupMovingCard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if lastKeyboardHeight == nil{
                lastKeyboardHeight = keyboardSize.height - 20
                for object in movingCardObjects ?? []{
                    object.frame.origin.y -= lastKeyboardHeight ?? 0
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        for object in movingCardObjects ?? []{
            object.frame.origin.y += lastKeyboardHeight ?? 0
        }
        lastKeyboardHeight = nil
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
    
    @IBAction func additionalCardTextFieldChanging(_ sender: Any){
        additionalCardTextField?.layer.borderWidth = 0
        
        var additionalCard = additionalCardTextField?.text ?? ""
        
        // Apply text formatting.
        additionalCard = additionalCard.applyPatternOnNumbers(pattern: kCardNumbersPattern, replacementCharacter: kCardNumbersPatternReplaceChar)
        if additionalCard.count > 6 { additionalCard = String(additionalCard.prefix(6)) }
        additionalCardTextField?.text = additionalCard
    }
    
    @IBAction func additionalCardTextFieldEditingEnded(_ sender: Any){
        if additionalCardTextField?.text?.count ?? 0 < 1{
            additionalCardTextField?.layer.borderWidth = 1
            additionalCardTextField?.layer.cornerRadius = 5
            additionalCardTextField?.layer.borderColor = UIColor.red.cgColor
        }
    }
}

extension CarAddViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == platesTextField, platesTextField != nil{
            mainCardTextField?.becomeFirstResponder()
        }
        if textField == mainCardTextField, mainCardTextField != nil{
            additionalCardTextField?.becomeFirstResponder()
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
            
            guard let account = data as? Account else{
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
            
            AccountController.account = account
            AccountController.saveDataToMemory()
            
            let plates = platesTextField?.text
            
            removeSpinner()
            if let car = AccountController.getCarByPlates(plates: plates){
                successfulAdding(car_id: car.id)
            }
            else{
                dismiss(animated: true, completion: successCallBackClosure)
            }
        }
    }
}
