//
//  UIFontDescriptor.SystemDesign+iOS+watchOS.swift
//  Due
//
//  Created by Muh Hon Cheng on 25/11/21.
//  Copyright © 2021 Lin Junjie. All rights reserved.
//

import UIKit

extension UIFontDescriptor.SystemDesign {
    
    @available(iOS 13.0, watchOS 5.2, *)
    static func design(with name: String) -> UIFontDescriptor.SystemDesign {
        if name == "rounded" {
            return .rounded
        }
        else if name == "monospaced" {
            return .monospaced
        }
        else if name == "serif" {
            return .serif
        }
        else {
            return .default
        }
    }
}
