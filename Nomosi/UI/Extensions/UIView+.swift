//
//  UIView+.swift
//  Nomosi
//
//  Created by Mario on 06/10/2018.
//

#if canImport(UIKit)
import UIKit

extension UIView {
    
    func fillSubview(_ subview: UIView, insets: UIEdgeInsets = .zero) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom),
            subview.leftAnchor.constraint(equalTo: leftAnchor, constant: insets.left),
            subview.rightAnchor.constraint(equalTo: rightAnchor, constant: insets.right)])
    }
}
#endif
