//
//  Theme+iOS+watchOS.swift
//  Due
//
//  Created by Muh Hon Cheng on 12/11/18.
//  Copyright © 2018 Lin Junjie. All rights reserved.
//

import UIKit

public extension Theme {
    
    // MARK: Advanced Data Types
    
	func image(forKey key:String) -> UIImage? {
        guard let imageName = self.string(forKey: key) else {
            return nil
        }
        if stringIsEmpty(s: imageName) {
            return nil
        }
        return UIImage(named: imageName)
    }
    
    func appearance(forKey key: String) -> UIAppearance? {
        return nil
    }
}

public class ViewSpecifier {
    public var size = CGSize.zero
    public var position = CGPoint.zero
    public var backgroundColor: UIColor?
    public var highlightedBackgroundColor: UIColor?
    public var disabledBackgroundColor: UIColor?
    
    /** Not used when creating a view \c -viewWithViewSpecifierKey:. How padding
     affect the view to be interpreted by interested party. */
    public var padding = UIEdgeInsets.zero
    
	public func backgroundColor(forState state: UIControl.State) -> UIColor? {
        switch state {
        case .normal:
            return backgroundColor
        case .highlighted:
            return highlightedBackgroundColor
        case .disabled:
            return disabledBackgroundColor
        default:
            return nil
        }
    }
    
    public var appearance: UIAppearance?
}

public class DashedBorderSpecifier {
    var lineWidth: Float = 0
    var color: UIColor?
    var cornerRadius: Float = 0
    var paintedSegmentLength: Float = 0
    var spacingSegmentLength: Float = 0
    var insets: UIEdgeInsets = .zero
}
