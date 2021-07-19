//
//  FirstPageViewController.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 25.05.2021.
//  Copyright © 2021 stepan14511. All rights reserved.
//

import Foundation
import UIKit

class FirstPageViewController: UIViewController{
    
    var isRegOpenedLast: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonPressed(){
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        guard let loginNavigationViewController = storyboard.instantiateViewController(withIdentifier: "login_nav") as? UINavigationController else { return }
        
        guard let loginViewController = loginNavigationViewController.children[0] as? LoginViewController else{ return }
        
        loginViewController.openMainViewClosure = openMainView
        isRegOpenedLast = false
        
        self.present(loginNavigationViewController, animated: true, completion: nil)
    }
    
    @IBAction func registrationButtonPressed(){
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        guard let registrationNavigationViewController = storyboard.instantiateViewController(withIdentifier: "registration_nav") as? UINavigationController else { return }
        
        guard let registrationViewController = registrationNavigationViewController.children[0] as? RegistrationViewController else{ return }
        
        registrationViewController.openMainViewClosure = openMainView
        isRegOpenedLast = true 
        
        self.present(registrationNavigationViewController, animated: true, completion: nil)
    }
    
    func openMainView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "main") as! MainViewController
        secondViewController.modalPresentationStyle = .fullScreen
        secondViewController.modalTransitionStyle = .flipHorizontal
        secondViewController.justRegistered = isRegOpenedLast
        self.present(secondViewController, animated: true, completion: nil)
    }
}
