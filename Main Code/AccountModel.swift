//
//  AccountModel.swift
//  SideMenu
//
//  Created by Stepan Kuznetsov on 14.12.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation

struct Account: Decodable {
    var email: String
    var phone: Int64
    var full_name: String
    var balance: Int
    var cars: [Car]
}

class AccountModel {
    
    weak var delegate: Downloadable?
    let networkModel = Network()
    
    func downloadAccountData(parameters: [String: Any], url: String) {
        let request = networkModel.request(parameters: parameters, url: url)
        networkModel.response(request: request) { (data) in
            let model = try! JSONDecoder().decode(Account?.self, from: data) as Account?
            self.delegate?.didReceiveData(data: model! as Account)
        }
    }
}
