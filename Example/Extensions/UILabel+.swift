//
//  UILabel+.swift
//  Nomosi_Example
//
//  Created by Mario on 01/08/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit

extension UILabel {
  
  var numberOfVisibleLines: Int {
    let textSize = CGSize(width: CGFloat(frame.size.width), height: CGFloat(MAXFLOAT))
    let rHeight: Int = lroundf(Float(sizeThatFits(textSize).height))
    let charSize: Int = lroundf(Float(font.pointSize))
    return rHeight / charSize
  }
}
