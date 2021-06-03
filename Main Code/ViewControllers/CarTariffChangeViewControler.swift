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
    var car_id: Int?
    var openLoginScreenClosure: (() -> Void)?
    var updateUIClosure: (() -> Void)?
    
    @IBOutlet var autopayCell: UITableViewCell?
    @IBOutlet var payedTillCell: UITableViewCell?
    @IBOutlet var parkingLotCell: UITableViewCell?
    @IBOutlet var currTariffCell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                
                accountViewController.car_id = car_id
                accountViewController.updateViewAfterDataChangeClosure = setupPageAfterDataChange
                accountViewController.openLoginScreenClosure = {self.dismiss(animated: true, completion: self.openLoginScreenClosure)}
                
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
                autopayViewController.openLoginScreenClosure = {self.dismiss(animated: true, completion: self.openLoginScreenClosure)}
                //autopayViewController.updateUIClosure = updateRowsText
                
                self.present(autopayNavigationViewController, animated: true, completion: nil)
            }
        }
        if indexPath.section == 1{
            let storyboard = UIStoryboard(name: "Tariffs", bundle: nil)
            guard let transportNavigationViewController = storyboard.instantiateViewController(withIdentifier: "howtoowner_nav") as? UINavigationController else { return }
            self.present(transportNavigationViewController, animated: true, completion: nil)
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
                label.text = lot_id
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
