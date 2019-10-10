//
//  UIColor+Theme.swift
//  Due
//
//  Created by Hon Cheng Muh on 10/10/19.
//  Copyright © 2019 Lin Junjie. All rights reserved.
//

import UIKit

extension UIColor {
    
    func lighter(amount : CGFloat = 0.25) -> UIColor {
        return hueColor(withBrightnessAmount: 1 + amount)
    }
    
    func darker(amount : CGFloat = 0.25) -> UIColor {
        return hueColor(withBrightnessAmount: 1 - amount)
    }
    
    private func hueColor(withBrightnessAmount amount: CGFloat) -> UIColor {
        var hue         : CGFloat = 0
        var saturation  : CGFloat = 0
        var brightness  : CGFloat = 0
        var alpha       : CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor( hue: hue,
                            saturation: saturation,
                            brightness: brightness * amount,
                            alpha: alpha )
        } else {
            return self
        }
    }
}
