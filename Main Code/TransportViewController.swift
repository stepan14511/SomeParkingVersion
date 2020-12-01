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
    
    @objc func addTransportPressed(sender : UITapGestureRecognizer) {
        //TODO: Open new view with change of payment system
    }
    
    override func viewDidLoad() {
        // Setting changePaymentSystem tap recogniser
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.addTransportPressed))
        self.addTransport!.addGestureRecognizer(gesture)
    }
    
    @IBAction func Exit(){
        dismiss(animated: true, completion: nil)
    }
}
