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
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // Spaces between cells to make them divided
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0))
    }
    
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
        // Button borders are made in storyboards.
        // Here only border colors
        if #available(iOS 13.0, *) {
            platesButton?.layer.borderColor = UIColor.systemGray4.cgColor
            lotButton?.layer.borderColor = UIColor.systemGray4.cgColor
            balanceButton?.layer.borderColor = UIColor.systemGray4.cgColor
        } else {
            //TODO Fallback on earlier versions
        }
        guard let car = AccountController.getCarById(id: car_id) else{
            return
        }
        
        platesButton?.setTitle(car.plates, for: .normal)
        if let lot = car.parking_lot_id{
            lotButton?.setTitle("Место: " + lot, for: .normal)
        }
        else{
            lotButton?.setTitle("Выбрать место", for: .normal)
        }
        if let due_time = car.payed_till,
           due_time.minutes(from: Date()) > 0{
            if due_time.weeks(from: Date()) < 1{
                balanceButton?.setTitleColor(.systemRed, for: .normal)
            }
            else{
                balanceButton?.setTitleColor(.systemGreen, for: .normal)
            }
            balanceButton?.setTitle("Осталось оплачено: " + (due_time.offset(from: Date())), for: .normal)
        }
        else{
            balanceButton?.setTitleColor(.systemRed, for: .normal)
            balanceButton?.setTitle("Не оплачено", for: .normal)
        }
    }
    
}
