//
//  ChangePasswordViewController.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 25.07.2021.
//  Copyright © 2021 stepan14511. All rights reserved.
//

import Foundation
import UIKit

class ChangePasswordViewController: UIViewController{
    
    @IBOutlet var phone_field: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setUpDismissKeyboardOutsideTouch()
    }
    
    @IBAction func phoneTextFieldChanging(_ sender: UITextField){
        phone_field.layer.borderWidth = 0
        
        guard var text = sender.text, text.count > 3 else{
            sender.text = "+7 "
            return
        }
        text = text.applyPatternOnNumbers()
        if text.count > 18{
            text = String(text.prefix(18))
        }
        sender.text = text
        if text.count < 3{
            sender.text = "+7 "
        }
    }
    
    @IBAction func phoneTextFieldEditingEnded(_ sender: Any){
        if let phone = phone_field.text{
            if(phone.count <= 4){
                phone_field.text = nil
            }
        }
        
        guard let phone = phone_field.text,
           phone.count == 18 else{
            phone_field.layer.borderWidth = 1
            phone_field.layer.cornerRadius = 5
            phone_field.layer.borderColor = UIColor.red.cgColor
            return
        }
    }
    
    @IBAction func changePasswordButtonPressed(){
        
    }
}

extension ChangePasswordViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == phone_field{
            changePasswordButtonPressed()
        }
        return true
    }
}
