//
//  MainViewController.swift
//
//  Created by Jon Kent on 11/12/15.
//  Copyright © 2015 Jon Kent. All rights reserved.
//

import SideMenu

class MainViewController: UIViewController {
    private var menuSettings: SideMenuSettings = SideMenuSettings()
    static var doOpenLogin: Bool = false // Some kosltyl for being able to update account while auto-login

    @IBOutlet weak var balanceShower: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSideMenu()
        
        updateAccountDataUI()
    }
    
    private func setupSideMenu() {
        // Define the menus
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        
    }
    
    public func updateAccountDataUI(){
        guard let account = AccountController.account else{
            return
        }
        
        if let _ = balanceShower{
            let formater = NumberFormatter()
            formater.locale = Locale(identifier: "ru_RU")
            formater.groupingSeparator = "."
            formater.numberStyle = .currency
            formater.currencySymbol = "₽"
            let formattedBalance = formater.string(from: NSNumber(value: account.balance))
            balanceShower!.setTitle(String(formattedBalance ?? "0,00 ₽"), for: .normal)
        }
        
    }
}

extension MainViewController: SideMenuNavigationControllerDelegate {
    
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
    }
    
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
    }
    
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        if(MainViewController.doOpenLogin){
            MainViewController.doOpenLogin = false
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondViewController = storyboard.instantiateViewController(withIdentifier: "login") as! LoginViewController
            secondViewController.modalPresentationStyle = .fullScreen
            secondViewController.modalTransitionStyle = .flipHorizontal
            self.present(secondViewController, animated: true, completion: nil)
        }
        
        updateAccountDataUI()
    }
}
