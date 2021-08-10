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

        self.registerTableViewCells()
        
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
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TransportTableViewCell") as! TransportTableViewCell?
        
//        if cell == nil{
//            //cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "CustomTableViewCell")
//            if let cars = AccountController.account?.cars?.sorted(by: {$0.id < $1.id}){
//                cell?.textLabel?.text = cars[indexPath.row].plates
//
//                if let parking_lot_id = cars[indexPath.row].parking_lot_id{
//                    cell?.detailTextLabel?.text = "Парковочное место: " + String(parking_lot_id)
//                }
//                else{
//                    cell?.detailTextLabel?.text = ""
//                }
//
//            }
//            else{
//                cell?.textLabel?.text = ""
//                cell?.detailTextLabel?.text = ""
//            }
//            //cell?.detailTextLabel?.textColor = .systemGray
//            return cell!
//        }
        if let cars = AccountController.account?.cars?.sorted(by: {$0.id < $1.id}){
            cell?.car_id = cars[indexPath.row].id
            cell?.updateUI()
            cell?.platesButtonFunction = platesButtonPressed(_:)
            cell?.lotButtonFunction = lotButtonPressed(_:)
            cell?.balanceButtonFunction = balanceButtonPressed(_:)
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        guard let car_id = AccountController.getCarByPlates(plates: cell?.textLabel?.text)?.id else{
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
    
    private func registerTableViewCells() {
        let textFieldCell = UINib(nibName: "TransportTableViewCell",
                                  bundle: nil)
        self.tableView.register(textFieldCell,
                                forCellReuseIdentifier: "TransportTableViewCell")
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
        carAddViewController.successCallBackClosure = loadAccountFromServer
        
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    @IBAction func Exit(){
        dismiss(animated: true, completion: nil)
    }
    
}

// Funcs for cells
extension TransportViewController{
    func platesButtonPressed(_ car_id: Int?){
        guard let car_id = AccountController.getCarById(id: car_id)?.id else{
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
    
    func lotButtonPressed(_ car_id: Int?){
        let storyboard = UIStoryboard(name: "Tariffs", bundle: nil)
        
        guard let accountNavigationViewController = storyboard.instantiateViewController(withIdentifier: "car_lot_nav") as? UINavigationController else { return }
        
        guard let accountViewController = accountNavigationViewController.children[0] as? CarLotPickerViewController else{ return }
        
        accountViewController.car_id = car_id
        accountViewController.openLoginScreenClosure = {self.dismiss(animated: true, completion: self.openLoginScreenClosure)}
        accountViewController.updateViewAfterDataChangeClosure = loadAccountFromServer
        
        self.present(accountNavigationViewController, animated: true, completion: nil)
    }
    
    func balanceButtonPressed(_ car_id: Int?){
        guard let car = AccountController.getCarById(id: car_id) else {
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        let storyboard = UIStoryboard(name: "CarEdit", bundle: nil)
        guard let autopayNavigationViewController = storyboard.instantiateViewController(withIdentifier: "autopay_nav") as? UINavigationController else { return }
        
        guard let autopayViewController = autopayNavigationViewController.children[0] as? CarAutopayViewController else{ return }
        
        autopayViewController.car_id = car.id
        autopayViewController.openLoginScreenClosure = {self.dismiss(animated: true, completion: self.openLoginScreenClosure)}
        //autopayViewController.updateUIClosure = updateRowsText
        
        self.present(autopayNavigationViewController, animated: true, completion: nil)
    }
}
 
extension TransportViewController {
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        let screenWidth = UIScreen.main.bounds.maxX / 2 - spinnerView.frame.minX
        let screenHeight = UIScreen.main.bounds.maxY * 0.4 - spinnerView.frame.minY
        
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = CGPoint(x: screenWidth, y: screenHeight)
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        self.vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            if let superview = self.vSpinner?.superview{
                UIView.transition(with: superview, duration: 0.25, options: .transitionCrossDissolve, animations: {
                        self.vSpinner?.removeFromSuperview()
                        self.vSpinner = nil
                    }, completion: nil)
            }
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
