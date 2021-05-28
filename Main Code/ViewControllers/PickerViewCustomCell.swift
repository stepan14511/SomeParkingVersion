//
//  PickerViewCustomCell.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 02.05.2021.
//  Copyright © 2021 stepan14511. All rights reserved.
//

import Foundation
import UIKit

class PickerViewCustomCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    var availableParkingLots: [ParkingLot]?
    var currentParkingLot: ParkingLot?
    var userInputResponceClosure: ((String) -> Void)?
    
    override func prepareForReuse() {}
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableParkingLots?.count ?? 1
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        if row == 0{
            if let currLot = currentParkingLot{
                let text = (currLot.id ?? "") + (" (текущее)")
                return NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGreen])
            }
            else{
                return NSAttributedString(string: "-", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
            }
        }
        
        let parkingLot = availableParkingLots?[row - 1]
        var typePostfix: String? = (parkingLot?.type ?? 1 == 2) ? (" (увеличенное)") : nil
        typePostfix = (parkingLot?.type ?? 1 == 3) ? (" (на 2 машины)") : typePostfix
        
        var pricePostfix: String = " - 3.000₽"
        pricePostfix = (parkingLot?.type ?? 1 == 2) ? (" - 4.000₽") : pricePostfix
        pricePostfix = (parkingLot?.type ?? 1 == 3) ? (" - 5.000₽") : pricePostfix
        let text = (parkingLot?.id ?? "") + (typePostfix ?? "") + pricePostfix
        
        // Define color of text
        var color = UIColor.black
        color = (parkingLot?.type ?? 1 == 2) ? .orange : color
        color = (parkingLot?.type ?? 1 == 3) ? .systemGreen : color
        return NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            userInputResponceClosure?((currentParkingLot?.id ?? "-"))
            return
        }
        userInputResponceClosure?(availableParkingLots?[row - 1].id ?? "-")
    }
}
