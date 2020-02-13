//
//  NSFont.Weight+iOS+watchOS.swift
//  Due
//
//  Created by Hon Cheng Muh on 8/2/20.
//  Copyright © 2020 Lin Junjie. All rights reserved.
//

import UIKit

extension UIFont.Weight {
	
    static func weight(with name: String) -> UIFont.Weight? {
        if name == "black" {
            return .black
        }
        else if name == "bold" {
            return .bold
        }
        else if name == "heavy" {
            return .heavy
        }
        else if name == "light" {
            return .light
        }
        else if name == "medium" {
            return .medium
        }
        else if name == "regular" {
            return .regular
        }
        else if name == "semibold" {
            return .semibold
        }
        else if name == "thin" {
            return .thin
        }
        else if name == "ultraLight" {
            return .ultraLight
        }
        else {
            return nil
        }
    }
}
