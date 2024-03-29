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
    var parking_lot_type: Int8? // 1 - standart, 2 - extended, 3 - 2-cars.
    var parking_lot_id: String?
    var plates: String
    var payed_till: Date?
    var is_auto_cont: Bool
    var main_card: Int
    var second_main_card: Int?
}

let tariffName: [Int8: String] = [0: "ежедневно", 1: "помесячно", 2: "собственник"]
// Tariffs:
// 0) Ежедневно
// 1) Помесячно
// 2) Вледелец
// Остальные пока не юзаются
