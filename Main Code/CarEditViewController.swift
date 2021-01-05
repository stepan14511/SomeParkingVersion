//
//  CarEditViewController.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 19.12.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation
import UIKit

class CarEditViewController: UITableViewController{
    let model = AccountModel()
    var car_id = -1
    
    var openLoginScreenClosure: (() -> Void)?
    var updateAccountClosure: (() -> Void)?
    
    
    @IBOutlet var platesCell: UITableViewCell?
    let platesTextField = UITextField()
    @IBOutlet var parkingLotCell: UITableViewCell?
    @IBOutlet var tariffCell: UITableViewCell?
    @IBOutlet var cardsCell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.delegate = self
        
        setupCells()
        updateRowsText()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath == [0, 0]{
            platesTextField.becomeFirstResponder()
        }
        
        if indexPath == [0, 3]{
            guard let car = AccountController.getCarById(id: car_id) else{
                dismiss(animated: true, completion: updateAccountClosure)
                return
            }
            
            guard let cardsNavigationViewController = self.storyboard?.instantiateViewController(withIdentifier: "cards_nav") as? UINavigationController else { return }
            
            guard let cardsViewController = cardsNavigationViewController.children[0] as? CarCardsViewController else{ return }
            
            cardsViewController.car = car
            cardsViewController.openLoginScreenClosure = openLoginScreenClosure
            cardsViewController.updateUIClosure = updateRowsText
            
            self.present(cardsNavigationViewController, animated: true, completion: nil)
        }
    }
    
    func setupCells(){
        if #available(iOS 13.0, *) {
            // Forward arrow for tariff
            let chevronImage1 = UIImageView()
            chevronImage1.image = UIImage(systemName: "chevron.forward")
            chevronImage1.tintColor = .lightGray
            tariffCell?.accessoryView = chevronImage1
            tariffCell?.accessoryView?.frame = CGRect(x: 0, y: 0, width: 10, height: 15)
            
            // Forward arrow for cards
            let chevronImage2 = UIImageView()
            chevronImage2.image = UIImage(systemName: "chevron.forward")
            chevronImage2.tintColor = .lightGray
            cardsCell?.accessoryView = chevronImage2
            cardsCell?.accessoryView?.frame = CGRect(x: 0, y: 0, width: 10, height: 15)
        }
        else{
            //TODO: SET FOR OTHER IOS VERSIONS
        }
        
        
        let textFieldWidth = (UIScreen.main.bounds.width) * 0.5
        
        platesTextField.frame = CGRect(x: 0, y: 480, width: textFieldWidth, height: 40)
        platesTextField.placeholder = "А 123 БВ 456"
        platesTextField.layer.cornerRadius = 10.0
        platesTextField.textAlignment = .right
        platesTextField.addTarget(self, action: #selector(platesTextFieldChanged), for: .editingChanged)
        platesTextField.addTarget(self, action: #selector(platesTextFieldChanged), for: .editingDidBegin)
        platesCell?.accessoryView = platesTextField
    }
    
    func updateRowsText(){
        guard let car = AccountController.getCarById(id: car_id) else{
            dismiss(animated: true, completion: updateAccountClosure)
            return
        }
        
        platesTextField.text = car.plates
        
        if let lot_id = car.parking_lot_id{
            parkingLotCell?.detailTextLabel?.text = String(lot_id)
        }
        else{
            parkingLotCell?.detailTextLabel?.text = "-"
        }
        
        if let tariff = car.tariff,
           [0, 1].contains(tariff)
           {
            tariffCell?.detailTextLabel?.text = tariffName[tariff]
        }
        else{
            tariffCell?.detailTextLabel?.text = "не выбрано"
        }
    }
    
    @objc func platesTextFieldChanged(){
        guard var text = platesTextField.text else{
            return
        }
        if text.count > 12{
            text = String(text.prefix(12))
        }
        //text = text.applyPatternOnNumbers(pattern: kPlatesPattern, replacementCharacter: kPlatesPatternReplaceChar, numbersRE: "[^a-zA-Zа-яА-Я0-9]") // FIX THIS SHIT
        platesTextField.text = text
    }
    
    @objc func platesTextFieldEditingEnded(){
        //TODO: Check for possible plates
    }
    
    @IBAction func dismissButtonPressed(){
        dismiss(animated: true, completion: nil)
    }
}

extension CarEditViewController: Downloadable{
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
                if error.code == 2{
                    dismiss(animated: true, completion: openLoginScreenClosure)
                    return
                }
                return
            }
            
            AccountController.account = account
            AccountController.saveDataToMemory()
        }
    }
}
