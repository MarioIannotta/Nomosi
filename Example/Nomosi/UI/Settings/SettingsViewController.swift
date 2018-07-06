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
    
    @IBOutlet private weak var resetCacheButton: UIButton!
    @IBOutlet private weak var cacheTimeoutStackView: UIStackView!
    @IBOutlet private weak var cachePolicySegmentControl: UISegmentedControl!
    @IBOutlet private weak var cacheTimeoutSegmentControl: UISegmentedControl!
    
    enum Timeout: Int {
        
        case thirtySeconds = 0
        case oneMinute = 1
        case fiveMinutes = 2
        case oneHour = 3
        
        var value: TimeInterval {
            switch self {
            case .thirtySeconds:
                return 30
            case .oneMinute:
                return 60
            case .fiveMinutes:
                return 60*5
            case .oneHour:
                return 60*60
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshCacheSettings()
    }
    
    @IBAction private func clearCacheButtonTapped() {
        let objectsViewController = (tabBarController?.childViewControllers.first as? UINavigationController)?.childViewControllers.first as? ObjectsViewController
        objectsViewController?.resetDataSource()
        Cache.removeAllCachedResponses() 
    }
    
    @IBAction private func networkErrorSwitchValueChanged(_ sender: UISwitch) {
        AppConfig.isNetworkErrorActive = sender.isOn
    }
    
    @IBAction private func slowDownNetworkSwitchValueChanged(_ sender: UISwitch) {
        AppConfig.slowDownNetworkRequest = sender.isOn
    }
    
    @IBAction private func cacheSegmentControlValueChanged(_ sender: UISegmentedControl) {
        refreshCacheSettings()
    }
    
    @IBAction private func cacheSegmentControlTimeoutValueChanged(_ sender: UISegmentedControl) {
        refreshCacheSettings()
    }
    
    @IBAction private func logValueChanged(_ sender: UISegmentedControl) {
        AppConfig.logLevel = Log(rawValue: sender.selectedSegmentIndex) ?? .minimal
    }
    
    private func refreshCacheSettings() {
        let timeout = Timeout(rawValue: cacheTimeoutSegmentControl.selectedSegmentIndex) ?? .thirtySeconds
        switch cachePolicySegmentControl.selectedSegmentIndex {
        case 0:
            AppConfig.cachePolicy = .none
        case 1:
            AppConfig.cachePolicy = .inRam(timeout: timeout.value)
        case 2:
            AppConfig.cachePolicy = .onDisk(timeout: timeout.value)
        default:
            break
        }
        setCacheConfigurationHidden(cachePolicySegmentControl.selectedSegmentIndex == 0)
    }
    
    private func setCacheConfigurationHidden(_ isHidden: Bool) {
        cacheTimeoutStackView.isHidden = isHidden
        resetCacheButton.isHidden = isHidden
    }
    
}
