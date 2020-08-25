//
//  Theme+OSX.swift
//  Due Mac
//
//  Created by Muh Hon Cheng on 12/11/18.
//  Copyright © 2018 Lin Junjie. All rights reserved.
//

import Cocoa

public extension Theme {
    
    func appearance(forKey key:String) -> NSAppearance? {
        let obj = self.object(forKey: key)
        return self.appearance(fromObject: obj)
    }
    
    func appearance(fromObject object: Any?) -> NSAppearance? {
        guard let nameString = object as? String else {
            return nil
        }
        let appearanceName = NSAppearance.Name(nameString)
        return NSAppearance(named: appearanceName)
    }
    
    func scrollerKnobStyle(forKey key: String) -> NSScroller.KnobStyle {
        guard let stringStyle = self.string(forKey: key) else {
            return .default
        }
        if stringStyle == "dark" {
            return .dark
        }
        else if stringStyle == "light" {
            return .light
        }
        else {
            return .default
        }
    }

    func tableViewSpecifier(forKey key: String) -> TableViewSpecifier? {
        guard let cachedSpecifier = self.viewSpecifierCache.object(forKey: key as NSString) as? TableViewSpecifier else {
            let dictionary = self.dictionary(forKey: key)
            let viewSpecifier = self.tableViewSpecifier(fromDictionary: dictionary)
            if let viewSpecifier = viewSpecifier {
                self.viewSpecifierCache.setObject(viewSpecifier, forKey: key as NSString)
            }
            return viewSpecifier
        }
        return cachedSpecifier
    }
    
    internal func tableViewSpecifier(fromDictionary dictionary: [String: Any]?) -> TableViewSpecifier? {
        guard let dictionary = dictionary else {
            return nil
        }
        
        let viewSpecifier = TableViewSpecifier()

        let sizeDictionary = self.dictionary(fromObject: dictionary["intercellSpacing"])
        viewSpecifier.intercellSpacing
            = self.size(fromDictionary: sizeDictionary)

        if let color = self.color(fromDictionary: dictionary, with: "backgroundColor") {
            viewSpecifier.backgroundColor = color
        }
        
        if let color = self.color(fromDictionary: dictionary, with: "separatorColor") {
            viewSpecifier.separatorColor = color
        }

        return viewSpecifier
    }
}

class NavigationBarSpecifier {
    
}

public class TextLabelSpecifier {
    var font: NSFont?
	var boldFont: NSFont?
	var italicFont: NSFont?
    var size = CGSize.zero
    /** If YES, \c size should be ignored when creating a text label from it */
    var sizeToFit: Bool = false
    var position = CGPoint.zero
    /** Default: 1 (single line) */
    var numberOfLines: Int = 1
    
    var paragraphSpacing: Float = 0
    var paragraphSpacingBefore: Float = 0
    /// If multiple is > 0, takes precedence over paragraphSpacing
    var paragraphSpacingMultiple: Float = 0
    /// If multiple is > 0, takes precedence over paragraphSpacingBefore
    var paragraphSpacingBeforeMultiple: Float = 0
    
    /// Line spacing affect line breaks (\u2028), while paragraph spacing affects paragraph breaks (\u2029). The line spacing is calculated with the font.pointSize multipled by lineSpacingMultiple.
    var lineSpacingMultiple: Float = 0
    
    var lineHeightMultiple: Float = 1
    
    var headIndent: Float = 0
    
    var alignment: NSTextAlignment = .left
    var lineBreakMode: NSLineBreakMode = .byWordWrapping
    var textTransform: TextCaseTransform = .none
    
    var color: NSColor?
	var darkColor: NSColor?
    var highlightedColor: NSColor?
    var disabledColor: NSColor?
    
    var backgroundColor: NSColor?
    var highlightedBackgroundColor: NSColor?
    var disabledBackgroundColor: NSColor?
    
    /** Not used when creating a view \c -labelWithText:specifierKey:sizeAdjustment:
     How padding affect the text label to be interpreted by interested party. */
    var padding: NSEdgeInsets?
    
    /** Attributes representing the font, color, backgroundColor, alignment and lineBreakMode */
    var attributes: [NSAttributedString.Key: Any]?
    
    func label(withText text: String) -> NSTextField {
        let frame = CGRect(origin: self.position, size: self.size)
        return self.label(withText: text, frame: frame)
    }
    
    func label(withText text: String, frame: CGRect) -> NSTextField {
        let label = NSTextField(frame: frame)
        self.apply(toLabel: label, withText: text)
        return label
    }
    
    func transform(text: String) -> String {
        var transformedText: String
        switch self.textTransform {
        case .upper:
            transformedText = text.uppercased()
            break
        case .lower:
            transformedText = text.lowercased()
            break
        case .none:
            transformedText = text
            break
        }
        return transformedText
    }
    
    private lazy var defaultTextLabelAttributes = {
        return [NSAttributedString.Key.font,
                NSAttributedString.Key.foregroundColor,
                NSAttributedString.Key.backgroundColor,
                NSAttributedString.Key.paragraphStyle]
    }()
    
    func attributedString(withText text: String) -> NSAttributedString {
        let allAttributes = self.attributes(forKeys: [
            NSAttributedString.Key.font,
            NSAttributedString.Key.foregroundColor,
            NSAttributedString.Key.backgroundColor,
            NSAttributedString.Key.paragraphStyle])
        return self.attributedString(withText: text, attributes: allAttributes)
    }
    
    func attributedString(withText text: String, attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let transformedText = self.transform(text: text)
        return NSAttributedString(string: transformedText, attributes: attributes)
    }
    
    func fontAndColorAttributes() -> [NSAttributedString.Key: Any] {
        return self.attributes(forKeys: [
            NSAttributedString.Key.font,
            NSAttributedString.Key.foregroundColor,
            NSAttributedString.Key.backgroundColor])
    }
    
    func attributes(forKeys keys: [NSAttributedString.Key], customForegroundColor: NSColor? = nil, customBackgroundColor: NSColor? = nil) -> [NSAttributedString.Key: Any] {
        var textAttributes: [NSAttributedString.Key: Any] = [:]
        for key in keys {
            if key == NSAttributedString.Key.paragraphStyle {
                if let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle {
                    
                    paragraphStyle.lineBreakMode = self.lineBreakMode
                    paragraphStyle.alignment = self.alignment
                    
                    if self.paragraphSpacingMultiple>0, let font = self.font {
                        paragraphStyle.paragraphSpacing = font.pointSize * CGFloat(self.paragraphSpacingMultiple)
                    }
                    else if self.paragraphSpacing>0 {
                        paragraphStyle.paragraphSpacing = CGFloat(paragraphSpacing)
                    }
                    else if self.paragraphSpacingBeforeMultiple>0, let font = self.font {
                        paragraphStyle.paragraphSpacing = font.pointSize * CGFloat(self.paragraphSpacingBeforeMultiple)
                    }
                    else if self.paragraphSpacingBefore>0 {
                        paragraphStyle.paragraphSpacing = CGFloat(paragraphSpacingBefore)
                    }
                    
                    if self.lineSpacingMultiple>0, let font = self.font {
                        paragraphStyle.lineSpacing = font.pointSize * CGFloat(self.lineSpacingMultiple)
                    }
                    
                    if self.headIndent>0 {
                        paragraphStyle.headIndent = CGFloat(headIndent)
                    }
                    
                    paragraphStyle.lineHeightMultiple = CGFloat(self.lineHeightMultiple)
                    
                    textAttributes[key] = paragraphStyle
                }
            }
            else if key == NSAttributedString.Key.font {
                if let font = self.font {
                    textAttributes[key] = font
                }
            }
            else if key == NSAttributedString.Key.foregroundColor {
                if let color = customForegroundColor ?? self.color {
                    textAttributes[key] = color
                }
            }
            else if key == NSAttributedString.Key.backgroundColor {
                if let backgroundColor =  customBackgroundColor ?? self.backgroundColor {
                    textAttributes[key] = backgroundColor
                }
            }
            else {
                assertionFailure("Invalid key \(key) to obtain attribute for")
            }
        }
        
        return textAttributes
    }
    
    func apply(toPlaceholderIn label: NSTextField) {
        self.apply(toPlaceholderIn: label, withPlaceholder: nil)
    }
    
    func apply(toPlaceholderIn label: NSTextField, withPlaceholder placeholder: String?) {
        var placeholderText: String?
        if let placeholder = placeholder {
            placeholderText = placeholder
        }
        else {
            placeholderText = label.placeholderString
        }
        
        guard let text = placeholderText else {
            return
        }
        
        let attributedPlaceholderText = NSMutableAttributedString(string: text)
        attributedPlaceholderText.addAttribute(.font, value: font!, range: NSMakeRange(0, text.count))
        attributedPlaceholderText.addAttribute(.foregroundColor, value: color!, range: NSMakeRange(0, text.count))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        attributedPlaceholderText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, text.count))
        
        label.placeholderAttributedString = attributedPlaceholderText
    }
    
    func apply(toLabel label: NSTextField) {
        self.apply(toLabel: label, withText: nil)
    }
    
	func apply(toLabel label: NSTextField, withText text: String?, useDarkColor: Bool = false) {
        if let text = text {
            label.attributedStringValue = attributedString(withText: text)
        }
        if let font = self.font {
            label.font = font
        }
        label.alignment = self.alignment
        label.maximumNumberOfLines = self.numberOfLines
		
		if useDarkColor, let darkColor = self.darkColor {
			label.textColor = darkColor
		} else if let color = self.color {
            label.textColor = color
        }
		
        if let backgroundColor = self.backgroundColor {
            label.backgroundColor = backgroundColor
        }
        if self.sizeToFit {
            label.sizeToFit()
        }
    }
    
    func apply(toTextView textView: NSTextView) {
        textView.font = self.font
        textView.textColor = self.color
    }
    
    func apply(toLabelIn button: NSButton) {
        self.apply(toLabelIn: button, withText: button.title)
    }
    
    func apply(toLabelIn button: NSButton, withText text: String) {
        if let font = self.font {
            button.font = font
        }
        button.alignment = self.alignment

        if let color = self.color {
            let attributedTitle = NSMutableAttributedString(string: text)
            attributedTitle.addAttribute(.foregroundColor, value: color, range: NSMakeRange(0, attributedTitle.length))
            if let font = self.font {
                attributedTitle.addAttribute(.font, value: font, range: NSMakeRange(0, attributedTitle.length))
            }
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = self.alignment
            paragraphStyle.lineBreakMode = self.lineBreakMode
            attributedTitle.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedTitle.length))
            
            button.attributedTitle = attributedTitle
        }
        
        if let backgroundColor = self.backgroundColor {
            button.wantsLayer = true
            button.layer?.backgroundColor = backgroundColor.cgColor
        }
    }
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
    
    public var appearance: NSAppearance?
    
}

public class TableViewSpecifier: ViewSpecifier {
    public var intercellSpacing: NSSize?
    public var separatorColor: NSColor?
    
    func apply(toTableView tableView: NSTableView) {
        if let backgroundColor = backgroundColor {
            tableView.backgroundColor = backgroundColor
        }
        if let separatorColor = separatorColor {
            tableView.gridColor = separatorColor
        }
        if let intercellSpacing = intercellSpacing {
            tableView.intercellSpacing = intercellSpacing
        }
        
    }
}

public class DashedBorderSpecifier {
    var lineWidth: Float = 0
    var color: NSColor?
    var cornerRadius: Float = 0
    var paintedSegmentLength: Float = 0
    var spacingSegmentLength: Float = 0
    var insets: NSEdgeInsets = NSEdgeInsetsZero
}
