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
    let model = AccountModel()
    
    @IBOutlet var addTransport: UIView?
    var vSpinner : UIView?
    
    var callbackClosure: (() -> Void)?
    var openLoginScreenClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting changePaymentSystem tap recogniser
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.addTransportPressed))
        self.addTransport!.addGestureRecognizer(gesture)
        
        model.delegate = self
        
        loadAccountFromServer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        callbackClosure?()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let cars = AccountController.account?.cars{
            return cars.count
        }
        else{
            return 0
        }
    }
    // create a cell for each table view row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        
        var cell = self.tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") as UITableViewCell?
        
        if cell == nil{
            
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "reuseIdentifier")
        }
        
        if let cars = AccountController.account?.cars{
            cell?.textLabel?.text = cars[indexPath.row].plates
            
            if let parking_lot_id = cars[indexPath.row].parking_lot_id{
                cell?.detailTextLabel?.text = "Парковочное место: " + String(parking_lot_id)
            }
            else{
                cell?.detailTextLabel?.text = ""
            }
            
        }
        else{
            cell?.textLabel?.text = ""
            cell?.detailTextLabel?.text = ""
        }
        cell?.detailTextLabel?.textColor = .systemGray
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        guard let account = AccountController.account,
              let car_id = account.cars?[row].id else{
            return
        }
        
        let storyboard = UIStoryboard(name: "CarEdit", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "carEdit_nav") as! UINavigationController
        
        guard let carEditViewController = secondViewController.children[0] as? CarEditViewController else{
            return
        }
        
        carEditViewController.openLoginScreenClosure = {self.dismiss(animated: true, completion: self.openLoginScreenClosure)}
        carEditViewController.updateAccountClosure = loadAccountFromServer
        carEditViewController.car_id = car_id
        
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    func loadAccountFromServer(){
        showSpinner(onView: self.view)
        
        guard let email = AccountController.email,
              let passhash = AccountController.password_hash
        else{
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unable to get app version"
        
        let param = ["ios_app_ver": appVersion, "email": email, "passhash": passhash]
        model.downloadAccountData(parameters: param, url: URLServices.login)
    }
    
    @objc func addTransportPressed(sender : UITapGestureRecognizer) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "carAdd_nav") as! UINavigationController
        
        guard let carAddViewController = secondViewController.children[0] as? CarAddViewController else{
            return
        }
        
        carAddViewController.openLoginScreenClosure = {self.dismiss(animated: true, completion: self.openLoginScreenClosure)}
        carAddViewController.updateAccountClosure = loadAccountFromServer
        
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    @IBAction func Exit(){
        dismiss(animated: true, completion: nil)
    }
}
 
extension TransportViewController {
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        self.vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            self.vSpinner?.removeFromSuperview()
            self.vSpinner = nil
        }
    }
}

extension TransportViewController: Downloadable{
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
                if error.code == 2{
                    dismiss(animated: true, completion: openLoginScreenClosure)
                    return
                }
                return
            }
            
            AccountController.account = account
            AccountController.saveDataToMemory()
            
            self.tableView.reloadData()
            removeSpinner()
        }
    }
}
