//
//  CarTariffChangeViewControler.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 10.01.2021.
//  Copyright © 2021 jonkykong. All rights reserved.
//

import Foundation
import UIKit

class CarTariffChangeViewController: UITableViewController{
    var model = AccountModel()
    
    var car: Car?
    var openLoginScreenClosure: (() -> Void)?
    var updateUIClosure: (() -> Void)?
    
    @IBOutlet var doneButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ = car else{
            dismiss(animated: true, completion: nil)
            return
        }
        
        setupCells()
        updateRowsText()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0{
            if indexPath.row == 2{ //TODO: For the case of owner show stuff, bla bla
                return
            }
        }
    }
    
    func setupCells(){
        /*
        guard let mainCards = mainCardsCells,
              mainCards.count == 2,
              let additionalCards = additionalCardsCells,
              additionalCards.count == 5
        else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        let textFieldWidth = (UIScreen.main.bounds.width) * 0.5
        
        mainCard1TextField.frame = CGRect(x: 0, y: 480, width: textFieldWidth, height: 40)
        mainCard1TextField.placeholder = "обязательно"
        mainCard1TextField.layer.cornerRadius = 10.0
        mainCard1TextField.textAlignment = .right
        mainCard1TextField.addTarget(self, action: #selector(cardsTextFieldChanged), for: .editingChanged)
        mainCard1TextField.addTarget(self, action: #selector(cardsTextFieldChanged), for: .editingDidBegin)
        mainCards[0].accessoryView = mainCard1TextField
        
        mainCard2TextField.frame = CGRect(x: 0, y: 480, width: textFieldWidth, height: 40)
        mainCard2TextField.placeholder = "необязательно"
        mainCard2TextField.layer.cornerRadius = 10.0
        mainCard2TextField.textAlignment = .right
        mainCard2TextField.addTarget(self, action: #selector(cardsTextFieldChanged), for: .editingChanged)
        mainCard2TextField.addTarget(self, action: #selector(cardsTextFieldChanged), for: .editingDidBegin)
        mainCards[1].accessoryView = mainCard2TextField
        
        for (index, textField) in additionalCardsTextFields.enumerated() {
            
            textField.frame = CGRect(x: 0, y: 480, width: textFieldWidth, height: 40)
            textField.placeholder = index == 0 ? "обязательно" : "необязательно"
            textField.layer.cornerRadius = 10.0
            textField.textAlignment = .right
            textField.addTarget(self, action: #selector(cardsTextFieldChanged), for: .editingChanged)
            textField.addTarget(self, action: #selector(cardsTextFieldChanged), for: .editingDidBegin)
            additionalCards[index].accessoryView = textField
        }
        */
    }
    
    func updateRowsText(){
        /*
        guard let car = car else{
            dismiss(animated: true, completion: nil)
            return
        }
        
        mainCard1TextField.text = String(car.main_card)
        mainCard2TextField.text = car.second_main_card != nil ? String(car.second_main_card!) : nil
        if let mainCards = mainCardsCells,
           mainCards.count == 2{
            if car.parking_lot_type == 1{ // Two card lot type
                mainCards[1].isUserInteractionEnabled = true
                mainCards[1].textLabel?.textColor = .black
            }
            else{
                mainCards[1].isUserInteractionEnabled = false
                mainCards[1].textLabel?.textColor = .lightGray
            }
        }
        
        for (index, card) in car.additional_cards.enumerated(){
            if index >= 5 { break }
            additionalCardsTextFields[index].text = card != nil ? String(card!) : nil
        }
        */
    }
    
    @IBAction func cancelButtonPressed(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(){
        
    }
}

extension CarTariffChangeViewController: Downloadable{
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
            dismiss(animated: true, completion: updateUIClosure)
        }
    }
}
