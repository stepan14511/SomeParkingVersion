//
//  TransportViewController.swift
//  Example
//
//  Created by Stepan Kuznetsov on 30.10.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation
import UIKit

class TransportViewController: UITableViewController{
    
    @IBOutlet var addTransport: UIView?
    
    override func viewDidLoad() {
        // Setting changePaymentSystem tap recogniser
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.addTransportPressed))
        self.addTransport!.addGestureRecognizer(gesture)
        
        print(AccountController.account!.cars!)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let cars = AccountController.account?.cars{
            return cars.count
        }
        else{
            return 0
        }
    }
    // create a cell for each table view row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        
        var cell = self.tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") as UITableViewCell?
        
        if cell == nil{
            
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "reuseIdentifier")
        }
        
        if let cars = AccountController.account?.cars{
            cell?.textLabel?.text = cars[indexPath.row].plates
            
            if let parking_lot_id = cars[indexPath.row].parking_lot_id{
                cell?.detailTextLabel?.text = "Парковочное место: " + String(parking_lot_id)
            }
            else{
                cell?.detailTextLabel?.text = ""
            }
            
        }
        else{
            cell?.textLabel?.text = ""
            cell?.detailTextLabel?.text = ""
        }
        cell?.detailTextLabel?.textColor = .systemGray
        return cell!
    }
    
    @objc func addTransportPressed(sender : UITapGestureRecognizer) {
        print("wtf")
    }
    
    @IBAction func Exit(){
        dismiss(animated: true, completion: nil)
    }
}
