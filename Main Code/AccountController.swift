//
//  AccountController.swift
//  Example
//
//  Created by Stepan Kuznetsov on 30.10.2020.
//  Copyright © 2020 jonkykong. All rights reserved.
//

import Foundation

class AccountController{
    static var id: Int?
    static var fullName: String?
    static var email: String?
    static var phone: String?
    static var passwordHash: String?
    static var balance: Int = 0
    static var cars: [CarInstance] = []
}
