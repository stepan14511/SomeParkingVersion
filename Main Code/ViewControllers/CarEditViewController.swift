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
    
    // Spinner vars
    var vSpinner : UIView?
    private var spinnerStartTime: Date = Date()
    
    var car_id: Int? // Set up by caller
    var openLoginScreenClosure: (() -> Void)?
    var updateAccountClosure: (() -> Void)?
    
    @IBOutlet var platesCell: UITableViewCell?
    let platesTextField = UITextField()
    @IBOutlet var tariffCell: UITableViewCell?
    @IBOutlet var cardsCell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpDismissKeyboardOutsideTouch()
        model.delegate = self
        
        setupCells()
        updateRowsText()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath == [0, 0]{
            platesTextField.becomeFirstResponder()
        }
        
        if indexPath == [0, 1]{ // Change tariff view
            guard let car = AccountController.getCarById(id: car_id) else{
                dismiss(animated: true, completion: updateAccountClosure)
                return
            }
            let storyboard = UIStoryboard(name: "CarEdit", bundle: nil)
            guard let tariffChangeNavigationViewController = storyboard.instantiateViewController(withIdentifier: "tariffChange_nav") as? UINavigationController else { return }
            
            guard let tariffChangeViewController = tariffChangeNavigationViewController.children[0] as? CarTariffChangeViewController else{ return }
            
            tariffChangeViewController.car_id = car.id
            tariffChangeViewController.openLoginScreenClosure = {self.dismiss(animated: true, completion: self.openLoginScreenClosure)}
            tariffChangeViewController.updateUIClosure = updateRowsText
            
            self.present(tariffChangeNavigationViewController, animated: true, completion: nil)
        }
        
        if indexPath == [0, 2]{ // Change cards view
            guard let car = AccountController.getCarById(id: car_id) else{
                dismiss(animated: true, completion: updateAccountClosure)
                return
            }
            
            let storyboard = UIStoryboard(name: "CarEdit", bundle: nil)
            guard let cardsNavigationViewController = storyboard.instantiateViewController(withIdentifier: "cards_nav") as? UINavigationController else { return }
            
            guard let cardsViewController = cardsNavigationViewController.children[0] as? CarCardsViewController else{ return }
            
            cardsViewController.car_id = car.id
            cardsViewController.openLoginScreenClosure = {self.dismiss(animated: true, completion: self.openLoginScreenClosure)}
            cardsViewController.updateUIClosure = updateRowsText
            
            self.present(cardsNavigationViewController, animated: true, completion: nil)
        }
        
        if indexPath == [1, 0]{ // Delete button
            
            // Show alert for double asking user if they want to delete the car
            let alert = UIAlertController(title: "Вы действительно хотите удалить ТС?", message: "Восстановить данные будет невозможно.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: deleteCar))
            alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))

            self.present(alert, animated: true)
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
        platesTextField.placeholder = "а123бс456"
        platesTextField.layer.cornerRadius = 10.0
        platesTextField.textAlignment = .right
        platesTextField.addTarget(self, action: #selector(platesTextFieldChanged), for: .editingChanged)
        platesTextField.addTarget(self, action: #selector(platesTextFieldChanged), for: .editingDidBegin)
        platesTextField.addTarget(self, action: #selector(platesTextFieldEditingEnded), for: .editingDidEnd)
        platesCell?.accessoryView = platesTextField
    }
    
    func updateRowsText(){
        guard let car = AccountController.getCarById(id: car_id) else{
            dismiss(animated: true, completion: updateAccountClosure)
            return
        }
        
        platesTextField.text = car.plates
        
        if let tariff = car.tariff,
           tariffName.keys.contains(tariff),
           let lot_id = car.parking_lot_id
           {
            tariffCell?.detailTextLabel?.text = tariffName[tariff]! + " - " + String(lot_id)
        }
        else{
            tariffCell?.detailTextLabel?.text = "не выбрано"
        }
    }
}

// Reaction to user input
extension CarEditViewController {
    
    @objc func platesTextFieldChanged(){
        guard var text = platesTextField.text else{
            return
        }
        if text.count > 9{
            text = String(text.prefix(9))
        }
        
        platesCell?.textLabel?.textColor = .black
        platesTextField.text = text
    }
    
    @objc func platesTextFieldEditingEnded(){
        guard let email = AccountController.email,
              let passhash = AccountController.password_hash,
              let car_id = AccountController.getCarById(id: car_id)?.id
              else{
            
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        
        guard var new_plates = platesTextField.text,
              new_plates.isLegalPlates else{
            
            platesCell?.textLabel?.textColor = .red
            return
        }
        
        new_plates = new_plates.removingWhitespaces()
        new_plates = new_plates.lowercased()
        new_plates = new_plates.translatePlatesToRus()
        guard let plates = AccountController.getCarById(id: car_id)?.plates,
              plates != new_plates
              else{
            return
        }
        
        if let view = platesCell{
            showSpinner(onView: view)
        }
        
        // Send data to server
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unable to get app version"
        
        let param =
                [
                    "ios_app_ver": appVersion,
                    "email": email,
                    "passhash": passhash,
                    "car_id": car_id,
                    "new_plates": new_plates
                ] as [String : Any]
        
        model.downloadAccountData(parameters: param, url: URLServices.updatePlates)
    }
    
    @IBAction func dismissButtonPressed(){
        dismiss(animated: true, completion: updateAccountClosure)
    }
    
    func deleteCar(_ alert: UIAlertAction){
        guard let email = AccountController.email,
              let passhash = AccountController.password_hash,
              let car_id = AccountController.getCarById(id: car_id)?.id
              else{
            return
        }
        
        showSpinner(onView: self.view)
        
        // Send data to server
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unable to get app version"
        
        let param =
                [
                    "ios_app_ver": appVersion,
                    "email": email,
                    "passhash": passhash,
                    "car_id": car_id
                ] as [String : Any]
        
        model.downloadAccountData(parameters: param, url: URLServices.deleteCar)
    }
}

extension CarEditViewController {
    
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
            updateRowsText()
            removeSpinner()
        }
    }
}
