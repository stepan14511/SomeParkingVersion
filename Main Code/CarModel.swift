//
//  CarModel.swift
//  SideMenu
//
//  Created by Stepan Kuznetsov on 14.12.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation

struct Car: Codable {
    var id: Int
    var tariff: Int8?
    var parking_lot_type: Int8? // 0 - single, 1 - 2 cars
    var parking_lot_id: Int?
    var plates: String
    var payed_till: String?
    var is_auto_cont: Bool
    var main_card: Int
    var second_main_card: Int?
    var additional_cards: [Int?]
}

let tariffName: [Int8: String] = [0: "владелец", 1: "помесячно"]
// Tariffs:
// 0) Вледелец
// 1) Помесячно
// Остальные пока не юзаются
