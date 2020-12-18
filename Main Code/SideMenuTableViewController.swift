//
//  SideMenuTableViewController.swift
//  SideMenu
//
//  Created by Jon Kent on 4/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import SideMenu

class SideMenuTableViewController: UITableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh cell blur effect in case it changed
        tableView.reloadData()
        
        guard let menu = navigationController as? SideMenuNavigationController, menu.blurEffectStyle == nil else {
            return
        }
        
        // Set up a cool background image for demo purposes
        //let imageView = UIImageView(image: #imageLiteral(resourceName: "saturn"))
        //imageView.contentMode = .scaleAspectFit
        //imageView.backgroundColor = UIColor.white
        tableView.backgroundView?.backgroundColor = UIColor.black
        
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
            AccountController.password_hash = nil
            AccountController.account = nil
            AccountController.saveDataToMemory()
            
            MainViewController.doOpenLogin = true
            dismiss(animated: true, completion: nil)
        }
    }
    
}
