//
//  AutopayViewController.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 29.01.2021.
//  Copyright © 2021 jonkykong. All rights reserved.
//

import Foundation
import UIKit

class CarAutopayViewController: UITableViewController{
    var model = AccountModel()
    var vSpinner : UIView?
    
    var openLoginScreenClosure: (() -> Void)?
    var car_id: Int?
    
    @IBOutlet var doneButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.delegate = self
        
        updateTextOnView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0{ // Type of autopay
            for rowIndex in 0..<self.tableView.numberOfRows(inSection: 0){
                self.tableView.cellForRow(at: [0, rowIndex])?.accessoryView = nil
            }
            // Checkmark for chosen
            let cell = self.tableView.cellForRow(at: indexPath)
            let checkmarkImage = UIImageView()
            if #available(iOS 13.0, *) {
                checkmarkImage.image = UIImage(systemName: "checkmark")
            } else {
                // Fallback on earlier versions
            }
            checkmarkImage.tintColor = .systemGreen
            cell?.accessoryView = checkmarkImage
            cell?.accessoryView?.frame = CGRect(x: 0, y: 0, width: 25, height: 20)
            
            checkDoneButtonState()
        }
    }
    
    func updateTextOnView(){
        guard let isAutoCont = AccountController.getCarById(id: car_id)?.is_auto_cont else{
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        
        let autoContType = isAutoCont ? 0 : 1
        self.tableView.reloadData()
        
        clearAutoPaySector()
        self.tableView(self.tableView, didSelectRowAt: [0, autoContType])
        checkDoneButtonState()
    }
    
    func clearAutoPaySector(){
        for rowIndex in 0..<self.tableView.numberOfRows(inSection: 0){
            self.tableView.cellForRow(at: [0, rowIndex])?.accessoryView = nil
        }
    }
    
    func checkDoneButtonState(){
        guard let _ = doneButton else { return }
        
        // Get current state of autoContType from memory
        guard let isAutoCont = AccountController.getCarById(id: car_id)?.is_auto_cont else{
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        let autoContType = isAutoCont ? 0 : 1
        
        // Get the picked variant by user
        var pickedAutoPayStatus: Int8? = nil
        for rowIndex in 0..<self.tableView.numberOfRows(inSection: 0){
            if self.tableView.cellForRow(at: [0, rowIndex])?.accessoryView != nil{
                pickedAutoPayStatus = Int8(rowIndex)
            }
        }
        
        if (pickedAutoPayStatus ?? -1 == autoContType) || (pickedAutoPayStatus == nil){
            doneButton?.isEnabled = false
        }
        else{
            doneButton?.isEnabled = true
        }
    }
    
    @IBAction func cancelButtonPressed(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(){
        guard let email = AccountController.email,
              let passhash = AccountController.password_hash,
              let car_id = AccountController.getCarById(id: car_id)?.id
              else{
            return
        }
    
        // Get picked pay type
        var pickedAutoPay: Int8? = nil
        for rowIndex in 0..<self.tableView.numberOfRows(inSection: 0){
            if self.tableView.cellForRow(at: [0, rowIndex])?.accessoryView != nil{
                pickedAutoPay = Int8(rowIndex)
            }
        }
        
        guard var autoPay = pickedAutoPay,
              [0, 1].contains(autoPay) else{
            return
        }
        autoPay = 1 - autoPay
        
        showSpinner(onView: self.view)
        
        // Send data to server
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unable to get app version"
        
        let param =
                [
                    "ios_app_ver": appVersion,
                    "email": email,
                    "passhash": passhash,
                    "car_id": car_id,
                    "autoPay": autoPay
                ] as [String : Any]
        
        model.downloadAccountData(parameters: param, url: URLServices.updateAutoPay)
    }
}

extension CarAutopayViewController {
    
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

extension CarAutopayViewController: Downloadable{
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
            updateTextOnView()
            removeSpinner()
        }
    }
}
