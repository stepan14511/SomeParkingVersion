//
//  HowToOwnerViewController.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 16.02.2021.
//  Copyright © 2021 jonkykong. All rights reserved.
//

import Foundation
import UIKit

class HowToOwnerViewContoller: UIViewController{
    
    @IBAction func cancelButtonPressed(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func phoneNumberPressed(){
        let number = URL(string: "tel://+74732075050")
        UIApplication.shared.open(number!)
    }
}
