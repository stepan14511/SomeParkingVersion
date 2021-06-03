//
//  MainViewController.swift
//
//  Created by Jon Kent on 11/12/15.
//  Copyright © 2015 Jon Kent. All rights reserved.
//

import SideMenu

class MainViewController: UIViewController {
    private var menuSettings: SideMenuSettings = SideMenuSettings()
    var model = AccountModel()
    var justRegistered: Bool = false

    @IBOutlet weak var balanceShower: UIButton?
    @IBOutlet weak var imageViewForZooming: UIView?
    @IBOutlet weak var scrollViewForZooming: UIScrollView?
    @IBOutlet weak var stackView: UIStackView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let _ = AccountController.account else{
            openLoginScreen()
            return
        }
        
        // Fix buttons size cause I ❤️ storyboards.
        stackView?.bounds = CGRect(x: 0, y: 0, width: 50, height: 120)

        
        setupSideMenu()
        model.delegate = self
        
        loadAccountFromServer()
        
        updateAccountDataUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if justRegistered{
            justRegistered = false
            openAddCarViewController(isForced: true)
        }
    }
    
    func loadAccountFromServer(){
        guard let email = AccountController.email,
              let passhash = AccountController.password_hash
        else{
            openLoginScreen()
            return
        }
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unable to get app version"
        
        let param = ["ios_app_ver": appVersion, "email": email, "passhash": passhash]
        model.downloadAccountData(parameters: param, url: URLServices.login)
    }
    
    public func updateAccountDataUI(){
        guard let account = AccountController.account else{
            return
        }
        
        if let balanceShower = balanceShower{
            let formater = NumberFormatter()
            formater.locale = Locale(identifier: "ru_RU")
            formater.groupingSeparator = "."
            formater.numberStyle = .currency
            formater.currencySymbol = "₽"
            let formattedBalance = formater.string(from: NSNumber(value: account.balance))
            balanceShower.setTitle("Баланс: " + String(formattedBalance ?? "0,00 ₽"), for: .normal)
        }
    }
    
    private func setupSideMenu() {
        // Define the menu
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        SideMenuManager.default.leftMenuNavigationController = storyboard.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        
    }
    
    @IBAction func balanceButtonPressed(){
        openBalanceViewController()
    }
    
    @IBAction func myCarsButtonPressed(){
        openTransportViewController()
    }
    
    @IBAction func addCarButtonPressed(){
        openAddCarViewController()
    }
}

// Closures, opening other views
extension MainViewController{
    
    func openLoginScreen(){
        AccountController.password_hash = nil
        AccountController.account = nil
        AccountController.saveDataToMemory()
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "first_page") as! FirstPageViewController
        secondViewController.modalPresentationStyle = .fullScreen
        secondViewController.modalTransitionStyle = .flipHorizontal
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    func openAccountViewController(){
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        guard let accountNavigationViewController = storyboard.instantiateViewController(withIdentifier: "account_nav") as? UINavigationController else { return }
        
        guard let accountViewController = accountNavigationViewController.children[0] as? AccountViewController else{ return }
        
        accountViewController.openLoginScreenClosure = openLoginScreen
        
        self.present(accountNavigationViewController, animated: true, completion: nil)
    }
    
    func openBalanceViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let popolnitNavigationViewController = storyboard.instantiateViewController(withIdentifier: "payment_nav") as? UINavigationController else { return }
        
        guard let popolnitViewController = popolnitNavigationViewController.children[0] as? BalanceViewController else{ return }
        
        popolnitViewController.openLoginScreenClosure = openLoginScreen
        popolnitViewController.updateDataClosure = updateAccountDataUI
        
        self.present(popolnitNavigationViewController, animated: true, completion: nil)
    }
    
    func openTransportViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let transportNavigationViewController = storyboard.instantiateViewController(withIdentifier: "transport_nav") as? UINavigationController else { return }
        
        guard let transportViewController = transportNavigationViewController.children[0] as? TransportViewController else{
            return
        }
        
        transportViewController.callbackClosure = updateAccountDataUI
        transportViewController.openLoginScreenClosure = openLoginScreen
        
        self.present(transportNavigationViewController, animated: true, completion: nil)
    }
    
    func openHowToOwnerViewController(){
        let storyboard = UIStoryboard(name: "Tariffs", bundle: nil)
        guard let transportNavigationViewController = storyboard.instantiateViewController(withIdentifier: "howtoowner_nav") as? UINavigationController else { return }
        
        self.present(transportNavigationViewController, animated: true, completion: nil)
    }
    
    func openAddCarViewController(isForced: Bool = false){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let transportNavigationViewController = storyboard.instantiateViewController(withIdentifier: "carAdd_nav") as? UINavigationController else { return }
        
        guard let transportViewController = transportNavigationViewController.children[0] as? CarAddViewController else{
            return
        }
            
        transportViewController.openLoginScreenClosure = openLoginScreen
        transportViewController.successCallBackClosure = openTransportViewController
        if isForced{
            transportViewController.isSkippable = true
        }
            
        self.present(transportNavigationViewController, animated: true, completion: nil)
    }
}

extension MainViewController: SideMenuNavigationControllerDelegate {
    
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        guard let sideMenuTableViewController = menu.children[0] as? SideMenuTableViewController else{
            return
        }
        
        sideMenuTableViewController.callbackClosure = updateAccountDataUI
        sideMenuTableViewController.openLoginScreenClosure = openLoginScreen
        sideMenuTableViewController.openAccountViewControllerClosure = openAccountViewController
        sideMenuTableViewController.openPopolnitViewControllerClosure = openBalanceViewController
        sideMenuTableViewController.openTransportViewControllerClosure = openTransportViewController
        sideMenuTableViewController.openHowToOwnerViewControllerClosure = openHowToOwnerViewController
    }
    
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
    }
    
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
    }
}

// Zoom and scroll of parking scheme
extension MainViewController: UIScrollViewDelegate, UIGestureRecognizerDelegate{
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageViewForZooming
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

extension MainViewController: Downloadable{
    
    func didReceiveData(data param: Any?) {
        // The data model has been dowloaded at this point
        // Now, pass the data model to the Holidays table view controller
        DispatchQueue.main.sync{
            guard let data = param else{
                // Smthing strange, not server error
                return
            }
            
            guard let account = data as? Account else{
                guard let error = data as? ServerError else{
                    // This is literally impossible, but why not to leave it here)
                    return
                }
                
                // Server error
                if(error.code == 2){
                    openLoginScreen()
                }
                return
            }
            
            AccountController.account = account
            AccountController.saveDataToMemory()
            updateAccountDataUI()
        }
    }
}
