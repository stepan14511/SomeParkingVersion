//
//  TariffMonthlyViewController.swift
//  ParkingApp
//
//  Created by Stepan Kuznetsov on 16.02.2021.
//  Copyright © 2021 jonkykong. All rights reserved.
//

import Foundation
import UIKit

class TariffMonthlyViewController: UIViewController{
    @IBOutlet var imageViewForZooming: UIView?
    @IBOutlet var scrollViewForZooming: UIScrollView?
    @IBOutlet var stackView: UIStackView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stackView?.bounds = CGRect(x: 10, y: 0, width: 50, height: 120)
    }
    
    @IBAction func cancelButtonPressed(){
        dismiss(animated: true, completion: nil)
    }
}

// Zoom and scroll of parking scheme
extension TariffMonthlyViewController: UIScrollViewDelegate, UIGestureRecognizerDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageViewForZooming
    }
    
    @IBAction func userDoubleTappedScrollview(recognizer:  UITapGestureRecognizer) {
        guard let scrollView = scrollViewForZooming else {return}
        
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        }
        else {            let zoomRect = zoomRectForScale(scale: scrollView.maximumZoomScale / 2.0, center: recognizer.location(in: recognizer.view))
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
