//
//  ParkingLotsModel.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 17.02.2021.
//  Copyright © 2021 jonkykong. All rights reserved.
//

import Foundation

struct ParkingLot: Codable {
    var id: String?
    var type: Int8?
}

class ParkingLotsModel {
    
    weak var delegate: Downloadable?
    let networkModel = Network()
    
    func downloadParkingLotsData(parameters: [String: Any], url: String) {
        let request = networkModel.request(parameters: parameters, url: url)
        
        networkModel.response(request: request) { (data) in
            var model: Any?
            let decoder = JSONDecoder()
            do{
                model = try decoder.decode([ParkingLot]?.self, from: data) as [ParkingLot]? as Any?
            } catch {
                model = try? decoder.decode(ServerError?.self, from: data) as ServerError? as Any?
            }
            self.delegate?.didReceiveData(data: model)
        }
    }
}


