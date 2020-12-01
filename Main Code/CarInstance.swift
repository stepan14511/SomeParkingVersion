//
//  CarInstance.swift
//  Example
//
//  Created by Stepan Kuznetsov on 30.10.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation

class CarInstance{
    var id: Int
    var tariff: Tariff?
    var parkingLotType: ParkingLotType?
    var parkingLotID: Int?
    var plates: String
    var payedTill: Date?
    var isAutoContinues: Bool = false
    var mainCard: String
    var secondMainCard: String?
    var additionalCards: [String] = []
    
    init(id: Int, plates: String, mainCard: String){
        self.id = id
        self.plates = plates
        self.mainCard = mainCard
    }
}

enum Tariff {
    case monthly
    case owner
}

enum ParkingLotType{
    
}
