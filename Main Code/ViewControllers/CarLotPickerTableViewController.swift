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
    var currentParkingLot: ParkingLot?
    
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
            cell.currentParkingLot = currentParkingLot
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
