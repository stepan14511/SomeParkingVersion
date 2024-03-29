//
//  Network.swift
//  This is a reusable API that provides a
//
//  Created by Jose's Work Station on 6/5/19.
//  Copyright © 2019 Jose Ortiz. All rights reserved.
//

import Foundation

protocol Downloadable: class {
    func didReceiveData(data: Any?)
}

enum URLServices {
    static let login: String = "https://mpaefcslpsoskmjikdn.ru/Parking/login.php"
    static let registration: String = "https://mpaefcslpsoskmjikdn.ru/Parking/registration.php"
    static let updateFIO: String = "https://mpaefcslpsoskmjikdn.ru/Parking/updateFIO.php"
    static let payment: String = "https://mpaefcslpsoskmjikdn.ru/Parking/payment.php"
    static let addCar: String = "https://mpaefcslpsoskmjikdn.ru/Parking/addCar.php"
    static let deleteCar: String = "https://mpaefcslpsoskmjikdn.ru/Parking/deleteCar.php"
    static let updateCards: String = "https://mpaefcslpsoskmjikdn.ru/Parking/updateCards.php"
    static let updateTariff: String = "https://mpaefcslpsoskmjikdn.ru/Parking/updateTariff.php"
    static let updateAutoPay: String = "https://mpaefcslpsoskmjikdn.ru/Parking/updateAutoPay.php"
    static let getAvailableParkingLots: String = "https://mpaefcslpsoskmjikdn.ru/Parking/getAvailableParkingLots.php"
    static let updateParkingLot: String = "https://mpaefcslpsoskmjikdn.ru/Parking/updateParkingLot.php"
    static let updatePlates: String = "https://mpaefcslpsoskmjikdn.ru/Parking/updatePlates.php"
}

class Network {
    
    func request(parameters: [String: Any], url: String) -> URLRequest {
        
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        request.httpBody = parameters.percentEscaped().data(using: .utf8)
        return request
    }
    
    func response(request: URLRequest, errorClosure: @escaping ((URLResponse?, Error?) -> Void), completionBlock: @escaping (Data) -> Void) -> Void {
        
        let task = URLSession.shared.dataTask(with: request) { data, _response, error in
            guard let data = data,
                let response = _response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    errorClosure(_response, error)
                    print("error", error ?? "Unknown error")
                    return
            }
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                errorClosure(_response, error)
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            completionBlock(data);
        }
        task.resume()
    }
    
    func response(request: URLRequest, completionBlock: @escaping (Data) -> Void) -> Void {
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            completionBlock(data);
        }
        task.resume()
    }
    
    func response(request: URLRequest) -> Void {
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
        }
        task.resume()
    }
}

extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
