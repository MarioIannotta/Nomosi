//
//  UIView+.swift
//  Nomosi_Example
//
//  Created by Mario on 06/10/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit

extension UIView {
    
    static var nib: UINib {
        UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        String(describing: self)
    }
    
    func fillSubview(_ subview: UIView, insets: UIEdgeInsets = .zero) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom),
            subview.leftAnchor.constraint(equalTo: leftAnchor, constant: insets.left),
            subview.rightAnchor.constraint(equalTo: rightAnchor, constant: insets.right)])
    }
}
