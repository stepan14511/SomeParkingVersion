//
//  AccountViewController.swift
//  SideMenu
//
//  Created by Stepan Kuznetsov on 27.12.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation
import UIKit

class AccountViewController: UITableViewController{
    
    var openLoginScreenClosure: (() -> Void)?
    
    @IBOutlet var fioCell: UITableViewCell?
    @IBOutlet var phoneCell: UITableViewCell?
    @IBOutlet var emailCell: UITableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCells()
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath == [1, 0]{ // Sign out button
            // Showing alert for double asking user if they want to sign out
            let alert = UIAlertController(title: "Вы действительно хотите выйти?", message: nil, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: signOutButtonPressed))
            alert.addAction(UIAlertAction(title: "Нет", style: .cancel, handler: nil))

            self.present(alert, animated: true)
        }
        if indexPath == [0, 0]{
            let storyboard = UIStoryboard(name: "Account", bundle: nil)
            guard let fioNavigationViewController = storyboard.instantiateViewController(withIdentifier: "changeFIO_nav") as? UINavigationController else { return }
            
            guard let fioViewController = fioNavigationViewController.children[0] as? FioChangeViewController else{ return }
            
            fioViewController.openLoginScreenClosure = {self.dismiss(animated: true, completion: self.openLoginScreenClosure)}
            fioViewController.updateUIClosure = updateRowsText
            
            self.present(fioNavigationViewController, animated: true, completion: nil)
        }
    }
    
    func setupCells(){
        if #available(iOS 13.0, *) {
            // Forward arrow for FIO
            let chevronImage = UIImageView()
            chevronImage.image = UIImage(systemName: "chevron.forward")
            chevronImage.tintColor = .lightGray
            fioCell?.accessoryView = chevronImage
            fioCell?.accessoryView?.frame = CGRect(x: 0, y: 0, width: 10, height: 15)
            
            /*
             I will leave it here just for the future, if I will want to add this functionality
            // Forward arrow for phone
            let forwardImage2 = UIImageView()
            forwardImage2.image = UIImage(systemName: "chevron.forward")
            forwardImage2.tintColor = .lightGray
            phoneCell?.accessoryView = forwardImage2
            phoneCell?.accessoryView?.frame = CGRect(x: 0, y: 0, width: 10, height: 15)
            
            // Forward arrow for email
            let forwardImage3 = UIImageView()
            forwardImage3.image = UIImage(systemName: "chevron.forward")
            forwardImage3.tintColor = .lightGray
            emailCell?.accessoryView = forwardImage3
            emailCell?.accessoryView?.frame = CGRect(x: 0, y: 0, width: 10, height: 15)
            */
        }
        else{
            //TODO: SET FOR OTHER IOS VERSIONS
        }
        
        updateRowsText()
    }
    
    func updateRowsText(){
        guard let account = AccountController.account else{
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        
        fioCell?.textLabel?.text = getFullFIO(account)
        phoneCell?.detailTextLabel?.text = account.phone
        emailCell?.detailTextLabel?.text = account.email
    }
    
    func getFullFIO(_ account: Account) -> String{
        var fio = account.name + " "
        if let patronymic = account.patronymic{
            fio += patronymic + " "
        }
        fio += account.surname
        return fio
    }
    
    func signOutButtonPressed(_ alert: UIAlertAction){
        dismiss(animated: true, completion: openLoginScreenClosure)
    }
}
