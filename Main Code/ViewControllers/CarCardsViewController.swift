//
//  CarCardsViewController.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 03.01.2021.
//  Copyright © 2021 jonkykong. All rights reserved.
//

import Foundation
import UIKit

class CarCardsViewController: UITableViewController{
    let model = AccountModel()
    var vSpinner : UIView?
    
    var car_id: Int?
    var openLoginScreenClosure: (() -> Void)?
    var updateUIClosure: (() -> Void)?
    
    @IBOutlet var mainCardsCells: [UITableViewCell]?
    let mainCard1TextField = UITextField()
    let mainCard2TextField = UITextField()
    @IBOutlet var doneButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.delegate = self
        
        guard let _ = AccountController.getCarById(id: car_id) else{
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        
        setupCells()
        updateRowsText()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                mainCard1TextField.becomeFirstResponder()
            case 1:
                mainCard2TextField.becomeFirstResponder()
            default:
                return
            }
        }
    }
    
    func setupCells(){
        guard let mainCards = mainCardsCells,
              mainCards.count == 2
        else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        let textFieldWidth = (UIScreen.main.bounds.width) * 0.5
        
        mainCard1TextField.frame = CGRect(x: 0, y: 480, width: textFieldWidth, height: 40)
        mainCard1TextField.placeholder = "обязательно"
        mainCard1TextField.layer.cornerRadius = 10.0
        mainCard1TextField.textAlignment = .right
        mainCard1TextField.keyboardType = .numberPad
        mainCard1TextField.addTarget(self, action: #selector(cardsTextFieldChanged), for: .editingChanged)
        mainCard1TextField.addTarget(self, action: #selector(cardsTextFieldChanged), for: .editingDidBegin)
        mainCards[0].accessoryView = mainCard1TextField
        
        mainCard2TextField.frame = CGRect(x: 0, y: 480, width: textFieldWidth, height: 40)
        mainCard2TextField.placeholder = "необязательно"
        mainCard2TextField.layer.cornerRadius = 10.0
        mainCard2TextField.textAlignment = .right
        mainCard2TextField.keyboardType = .numberPad
        mainCard2TextField.addTarget(self, action: #selector(cardsTextFieldChanged), for: .editingChanged)
        mainCard2TextField.addTarget(self, action: #selector(cardsTextFieldChanged), for: .editingDidBegin)
        mainCards[1].accessoryView = mainCard2TextField
    }
    
    func updateRowsText(){
        guard let car = AccountController.getCarById(id: car_id) else{
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        
        mainCard1TextField.text = String(car.main_card)
        mainCard2TextField.text = car.second_main_card != nil ? String(car.second_main_card!) : nil
        if let mainCards = mainCardsCells,
           mainCards.count == 2{
            if car.parking_lot_type == 3{ // Two card lot type
                mainCards[1].isUserInteractionEnabled = true
                mainCards[1].textLabel?.textColor = .black
            }
            else{
                mainCards[1].isUserInteractionEnabled = false
                mainCards[1].textLabel?.textColor = .lightGray
            }
        }
        
        cardsTextFieldChanged()
    }
    
    @IBAction func cancelButtonPressed(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(){
        guard let email = AccountController.email,
              let passhash = AccountController.password_hash,
              let car_id = AccountController.getCarById(id: car_id)?.id else{
            return
        }
        
        // Get data from text fields
        let mainCard1 = Int(mainCard1TextField.text ?? "")
        let mainCard2 = Int(mainCard2TextField.text ?? "")
        
        guard mainCard1 != nil else{ return }
        
        showSpinner(onView: self.view)
        
        // Send data to server
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unable to get app version"
        
        var param =
                [
                    "ios_app_ver": appVersion,
                    "email": email,
                    "passhash": passhash,
                    "car_id": car_id,
                    "main_card_1": mainCard1!
                ] as [String : Any]
        
        if mainCard2 != nil{
            param["main_card_2"] = mainCard2!
        }
        
        model.downloadAccountData(parameters: param, url: URLServices.updateCards)
    }
    
    @objc func cardsTextFieldChanged(){
        // Get all texts
        guard let car = AccountController.getCarById(id: car_id) else {
            doneButton?.isEnabled = false
            return
        }
        var mainCard1 = mainCard1TextField.text ?? ""
        var mainCard2 = mainCard2TextField.text ?? ""
        
        // Apply text formatting.
        mainCard1 = mainCard1.applyPatternOnNumbers(pattern: kCardNumbersPattern, replacementCharacter: kCardNumbersPatternReplaceChar)
        if mainCard1.count > 6 { mainCard1 = String(mainCard1.prefix(6)) }
        mainCard1TextField.text = mainCard1
        mainCard2 = mainCard2.applyPatternOnNumbers(pattern: kCardNumbersPattern, replacementCharacter: kCardNumbersPatternReplaceChar)
        if mainCard2.count > 6 { mainCard2 = String(mainCard2.prefix(6)) }
        mainCard2TextField.text = mainCard2
        
        // Check for done button enabling possibility
        // Check for required fields
        guard !mainCard1.isEmpty, mainCard1.isInt else{
            doneButton?.isEnabled = false
            return
        }
        
        doneButton?.isEnabled = false
        // Check if a main field is changed
        if mainCard1 != String(car.main_card) ||
            mainCard2 != (car.second_main_card != nil ? String(car.second_main_card!) : "")
            {
            doneButton?.isEnabled = true
            return
        }
    }
}

extension CarCardsViewController {
    
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

extension CarCardsViewController: Downloadable{
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
            removeSpinner()
            dismiss(animated: true, completion: updateUIClosure)
        }
    }
}
