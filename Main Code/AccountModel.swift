//
//  AccountModel.swift
//  SideMenu
//
//  Created by Stepan Kuznetsov on 14.12.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation

struct Account: Codable {
    var email: String
    var phone: String
    var surname: String
    var name: String
    var patronymic: String?
    var balance: Int
    var cars: [Car]?
}

class AccountModel {
    
    weak var delegate: Downloadable?
    let networkModel = Network()
    
    func downloadAccountData(parameters: [String: Any], url: String) {
        let request = networkModel.request(parameters: parameters, url: url)
        
        networkModel.response(request: request) { (data) in
            var model: Any?
            let decoder =  JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do{
                model = try decoder.decode(Account?.self, from: data) as Account? as Any?
                print(model)
            } catch {
                do{
                    model = try decoder.decode(ServerError?.self, from: data) as ServerError? as Any?
                } catch {
                    model = try? decoder.decode(ServerSuccess?.self, from: data) as ServerSuccess? as Any?
                }
            }
            self.delegate?.didReceiveData(data: model)
        }
    }
}

