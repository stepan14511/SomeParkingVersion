//
//  TariffMonthlyTableViewcontroller.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 17.02.2021.
//  Copyright © 2021 jonkykong. All rights reserved.
//

import Foundation
import UIKit

class TariffMonthlyTableViewConroller: UITableViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
