//
//  ServerError.swift
//  SideMenu
//
//  Created by Stepan Kuznetsov on 16.12.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation

struct ServerError: Codable{
    var code: Int
    var message: String
    var subMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "err_num"
        case message = "err_message"
        case subMessage = "err_sub_message"
    }
}
