//
//  SettingsViewController.swift
//  Nomosi_Example
//
//  Created by Mario on 14/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit
import Nomosi

class SettingsViewController: UIViewController {
    
    @IBAction private func clearCacheButtonTapped() {
        let objectsViewController = (tabBarController?.childViewControllers.first as? UINavigationController)?.childViewControllers.first as? ObjectsViewController
        objectsViewController?.resetDataSource()
        Cache.removeAllCachedResponses() 
    }
    
}
