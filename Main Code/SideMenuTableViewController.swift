//
//  SideMenuTableViewController.swift
//  SideMenu
//
//  Created by Jon Kent on 4/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import SideMenu

class SideMenuTableViewController: UITableViewController {
    
    @IBOutlet weak var fullNameLabel: UILabel?
    @IBOutlet weak var phoneNumberLabel: UILabel?
    @IBOutlet weak var balanceLabel: UILabel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
        guard let menu = navigationController as? SideMenuNavigationController, menu.blurEffectStyle == nil else {
            return
        }
        
        tableView.backgroundView?.backgroundColor = UIColor.black
        
        updateAccountDataUI()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! UITableViewVibrantCell

        if let menu = navigationController as? SideMenuNavigationController {
            cell.blurEffectStyle = menu.blurEffectStyle
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == [0, 1]{ // Account button
            AccountController.password_hash = nil
            AccountController.account = nil
            AccountController.saveDataToMemory()
            
            MainViewController.doOpenLogin = true
            dismiss(animated: true, completion: nil)
        }
        if indexPath == [0, 2]{ // Account button
            guard let popolnitController = self.storyboard?.instantiateViewController(withIdentifier: "payment") as? PopolnitViewController else { return }
            
            popolnitController.callbackClosure = {
                self.updateAccountDataUI()
            }
            
            self.present(popolnitController, animated: true, completion: nil)
        }
    }
    
    func updateAccountDataUI(){
        guard let account = AccountController.account else{
            return
        }
        
        if let _ = fullNameLabel{
            fullNameLabel!.text = account.name + " "
            
            if let patronymic = account.patronymic{
                fullNameLabel!.text! += patronymic + " "
            }
            
            fullNameLabel!.text! += account.surname
        }
        
        if let _ = phoneNumberLabel{
            phoneNumberLabel!.text = account.phone
        }
        
        if let _ = balanceLabel{
            let formater = NumberFormatter()
            formater.locale = Locale(identifier: "ru_RU")
            formater.groupingSeparator = "."
            formater.numberStyle = .currency
            formater.currencySymbol = "₽"
            let formattedBalance = formater.string(from: NSNumber(value: account.balance))
            balanceLabel!.text = String(formattedBalance ?? "0,00 ₽")
        }
    }
    
}
