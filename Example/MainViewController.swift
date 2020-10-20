//
//  MainViewController.swift
//
//  Created by Jon Kent on 11/12/15.
//  Copyright © 2015 Jon Kent. All rights reserved.
//

import SideMenu

class MainViewController: UIViewController {
    private var menuSettings: SideMenuSettings = SideMenuSettings()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSideMenu()
        /*menuSettings.menuWidth = view.frame.width * 0.9
        
        
        let presentationStyle = SideMenuPresentationStyle.menuSlideIn
        //presentationStyle.menuStartAlpha = CGFloat(menuAlphaSlider.value)
        //presentationStyle.menuScaleFactor = CGFloat(menuScaleFactorSlider.value)
        //presentationStyle.onTopShadowOpacity = shadowOpacitySlider.value
        //presentationStyle.presentingEndAlpha = CGFloat(presentingAlphaSlider.value)
        //presentationStyle.presentingScaleFactor = CGFloat(presentingScaleFactorSlider.value)
         
        menuSettings.presentationStyle = presentationStyle
        //screenWidthSlider.value = Float(settings.menuWidth / min(view.frame.width, view.frame.height))
        //updateUI(settings: settings)
        updateMenus()*/
    }

    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sideMenuNavigationController = segue.destination as? SideMenuNavigationController else { return }
        sideMenuNavigationController.settings = makeSettings()
    }*/
    
    private func setupSideMenu() {
        // Define the menus
        SideMenuManager.default.leftMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        
    }
    
    /*private func updateUI(settings: SideMenuSettings) {
        //blackOutStatusBar.isOn = settings.statusBarEndAlpha > 0
        //menuAlphaSlider.value = Float(settings.presentationStyle.menuStartAlpha)
        //menuScaleFactorSlider.value = Float(settings.presentationStyle.menuScaleFactor)
        //presentingAlphaSlider.value = Float(settings.presentationStyle.presentingEndAlpha)
        //presentingScaleFactorSlider.value = Float(settings.presentationStyle.presentingScaleFactor)
        //screenWidthSlider.value = Float(settings.menuWidth / min(view.frame.width, view.frame.height))
        //shadowOpacitySlider.value = Float(settings.presentationStyle.onTopShadowOpacity)
    }*/

    /*@IBAction private func changeControl(_ control: UIControl) {
        if control == presentationStyleSegmentedControl {
            var settings = makeSettings()
            settings.presentationStyle = SideMenuPresentationStyle.menuSlideIn
            updateUI(settings: settings)
        }
        updateMenus()
    }*/

    /*private func updateMenus() {
        SideMenuManager.default.leftMenuNavigationController?.settings = menuSettings
    }*/

    /*private func makeSettings() -> SideMenuSettings {
        let presentationStyle = SideMenuPresentationStyle.menuSlideIn
        presentationStyle.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
        presentationStyle.menuStartAlpha = CGFloat(menuAlphaSlider.value)
        presentationStyle.menuScaleFactor = CGFloat(menuScaleFactorSlider.value)
        presentationStyle.onTopShadowOpacity = shadowOpacitySlider.value
        presentationStyle.presentingEndAlpha = CGFloat(presentingAlphaSlider.value)
        presentationStyle.presentingScaleFactor = CGFloat(presentingScaleFactorSlider.value)

        var settings = SideMenuSettings()
        settings.presentationStyle = presentationStyle
        settings.menuWidth = min(view.frame.width, view.frame.height) * CGFloat(screenWidthSlider.value)
        let styles:[UIBlurEffect.Style?] = [nil, .dark, .light, .extraLight]
        settings.blurEffectStyle = styles[blurSegmentControl.selectedSegmentIndex]
        settings.statusBarEndAlpha = blackOutStatusBar.isOn ? 1 : 0

        return settings
    }*/
}

extension MainViewController: SideMenuNavigationControllerDelegate {
    
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appearing! (animated: \(animated))")
    }
    
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appeared! (animated: \(animated))")
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappearing! (animated: \(animated))")
    }
    
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappeared! (animated: \(animated))")
    }
}
