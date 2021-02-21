//
//  CarTariffChangeViewControler.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 10.01.2021.
//  Copyright © 2021 jonkykong. All rights reserved.
//

import Foundation
import UIKit

class CarTariffViewController: UITableViewController{
    var model = AccountModel()
    var vSpinner : UIView?
    
    var car_id: Int?
    var openLoginScreenClosure: (() -> Void)?
    var updateUIClosure: (() -> Void)?
    
    @IBOutlet var autopayCell: UITableViewCell?
    @IBOutlet var payedTillCell: UITableViewCell?
    @IBOutlet var parkingLotCell: UITableViewCell?
    @IBOutlet var currTariffCell: UITableViewCell?
    
    // Next tariff labels
    @IBOutlet var tariffs: [UITableViewCell]?
    @IBOutlet var tariffNotChange: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.delegate = self
        
        guard let _ = AccountController.getCarById(id: car_id) else{
            dismiss(animated: true, completion: nil)
            return
        }
        setupCells()
        setupPageAfterDataChange()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0{
            if indexPath.row == 1{
                let storyboard = UIStoryboard(name: "Tariffs", bundle: nil)
                
                guard let accountNavigationViewController = storyboard.instantiateViewController(withIdentifier: "car_lot_nav") as? UINavigationController else { return }
                
                guard let accountViewController = accountNavigationViewController.children[0] as? CarLotPickerViewController else{ return }
                
                self.present(accountNavigationViewController, animated: true, completion: nil)
            }
            
            if indexPath.row == 3{
                guard let car = AccountController.getCarById(id: car_id) else {
                    dismiss(animated: true, completion: openLoginScreenClosure)
                    return
                }
                let storyboard = UIStoryboard(name: "CarEdit", bundle: nil)
                guard let autopayNavigationViewController = storyboard.instantiateViewController(withIdentifier: "autopay_nav") as? UINavigationController else { return }
                
                guard let autopayViewController = autopayNavigationViewController.children[0] as? CarAutopayViewController else{ return }
                
                autopayViewController.car_id = car.id
                /*autopayViewController.openLoginScreenClosure = {self.dismiss(animated: true, completion: self.openLoginScreenClosure)}
                autopayViewController.updateUIClosure = updateRowsText*/
                
                self.present(autopayNavigationViewController, animated: true, completion: nil)
            }
        }
        if indexPath.section == 1{
            let storyboard = UIStoryboard(name: "Tariffs", bundle: nil)
            switch indexPath.row {
            case 0:
                print("daily")
            case 1:
                print("monthly")
            case 2:
                guard let transportNavigationViewController = storyboard.instantiateViewController(withIdentifier: "howtoowner_nav") as? UINavigationController else { return }
                
                self.present(transportNavigationViewController, animated: true, completion: nil)
            
            default:
                print("Programmer is invalid, forgot to create logic for new tariff cells.")
            }
            
        }
    }
    
    func setupPageAfterDataChange(){
        guard let car = AccountController.getCarById(id: car_id) else {
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        
        // Update tariff type label
        if let cell = currTariffCell,
           let label = cell.detailTextLabel{
            
            if let tariff = car.tariff{
                label.text = tariffName[tariff]
            }
            else{
                label.text = "-"
            }
        }
        
        // Update parking lot label
        if let cell = parkingLotCell,
           let label = cell.detailTextLabel{
            
            if let lot_id = car.parking_lot_id{
                var labelText = lot_id
                if let new_lot_id = car.new_parking_lot_id{
                    labelText += " (\(new_lot_id))"
                }
                label.text = labelText
            }
            else{
                label.text = "выбрать"
            }
        }
        
        // Update payed till label
        if let cell = payedTillCell,
           let label = cell.detailTextLabel{
            
            if let time = car.payed_till{
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                label.text = formatter.string(from: time)
            }
            else{
                label.text = "-"
            }
        }
        
        // Update pay type label
        if let cell = autopayCell,
           let label = cell.detailTextLabel{
            
            let type_name = car.is_auto_cont ? "атвоматически" : "вручную"
            label.text = type_name
        }
        
        
        // Set cells unaccessible for owners
        if let tariff = car.tariff,
           tariff == 2{ // Owner of lot case
            
            if let tariffs = tariffs{
                for cell in tariffs{
                    cell.isUserInteractionEnabled = false
                    cell.textLabel?.textColor = .lightGray
                }
            }
            
            if let cell = tariffNotChange{
                cell.isUserInteractionEnabled = false
                cell.textLabel?.textColor = .lightGray
            }
        }
        else{
            if let tariffs = tariffs{
                for cell in tariffs{
                    cell.isUserInteractionEnabled = true
                    cell.textLabel?.textColor = .black
                }
            }
            
            if let cell = tariffNotChange{
                cell.isUserInteractionEnabled = true
                cell.textLabel?.textColor = .black
            }
            
            // Next tariff setup
            if let tariffNotChange = tariffNotChange,
               let tariffs = tariffs,
               tariffs.count >= 3{
                
                var toPutCheckmark: UITableViewCell = tariffNotChange
                
                if let new_tariff = car.new_tariff,
                   new_tariff >= 0, new_tariff <= 2{
                    toPutCheckmark = tariffs[Int(new_tariff)]
                }
                
                
                // Checkmark for chosen
                let checkmarkImage = UIImageView()
                if #available(iOS 13.0, *) {
                    checkmarkImage.image = UIImage(systemName: "checkmark")
                } else {
                    // Fallback on earlier versions
                }
                checkmarkImage.tintColor = .systemGreen
                toPutCheckmark.accessoryView = checkmarkImage
                toPutCheckmark.accessoryView?.frame = CGRect(x: 0, y: 0, width: 25, height: 20)
            }
        }
    }
    
    func setupCells(){
        if #available(iOS 13.0, *) {
            // Forward arrow for parking lot
            if let cell = parkingLotCell{
                let chevronImage1 = UIImageView()
                chevronImage1.image = UIImage(systemName: "chevron.forward")
                chevronImage1.tintColor = .lightGray
                cell.accessoryView = chevronImage1
                cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 10, height: 15)
            }
            
            // Forward arrow for autopay
            if let cell = autopayCell{
                let chevronImage2 = UIImageView()
                chevronImage2.image = UIImage(systemName: "chevron.forward")
                chevronImage2.tintColor = .lightGray
                cell.accessoryView = chevronImage2
                cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 10, height: 15)
            }
        }
        else{
            //TODO: SET FOR OTHER IOS VERSIONS
        }
    }
    
    @IBAction func cancelButtonPressed(){
        dismiss(animated: true, completion: updateUIClosure)
    }
}

extension CarTariffViewController: Downloadable{
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
        }
    }
}
