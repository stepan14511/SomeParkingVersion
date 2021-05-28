//
//  TransportTableViewCell.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 27.05.2021.
//  Copyright © 2021 stepan14511. All rights reserved.
//

import UIKit

class TransportTableViewCell: UITableViewCell {
    var car_id: Int?
    var platesButtonFunction: ((Int?) -> Void)?
    var lotButtonFunction: ((Int?) -> Void)?
    var balanceButtonFunction: ((Int?) -> Void)?
    
    @IBOutlet var platesButton: UIButton?
    @IBOutlet var lotButton: UIButton?
    @IBOutlet var balanceButton: UIButton?
    
    @IBAction func platesButtonPressed(){
        platesButtonFunction?(car_id)
    }
    
    @IBAction func lotButtonPressed(){
        lotButtonFunction?(car_id)
    }
    
    @IBAction func balanceButtonPressed(){
        balanceButtonFunction?(car_id)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(){
        guard let car = AccountController.getCarById(id: car_id) else{
            return
        }
        
        platesButton?.setTitle(car.plates, for: .normal)
        lotButton?.setTitle(car.parking_lot_id ?? "Выбрать место", for: .normal)
        balanceButton?.setTitle("Осталось оплачено: 24д.", for: .normal)
    }
    
}
