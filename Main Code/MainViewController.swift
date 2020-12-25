//
//  MainViewController.swift
//
//  Created by Jon Kent on 11/12/15.
//  Copyright © 2015 Jon Kent. All rights reserved.
//

import SideMenu

class MainViewController: UIViewController {
    private var menuSettings: SideMenuSettings = SideMenuSettings()
    var model = AccountModel()

    @IBOutlet weak var balanceShower: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let _ = AccountController.account else{
            openLoginScreen()
            return
        }
        
        setupSideMenu()
        model.delegate = self
        
        loadAccountFromServer()
        
        updateAccountDataUI()
    }
    
    func loadAccountFromServer(){
        guard let email = AccountController.email,
              let passhash = AccountController.password_hash
        else{
            openLoginScreen()
            return
        }
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unable to get app version"
        
        let param = ["ios_app_ver": appVersion, "email": email, "passhash": passhash]
        model.downloadAccountData(parameters: param, url: URLServices.login)
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
    
    private func setupSideMenu() {
        // Define the menu
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        
    }
}

// Closures, opening other views
extension MainViewController{
    
    func openLoginScreen(){
        AccountController.password_hash = nil
        AccountController.account = nil
        AccountController.saveDataToMemory()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "login") as! LoginViewController
        secondViewController.modalPresentationStyle = .fullScreen
        secondViewController.modalTransitionStyle = .flipHorizontal
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    func openTransportViewController(){
        guard let transportNavigationViewController = self.storyboard?.instantiateViewController(withIdentifier: "transport_nav") as? UINavigationController else { return }
        
        guard let transportViewController = transportNavigationViewController.children[0] as? TransportViewController else{
            return
        }
        
        transportViewController.callbackClosure = updateAccountDataUI
        transportViewController.openLoginScreenClosure = openLoginScreen
        
        self.present(transportNavigationViewController, animated: true, completion: nil)
    }
    
    func openPopolnitViewController(){
        guard let popolnitController = self.storyboard?.instantiateViewController(withIdentifier: "payment") as? PopolnitViewController else { return }
        
        popolnitController.callbackClosure = updateAccountDataUI
        popolnitController.openLoginScreenClosure = openLoginScreen
        
        self.present(popolnitController, animated: true, completion: nil)
    }
}

extension MainViewController: SideMenuNavigationControllerDelegate {
    
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        guard let sideMenuTableViewController = menu.children[0] as? SideMenuTableViewController else{
            return
        }
        
        sideMenuTableViewController.callbackClosure = updateAccountDataUI
        sideMenuTableViewController.openLoginScreenClosure = openLoginScreen
        sideMenuTableViewController.openTransportViewControllerClosure = openTransportViewController
        sideMenuTableViewController.openPopolnitViewControllerClosure = openPopolnitViewController
    }
    
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
    }
    
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
    }
}

extension MainViewController: Downloadable{
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
                    // This is literally impossible, but why not to leave it here)
                    return
                }
                
                // Server error
                if(error.code == 2){
                    openLoginScreen()
                }
                return
            }
            
            AccountController.account = account
            AccountController.saveDataToMemory()
            updateAccountDataUI()
        }
    }
}
