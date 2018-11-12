//
//  Theme+OSX.swift
//  Due Mac
//
//  Created by Muh Hon Cheng on 12/11/18.
//  Copyright © 2018 Lin Junjie. All rights reserved.
//

import Cocoa

public extension Theme {

}

class NavigationBarSpecifier {
    
}

class TextLabelSpecifier {
    
}

public class ViewSpecifier {
    public var size = CGSize.zero
    public var position = CGPoint.zero
    public var backgroundColor: NSColor?
    public var highlightedBackgroundColor: NSColor?
    public var disabledBackgroundColor: NSColor?
    
    /** Not used when creating a view \c -viewWithViewSpecifierKey:. How padding
     affect the view to be interpreted by interested party. */
    public var padding = NSEdgeInsetsZero
    
}

public class DashedBorderSpecifier {
    var lineWidth: Float = 0
    var color: NSColor?
    var cornerRadius: Float = 0
    var paintedSegmentLength: Float = 0
    var spacingSegmentLength: Float = 0
    var insets: NSEdgeInsets = NSEdgeInsetsZero
}
