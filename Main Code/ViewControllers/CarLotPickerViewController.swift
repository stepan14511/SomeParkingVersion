//
//  TariffMonthlyViewController.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 16.02.2021.
//  Copyright © 2021 jonkykong. All rights reserved.
//

import Foundation
import UIKit

class CarLotPickerViewController: UIViewController{
    var modelParking = ParkingLotsModel()
    var modelAccount = AccountModel()
    var vSpinner : UIView?
    var usersPickedLot: String?
    var car_id: Int?
    var isSkippable: Bool = false
    var availableLots: [ParkingLot]?
    
    @IBOutlet var doneButton: UIButton?
    @IBOutlet var cancelButton: UIButton?
    @IBOutlet var imageViewForZooming: UIView?
    @IBOutlet var scrollViewForZooming: UIScrollView?
    @IBOutlet var stackView: UIStackView?
    @IBOutlet var containerView: UIView?
    var carLotPickerTableViewController: CarLotPickerTableViewController?

    var openLoginScreenClosure: (() -> Void)?
    var updateViewAfterDataChangeClosure: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fix zoom buttons size
        stackView?.bounds = CGRect(x: 0, y: 0, width: 50, height: 120)
        
        cancelButton?.setTitle(isSkippable ? "Пропустить" : "Отменить", for: .normal)
        
        modelParking.delegate = self
        modelAccount.delegate = self
        checkDoneButtonState()
        
        // Setup tableview
        carLotPickerTableViewController = self.children[0] as? CarLotPickerTableViewController
        guard carLotPickerTableViewController != nil else{
            dismiss(animated: true, completion: updateViewAfterDataChangeClosure)
            return
        }
        carLotPickerTableViewController!.pickerViewToggledClosure = pickerViewToggled(isHidden:)
        carLotPickerTableViewController!.responseOnInputFromPickerViewClosure = responseToUserInputFromPickerView(lot:)
            
        // Setup tableview size
        pickerViewToggled(isHidden: true)
        
        // Download available places
        downloadAvailablePlacesFromServer()
    }
    
    func pickerViewToggled(isHidden: Bool){
        guard let bounds = containerView?.frame else {return}
        if isHidden{
            UIView.animate(withDuration: 0.25, animations: {
                self.containerView?.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: 80)
            })
        }
        else{
            UIView.animate(withDuration: 0.25, animations: {
                self.containerView?.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: 245)
            })
        }
    }
    
    func updateUI(){
        let controller = self.children[0] as! CarLotPickerTableViewController
        controller.availableParkingLots = availableLots
        if let car = AccountController.getCarById(id: car_id),
           let lot_id = car.parking_lot_id,
           let lot_type = car.parking_lot_type{
            let currLot = ParkingLot(id: lot_id, type: lot_type)
            controller.currentParkingLot = currLot
        }
    }
    
    func downloadAvailablePlacesFromServer(){
        showSpinner(onView: self.view)
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unable to get app version"
        
        let param = ["ios_app_ver": appVersion]
        modelParking.downloadParkingLotsData(parameters: param, url: URLServices.getAvailableParkingLots)
    }
    
    func responseToUserInputFromPickerView(lot: String){
        usersPickedLot = lot
        checkDoneButtonState()
    }
    
    func checkDoneButtonState(){
        var currentLot: ParkingLot?
        if let car = AccountController.getCarById(id: car_id),
           let lot_id = car.parking_lot_id,
           let lot_type = car.parking_lot_type{
            let currLot = ParkingLot(id: lot_id, type: lot_type)
            currentLot = currLot
        }
        if currentLot == nil{
            if let pickedLot = usersPickedLot,
               pickedLot != "-"{
                doneButton?.isEnabled = true
            }
            else{
                doneButton?.isEnabled = false
            }
        }
        else{
            if let pickedLot = usersPickedLot,
               pickedLot != currentLot?.id{
                doneButton?.isEnabled = true
            }
            else{
                doneButton?.isEnabled = false
            }
        }
    }
    
    @IBAction func cancelButtonPressed(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(){
        showSpinner(onView: self.view)
        
        guard let email = AccountController.email,
              let passhash = AccountController.password_hash,
              let car_id = AccountController.getCarById(id: car_id)?.id
        else{
            dismiss(animated: true, completion: openLoginScreenClosure)
            return
        }
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unable to get app version"
        
        var param = ["ios_app_ver": appVersion, "email": email, "passhash": passhash, "car_id": car_id] as [String : Any]
        
        if let pickedLot = usersPickedLot,
           pickedLot != "-"{
            param["new_lot"] = pickedLot
        }
        modelAccount.downloadAccountData(parameters: param, url: URLServices.updateParkingLot)
    }
    
    func openPayScreen(){
        let storyboard = UIStoryboard(name: "CarEdit", bundle: nil)
        guard let newViewController = storyboard.instantiateViewController(withIdentifier: "autopay") as? CarAutopayViewController else { dismiss(animated: true, completion: updateViewAfterDataChangeClosure)
            return
        }
        newViewController.car_id = car_id
        newViewController.openLoginScreenClosure = {self.dismiss(animated: true, completion: self.openLoginScreenClosure)}
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
}

// Zoom and scroll of parking scheme
extension CarLotPickerViewController: UIScrollViewDelegate, UIGestureRecognizerDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageViewForZooming
    }
    
    @IBAction func userDoubleTappedScrollview(recognizer:  UITapGestureRecognizer) {
        guard let scrollView = scrollViewForZooming else {return}
        
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
        else {
            let zoomRect = zoomRectForScale(scale: scrollView.maximumZoomScale / 2.0, center: recognizer.location(in: recognizer.view))
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }

    func zoomRectForScale(scale : CGFloat, center : CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        if let imageV = self.scrollViewForZooming {
            zoomRect.size.height = imageV.frame.size.height / scale;
            zoomRect.size.width  = imageV.frame.size.width  / scale;
            let newCenter = center
            zoomRect.origin.x = newCenter.x - ((zoomRect.size.width / 2.0));
            zoomRect.origin.y = newCenter.y - ((zoomRect.size.height / 2.0));
        }
        return zoomRect;
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
    
    @IBAction func zoomInButtonPressed(){
        guard let scrollView = scrollViewForZooming else {return}
        if scrollView.zoomScale >= 1 && scrollView.zoomScale < 1.7{
            scrollView.setZoomScale(2, animated: true)
        }
        else if scrollView.zoomScale >= 1.7 && scrollView.zoomScale < 3.4{
            scrollView.setZoomScale(4, animated: true)
        }
        else if scrollView.zoomScale != scrollView.maximumZoomScale{
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    @IBAction func zoomOutButtonPressed(){
        guard let scrollView = scrollViewForZooming else {return}
        if scrollView.zoomScale >= 1 && scrollView.zoomScale < 2.4{
            scrollView.setZoomScale(1, animated: true)
        }
        else if scrollView.zoomScale >= 2.4 && scrollView.zoomScale < 4.1{
            scrollView.setZoomScale(2, animated: true)
        }
        else{
            scrollView.setZoomScale(3.5, animated: true)
        }
    }
}

extension CarLotPickerViewController {
    
    func showSpinner(onView : UIView) {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = CGPoint(x: screenWidth / 2, y: screenHeight * 0.4)
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        self.vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            if let superview = self.vSpinner?.superview{
                UIView.transition(with: superview, duration: 0.25, options: .transitionCrossDissolve, animations: {
                        self.vSpinner?.removeFromSuperview()
                        self.vSpinner = nil
                    }, completion: nil)
            }
        }
    }
}

extension CarLotPickerViewController: Downloadable{
    
    func didReceiveData(data param: Any?) {
        // The data model has been dowloaded at this point
        // Now, pass the data model to the Holidays table view controller
        DispatchQueue.main.sync{
            guard let data = param else{
                // Smthing strange, not server error
                return
            }
            
            guard let lots = data as? [ParkingLot] else{
                guard let account = data as? Account else{
                    guard let error = data as? ServerError else{
                        // This is literally impossible, but why not to leave it here)
                        return
                    }
                    
                    // Server error
                    if error.code == 2{
                        dismiss(animated: true, completion: openLoginScreenClosure)
                        return
                    }
                    return
                }
                
                
                // Successful payment
                
                AccountController.account = account
                AccountController.saveDataToMemory()
                openPayScreen()
                //dismiss(animated: true, completion: updateViewAfterDataChangeClosure)
                return
            }
            
            // Just got parking lots
            availableLots = lots
            if let car = AccountController.getCarById(id: car_id),
               let lot_id = car.parking_lot_id,
               let lot_type = car.parking_lot_type{
                let currLot = ParkingLot(id: lot_id, type: lot_type)
                carLotPickerTableViewController?.responseOnUserInputFromPickerView(lot: currLot.id ?? "-")
            }
            updateUI()
            removeSpinner()
        }
    }
    
    // DO NOT TOUCH PLS. It works for now, but may be broken easily in the future.
    func sortAvailableLots(left: ParkingLot, right: ParkingLot) -> Bool{
        guard left.id != nil else{
            return false
        }
        guard right.id != nil else{
            return true
        }
        var left_id = Int(left.id!)
        var right_id = Int(right.id!)
        if left_id != nil{
            left_id = left_id! * 10
        }
        else{
            left_id = Int(left.id![...String.Index(encodedOffset: left.id!.count - 2)])
            guard left_id != nil else {
                return false
            }
            left_id = left_id! * 10
            if left.id!.last == "а"{
                left_id! += 1
            }
            else{
                left_id! += 2
            }
        }
        if right_id != nil{
            right_id = right_id! * 10
        }
        else{
            right_id = Int(right.id![...String.Index(encodedOffset: right.id!.count - 2)])
            guard right_id != nil else {
                return true
            }
            right_id = right_id! * 10
            if right.id!.last == "а"{
                right_id! += 1
            }
            else{
                right_id! += 2
            }
        }
        return left_id! < right_id!
    }
}
