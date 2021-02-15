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
    var vSpinner : UIView?
    
    var car: Car?
    var openLoginScreenClosure: (() -> Void)?
    var updateUIClosure: (() -> Void)?
    
    @IBOutlet var doneButton: UIButton?
    @IBOutlet var autopayCell: UITableViewCell?
    @IBOutlet var payedTillCell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.delegate = self
        
        guard let _ = car else{
            dismiss(animated: true, completion: nil)
            return
        }
        setupCells()
        setupPageAfterDataChange()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0{
            let viewBeforeSelecting = self.tableView.cellForRow(at: indexPath)?.accessoryView
            for rowIndex in 0..<self.tableView.numberOfRows(inSection: 0){
                self.tableView.cellForRow(at: [0, rowIndex])?.accessoryView = nil
            }
            if(viewBeforeSelecting == nil){
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
            }
            setDoneButtonState()
        }
        if indexPath.section == 1{
            if indexPath.row == 1{
                guard let autopayNavigationViewController = self.storyboard?.instantiateViewController(withIdentifier: "autopay_nav") as? UINavigationController else { return }
                
                guard let autopayViewController = autopayNavigationViewController.children[0] as? CarAutopayViewController else{ return }
                
                autopayViewController.car = car
                /*autopayViewController.openLoginScreenClosure = {self.dismiss(animated: true, completion: self.openLoginScreenClosure)}
                autopayViewController.updateUIClosure = updateRowsText*/
                
                self.present(autopayNavigationViewController, animated: true, completion: nil)
            }
        }
    }
    
    func setupPageAfterDataChange(){
        self.tableView.reloadData()
        car = AccountController.getCarById(id: car?.id) // Update car
        clearTariffSector()
        if let tariff = car?.tariff{
            self.tableView(self.tableView, didSelectRowAt: [0, Int(tariff)])
        }
        updateRowsText()
        setDoneButtonState()
        
        //Update payed till label
        if let cell = payedTillCell,
              let label = cell.detailTextLabel,
              let time = car?.payed_till{
            
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            label.text = formatter.string(from: time)
        }
        
    }
    
    func clearTariffSector(){
        for rowIndex in 0..<self.tableView.numberOfRows(inSection: 0){
            self.tableView.cellForRow(at: [0, rowIndex])?.accessoryView = nil
        }
    }
    
    func setupCells(){
        if #available(iOS 13.0, *) {
            // Forward arrow for autopay
            let chevronImage1 = UIImageView()
            chevronImage1.image = UIImage(systemName: "chevron.forward")
            chevronImage1.tintColor = .lightGray
            autopayCell?.accessoryView = chevronImage1
            autopayCell?.accessoryView?.frame = CGRect(x: 0, y: 0, width: 10, height: 15)
        }
        else{
            //TODO: SET FOR OTHER IOS VERSIONS
        }
    }
    
    func updateRowsText(){
        //TODO: add end time label
    }
    
    func setDoneButtonState(){
        var pickedTariff: Int8? = nil
        for rowIndex in 0..<self.tableView.numberOfRows(inSection: 0){
            if self.tableView.cellForRow(at: [0, rowIndex])?.accessoryView != nil{
                pickedTariff = Int8(rowIndex)
            }
        }
        if pickedTariff == car?.tariff{
            doneButton?.isEnabled = false
        }
        else{
            doneButton?.isEnabled = true
        }
    }
    
    @IBAction func cancelButtonPressed(){
        dismiss(animated: true, completion: updateUIClosure)
    }
    
    @IBAction func doneButtonPressed(){
        guard let email = AccountController.email,
              let passhash = AccountController.password_hash,
              let car_id = car?.id
              else{
            return
        }
        
        showSpinner(onView: self.view)
        
        // Send data to server
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unable to get app version"
        
        var param =
                [
                    "ios_app_ver": appVersion,
                    "email": email,
                    "passhash": passhash,
                    "car_id": car_id
                ] as [String : Any]
        
        var pickedTariff: Int8? = nil
        for rowIndex in 0..<self.tableView.numberOfRows(inSection: 0){
            if self.tableView.cellForRow(at: [0, rowIndex])?.accessoryView != nil{
                pickedTariff = Int8(rowIndex)
            }
        }
        if pickedTariff != nil{
            param["tariff"] = pickedTariff
        }
        
        model.downloadAccountData(parameters: param, url: URLServices.updateTariff)
    }
}

extension CarTariffChangeViewController {
    
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
            setupPageAfterDataChange()
            removeSpinner()
        }
    }
}
