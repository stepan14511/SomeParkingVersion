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
    
    var car_id: Int?
    var openLoginScreenClosure: (() -> Void)?
    var updateUIClosure: (() -> Void)?
    
    @IBOutlet var autopayCell: UITableViewCell?
    @IBOutlet var payedTillCell: UITableViewCell?
    
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
            let storyboard = UIStoryboard(name: "Tariffs", bundle: nil)
            switch indexPath.row {
            case 0:
                print("daily")
            case 1:
                guard let accountNavigationViewController = storyboard.instantiateViewController(withIdentifier: "monthlyTariff_nav") as? UINavigationController else { return }
                
                guard let accountViewController = accountNavigationViewController.children[0] as? TariffMonthlyViewController else{ return }
                
                self.present(accountNavigationViewController, animated: true, completion: nil)
            case 2:
                guard let transportNavigationViewController = storyboard.instantiateViewController(withIdentifier: "howtoowner_nav") as? UINavigationController else { return }
                
                self.present(transportNavigationViewController, animated: true, completion: nil)
            
            default:
                print("Programmer is invalid, forgot to create logic for new tariff cells.")
            }
        }
        if indexPath.section == 1{
            if indexPath.row == 1{
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
    }
    
    func setupPageAfterDataChange(){
        guard let car = AccountController.getCarById(id: car_id) else {
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        
        //Update payed till label
        if let cell = payedTillCell,
              let label = cell.detailTextLabel,
              let time = car.payed_till{
            
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            label.text = formatter.string(from: time)
        }
        
    }
    
    func setupCells(){
        if #available(iOS 13.0, *) {
            // Forward arrow for first tariff
            let chevronImage1 = UIImageView()
            chevronImage1.image = UIImage(systemName: "chevron.forward")
            chevronImage1.tintColor = .lightGray
            autopayCell?.accessoryView = chevronImage1
            autopayCell?.accessoryView?.frame = CGRect(x: 0, y: 0, width: 10, height: 15)
            
            // Forward arrow for second tariff
            if self.tableView.numberOfRows(inSection: 0) >= 1{
                let chevronImage2 = UIImageView()
                chevronImage2.image = UIImage(systemName: "chevron.forward")
                chevronImage2.tintColor = .lightGray
                self.tableView.cellForRow(at: [0, 0])?.accessoryView = chevronImage2
                self.tableView.cellForRow(at: [0, 0])?.accessoryView?.frame = CGRect(x: 0, y: 0, width: 10, height: 15)
            }
            
            // Forward arrow for third tariff
            if self.tableView.numberOfRows(inSection: 0) >= 2{
                let chevronImage3 = UIImageView()
                chevronImage3.image = UIImage(systemName: "chevron.forward")
                chevronImage3.tintColor = .lightGray
                self.tableView.cellForRow(at: [0, 1])?.accessoryView = chevronImage3
                self.tableView.cellForRow(at: [0, 1])?.accessoryView?.frame = CGRect(x: 0, y: 0, width: 10, height: 15)
            }
            
            // Forward arrow for autopay
            if self.tableView.numberOfRows(inSection: 0) >= 3{
                let chevronImage4 = UIImageView()
                chevronImage4.image = UIImage(systemName: "chevron.forward")
                chevronImage4.tintColor = .lightGray
                self.tableView.cellForRow(at: [0, 2])?.accessoryView = chevronImage4
                self.tableView.cellForRow(at: [0, 2])?.accessoryView?.frame = CGRect(x: 0, y: 0, width: 10, height: 15)
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
        }
    }
}
