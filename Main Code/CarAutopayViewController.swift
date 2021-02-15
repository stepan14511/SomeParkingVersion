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
    var openLoginScreenClosure: (() -> Void)?
    var car: Car?
    
    @IBOutlet var doneButton: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let isAutoCont = car?.is_auto_cont else{
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        let autoContType = isAutoCont ? 0 : 1
        self.tableView.reloadData()
        self.tableView(self.tableView, didSelectRowAt: [0, autoContType])
        checkDoneButtonState()
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
    
    func checkDoneButtonState(){
        guard let _ = doneButton else { return }
        
        // Get current state of autoContType from memory
        guard let isAutoCont = car?.is_auto_cont else{
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        let autoContType = isAutoCont ? 0 : 1
        
        // Get the picked variant by user
        var pickedTariff: Int8? = nil
        for rowIndex in 0..<self.tableView.numberOfRows(inSection: 0){
            if self.tableView.cellForRow(at: [0, rowIndex])?.accessoryView != nil{
                pickedTariff = Int8(rowIndex)
            }
        }
        
        if (pickedTariff ?? -1 == autoContType) || (pickedTariff == nil){
            doneButton?.isEnabled = false
        }
        else{
            doneButton?.isEnabled = true
        }
    }
    
    @IBAction func cancelButtonPressed(){
        dismiss(animated: true, completion: nil)
    }
}
