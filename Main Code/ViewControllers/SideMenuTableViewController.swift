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
    
    var callbackClosure: (() -> Void)?
    var openLoginScreenClosure: (() -> Void)?
    var openAccountViewControllerClosure: (() -> Void)?
    var openPopolnitViewControllerClosure: (() -> Void)?
    var openTransportViewControllerClosure: (() -> Void)?
    var openHowToOwnerViewControllerClosure: (() -> Void)?
    var openRulesPageClosure: (() -> Void)?
    var openHowToUsePageClosure: (() -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
        guard let menu = navigationController as? SideMenuNavigationController, menu.blurEffectStyle == nil else {
            return
        }
        
        tableView.backgroundView?.backgroundColor = UIColor.black
        
        updateAccountDataUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        callbackClosure?()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! UITableViewVibrantCell

        if let menu = navigationController as? SideMenuNavigationController {
            cell.blurEffectStyle = menu.blurEffectStyle
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath == [0, 1]{
            dismiss(animated: true, completion: openAccountViewControllerClosure)
        }
        if indexPath == [0, 2]{ // Popolnit button
            dismiss(animated: true, completion: openPopolnitViewControllerClosure)
        }
        
        if indexPath == [0, 5]{ // Transport button
            dismiss(animated: true, completion: openTransportViewControllerClosure)
        }
        
        if indexPath == [0, 7]{ // How to owner button
            dismiss(animated: true, completion: openHowToOwnerViewControllerClosure)
        }
        
        if indexPath == [0, 9]{ // Rules button
            dismiss(animated: true, completion: openRulesPageClosure)
        }
        
        if indexPath == [0, 10]{ // How to use button
            dismiss(animated: true, completion: openHowToUsePageClosure)
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
