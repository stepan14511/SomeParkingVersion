//
//  CarModel.swift
//  SideMenu
//
//  Created by Stepan Kuznetsov on 14.12.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation

struct Car: Decodable {
    var id: Int
    var tariff: Int8
    var parking_lot_type: Int8
    var parking_lot_id: Int
    var plates: String
    var payed_till: Date
    var is_auto_cont: Bool
    var main_card: Int
    var second_main_card: Int
    var additional_cards: [Int]
}
