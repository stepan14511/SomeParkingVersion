//
//  TariffMonthlyTableViewcontroller.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 17.02.2021.
//  Copyright © 2021 jonkykong. All rights reserved.
//

import Foundation
import UIKit

class CarLotPickerTableViewController: UITableViewController{
    private var _isPickerHidden = true
    
    var isPickerHidden: Bool{
        set{ // Just push raw password, it will be hashed itself
            _isPickerHidden = newValue
            pickerViewToggledClosure?(newValue)
        }
        get{ return _isPickerHidden }
    }
    
    var pickerViewToggledClosure: ((Bool) -> Void)?
    var responseOnInputFromPickerViewClosure: ((String) -> Void)?
    var availableParkingLots: [ParkingLot]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isPickerHidden ? 1 : 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "main")!

            return cell
        }
        else{
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "picker")! as! PickerViewCustomCell
            
            cell.availableParkingLots = availableParkingLots
            cell.userInputResponceClosure = responseOnUserInputFromPickerView(lot:)

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.row == 1 {
            return 165
        }
        return 45 //or whatever you need
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0{
            if isPickerHidden{
                isPickerHidden = false
                tableView.beginUpdates()
                tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                tableView.endUpdates()
            }
            else{
                isPickerHidden = true
                tableView.deleteRows(at: [[0, 1]], with: .top)
            }
        }
    }
    
    func responseOnUserInputFromPickerView(lot: String){
        tableView.cellForRow(at: [0, 0])?.detailTextLabel?.text = lot
        responseOnInputFromPickerViewClosure?(lot)
    }
}


class PickerViewCustomCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    var availableParkingLots: [ParkingLot]?
    var userInputResponceClosure: ((String) -> Void)?
    
    override func prepareForReuse() {}
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableParkingLots?.count ?? 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row == 0{
            return "-"
        }
        
        let parkingLot = availableParkingLots?[row - 1]
        let typePostfix: String? = (parkingLot?.type ?? 1 == 2) ? (" (расширенное)") : nil
        return (parkingLot?.id ?? "") + (typePostfix ?? "")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            userInputResponceClosure?("-")
            return
        }
        userInputResponceClosure?(availableParkingLots?[row - 1].id ?? "-")
    }
}
