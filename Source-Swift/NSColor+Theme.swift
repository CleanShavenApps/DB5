//
//  NSColor+Theme.swift
//  Due Mac
//
//  Created by Hon Cheng Muh on 10/10/19.
//  Copyright © 2019 Lin Junjie. All rights reserved.
//

import Cocoa

extension NSColor {
    
    func lighter(amount : CGFloat = 0.25) -> NSColor {
        return hueColor(withBrightnessAmount: 1 + amount)
    }
    
    func darker(amount : CGFloat = 0.25) -> NSColor {
        return hueColor(withBrightnessAmount: 1 - amount)
    }
    
    private func hueColor(withBrightnessAmount amount: CGFloat) -> NSColor {
        var hue         : CGFloat = 0
        var saturation  : CGFloat = 0
        var brightness  : CGFloat = 0
        var alpha       : CGFloat = 0
        
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return NSColor( hue: hue,
                        saturation: saturation,
                        brightness: brightness * amount,
                        alpha: alpha )
    }
}
