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
    @IBOutlet private weak var networkErrorSwitch: UISwitch!
    @IBOutlet private weak var delayNetworkRequestSwitch: UISwitch!
    
    enum Timeout: TimeInterval {
        
        case thirtySeconds = 30
        case oneMinute = 60
        case fiveMinutes = 300
        case oneHour = 1440
        
        var index: Int {
            switch self {
            case .thirtySeconds:
                return 0
            case .oneMinute:
                return 1
            case .fiveMinutes:
                return 2
            case .oneHour:
                return 3
            }
        }
        
        init?(index: Int) {
            switch index {
            case 0:
                self = .thirtySeconds
            case 1:
                self = .oneMinute
            case 2:
                self = .fiveMinutes
            case 3:
                self = .oneHour
            default:
                return nil
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCacheSettings()
        networkErrorSwitch.isOn = AppConfig.isNetworkErrorActive
        delayNetworkRequestSwitch.isOn = AppConfig.isNetworkRequestDelayEnabled
    }
    
    @IBAction private func clearCacheButtonTapped() {
        let objectsViewController = (tabBarController?.children.first as? UINavigationController)?.children.first as? ObjectsViewController
        objectsViewController?.resetDataSource()
        URLCache.shared.removeAllCachedResponses() 
    }
    
    @IBAction private func networkErrorSwitchValueChanged(_ sender: UISwitch) {
        AppConfig.isNetworkErrorActive = sender.isOn
    }
    
    @IBAction private func slowDownNetworkSwitchValueChanged(_ sender: UISwitch) {
        AppConfig.isNetworkRequestDelayEnabled = sender.isOn
    }
    
    @IBAction private func cacheSegmentControlValueChanged(_ sender: UISegmentedControl) {
        storeCacheSettings()
    }
    
    @IBAction private func cacheSegmentControlTimeoutValueChanged(_ sender: UISegmentedControl) {
        storeCacheSettings()
    }
    
    @IBAction private func logValueChanged(_ sender: UISegmentedControl) {
        AppConfig.logLevel = Log(rawValue: sender.selectedSegmentIndex) ?? .minimal
    }
    
    private func storeCacheSettings() {
        let timeout = Timeout(index: cacheTimeoutSegmentControl.selectedSegmentIndex)?.rawValue ?? 0
        switch cachePolicySegmentControl.selectedSegmentIndex {
        case 0:
            AppConfig.cachePolicy = .none
        case 1:
            AppConfig.cachePolicy = .inRam(timeout: timeout)
        case 2:
            AppConfig.cachePolicy = .onDisk(timeout: timeout)
        default:
            break
        }
        hideCacheConfigurationIfNeeded()
    }
    
    private func loadCacheSettings() {
        switch AppConfig.cachePolicy {
        case .none:
            cachePolicySegmentControl.selectedSegmentIndex = 0
        case .inRam(let timeout):
            cachePolicySegmentControl.selectedSegmentIndex = 1
            cacheTimeoutSegmentControl.selectedSegmentIndex = Timeout(rawValue: timeout)?.index ?? 0
        case .onDisk(let timeout):
            cachePolicySegmentControl.selectedSegmentIndex = 2
            cacheTimeoutSegmentControl.selectedSegmentIndex = Timeout(rawValue: timeout)?.index ?? 0
        }
        hideCacheConfigurationIfNeeded()
    }
    
    private func hideCacheConfigurationIfNeeded() {
        let isHidden = cachePolicySegmentControl.selectedSegmentIndex == 0
        cacheTimeoutStackView.isHidden = isHidden
        resetCacheButton.isHidden = isHidden
    }
    
}
