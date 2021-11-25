//
//  NSFontDescriptor.SystemDesign+OSX.swift
//  Due Mac
//
//  Created by Muh Hon Cheng on 25/11/21.
//  Copyright © 2021 Lin Junjie. All rights reserved.
//

import Foundation
import AppKit

extension NSFontDescriptor.SystemDesign {
    
    @available(OSX 10.15, *)
    static func design(with name: String) -> NSFontDescriptor.SystemDesign {
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
