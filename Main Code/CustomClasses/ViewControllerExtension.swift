//
//  ViewControllerExtension.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 04.04.2021.
//  Copyright © 2021 stepan14511. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func setUpDismissKeyboardOutsideTouch() {
       let tap: UITapGestureRecognizer = UITapGestureRecognizer( target:     self, action:    #selector(UIViewController.dismissKeyboardTouchOutside))
       tap.cancelsTouchesInView = false
       view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboardTouchOutside() {
       view.endEditing(true)
    }
}
