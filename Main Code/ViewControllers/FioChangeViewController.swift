//
//  FioChangeViewController.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 28.12.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation
import UIKit

class FioChangeViewController: UITableViewController{
    let model = AccountModel()
    
    @IBOutlet var doneButton: UIButton?
    @IBOutlet var surnameCell: UITableViewCell?
    let surnameTextField = UITextField()
    @IBOutlet var nameCell: UITableViewCell?
    let nameTextField = UITextField()
    @IBOutlet var patronymicCell: UITableViewCell?
    let patronymicTextField = UITextField()
    
    var openLoginScreenClosure: (() -> Void)?
    var updateUIClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpDismissKeyboardOutsideTouch()
        model.delegate = self
        
        doneButton?.isEnabled = false
        setupRows()
        updateUI()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.backgroundColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        var textField: UITextField?
        
        switch indexPath.row {
        case 0:
            textField = surnameTextField
        case 1:
            textField = nameTextField
        case 2:
            textField = patronymicTextField
        default:
            return
        }
        
        guard let _ = textField else{ return }
        
        textField!.becomeFirstResponder()
    }
    
    func setupRows(){
        let textFieldWidth = (UIScreen.main.bounds.width) * 0.5
        
        surnameTextField.frame = CGRect(x: 0, y: 480, width: textFieldWidth, height: 40)
        surnameTextField.placeholder = "обязательно"
        surnameTextField.layer.cornerRadius = 10.0
        surnameTextField.addTarget(self, action: #selector(checkForDoneButton), for: .editingChanged)
        surnameTextField.addTarget(self, action: #selector(surnameTextFieldChanging), for: .editingChanged)
        surnameTextField.addTarget(self, action: #selector(surnameTextFieldChanging), for: .editingDidBegin)
        surnameTextField.addTarget(self, action: #selector(surnameTextFieldEditingEnded), for: .editingDidEnd)
        surnameCell?.accessoryView = surnameTextField
        
        nameTextField.frame = CGRect(x: 0, y: 480, width: textFieldWidth, height: 40)
        nameTextField.placeholder = "обязательно"
        nameTextField.layer.cornerRadius = 10.0
        nameTextField.addTarget(self, action: #selector(checkForDoneButton), for: .editingChanged)
        nameTextField.addTarget(self, action: #selector(nameTextFieldChanging), for: .editingChanged)
        nameTextField.addTarget(self, action: #selector(nameTextFieldChanging), for: .editingDidBegin)
        nameTextField.addTarget(self, action: #selector(nameTextFieldEditingEnded), for: .editingDidEnd)
        nameCell?.accessoryView = nameTextField
        
        patronymicTextField.frame = CGRect(x: 0, y: 480, width: textFieldWidth, height: 40)
        patronymicTextField.placeholder = "необязательно"
        patronymicTextField.layer.cornerRadius = 10.0
        patronymicTextField.addTarget(self, action: #selector(checkForDoneButton), for: .editingChanged)
        patronymicCell?.accessoryView = patronymicTextField
    }
    
    @objc func checkForDoneButton(){
        guard let account = AccountController.account else{
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        
        guard let button = doneButton else{
            return
        }
        
        let surname = surnameTextField.text ?? ""
        let name = nameTextField.text ?? ""
        let patronymic = patronymicTextField.text ?? ""
        let acc_patronymic = account.patronymic ?? ""
        
        button.isEnabled = false
        
        if surname.isValidName,
           name.isValidName
        {
            if name != account.name ||
               surname != account.surname ||
               patronymic != acc_patronymic
            {
                button.isEnabled = true
            }
        }
    }
    
    func updateUI(){
        guard let account = AccountController.account else{
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        
        surnameTextField.text = account.surname
        nameTextField.text = account.name
        patronymicTextField.text = account.patronymic
    }
    
    @IBAction func cancelButtonPressed(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(){
        guard let email = AccountController.email,
              let passhash = AccountController.password_hash else{
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        
        //Get version number
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unable to get app version"
        
        let surname = surnameTextField.text ?? ""
        let name = nameTextField.text ?? ""
        let patronymic = patronymicTextField.text ?? ""
        
        guard surname.isValidName, name.isValidName else{
            return
        }
        
        var param =
                [
                    "ios_app_ver": appVersion,
                    "email": email,
                    "passhash": passhash,
                    "surname": surname,
                    "name": name
                ]
        
        if !patronymic.isEmpty{
            param["patronymic"] = patronymic
        }
        
        model.downloadAccountData(parameters: param, url: URLServices.updateFIO)
    }
}

// Reaction to user input
extension FioChangeViewController{
    
    @objc func nameTextFieldChanging(){
        nameCell?.textLabel?.textColor = .black
    }

    @objc func nameTextFieldEditingEnded(){
        guard let name = nameTextField.text,
              name.isValidName
              else {
            
            nameCell?.textLabel?.textColor = .red
            return
        }
    }
    
    @objc func surnameTextFieldChanging(){
        surnameCell?.textLabel?.textColor = .black
    }

    @objc func surnameTextFieldEditingEnded(){
        guard let surname = surnameTextField.text,
              surname.isValidName
              else {
            
            surnameCell?.textLabel?.textColor = .red
            return
        }
    }
}

extension FioChangeViewController: Downloadable{
    func didReceiveData(data param: Any?) {
        // The data model has been dowloaded at this point
        // Now, pass the data model to the Holidays table view controller
        DispatchQueue.main.sync{
            guard let data = param else{
                // Smthing strange, not server error
                return
            }
            
            guard let account = data as? Account else{
                guard let error = data as? ServerError else{
                    return
                }
                
                // Server error
                if error.code == 2{
                    dismiss(animated: true, completion: openLoginScreenClosure)
                    return
                }
                return
            }
            
            AccountController.account = account
            AccountController.saveDataToMemory()
            dismiss(animated: true, completion: updateUIClosure)
        }
    }
}
