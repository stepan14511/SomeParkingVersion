//
//  PopolnitViewController.swift
//  Example
//
//  Created by Stepan Kuznetsov on 30.10.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//
import UIKit

class PopolnitViewController: UIViewController{
    
    @IBOutlet var changePaymentSystemView: UIView?
    
    @objc func changePaymentSystemPressed(sender : UITapGestureRecognizer) {
        //TODO: Open new view with change of payment system
    }
    
    override func viewDidLoad() {
        // Setting changePaymentSystem tap recogniser
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.changePaymentSystemPressed))
        self.changePaymentSystemView!.addGestureRecognizer(gesture)
    }
    
    @IBAction func Exit(){
        dismiss(animated: true, completion: nil)
    }
    
}
