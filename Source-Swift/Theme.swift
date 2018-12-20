//
//  Theme.swift
//  DB5Demo-Swift
//
//  Created by Hon Cheng Muh on 12/1/17.
//  Copyright © 2017 Clean Shaven Apps Pte. Ltd. All rights reserved.
//

#if os(iOS)
import UIKit
public typealias Color = UIColor
public typealias Font = UIFont
public typealias EdgeInsets = UIEdgeInsets
#elseif os(OSX)
import Cocoa
public typealias Color = NSColor
public typealias Font = NSFont
public typealias EdgeInsets = NSEdgeInsets
#endif

public enum TextCaseTransform {
    case none
    case upper
    case lower
}

public func stringIsEmpty(s: String?) -> Bool {
    guard let s = s else {
        return true
    }
    return s.count == 0
}

// Picky. Crashes by design.
public func colorWithHexString(hexString: String?) -> Color {
    
    guard let hexString = hexString else {
        return Color.black
    }
    if stringIsEmpty(s: hexString) {
        return Color.black
    }

    let s: NSMutableString = NSMutableString(string: hexString)
    s.replaceOccurrences(of: "#", with: "", options: NSString.CompareOptions.caseInsensitive, range: NSMakeRange(0, hexString.count))
    CFStringTrimWhitespace(s)
    let redString = s.substring(to: 2)
    let greenString = s.substring(with: NSMakeRange(2, 2))
    let blueString = s.substring(with: NSMakeRange(4, 2))
    
    var r: UInt32 = 0, g: UInt32 = 0, b: UInt32 = 0
    Scanner(string: redString).scanHexInt32(&r)
    Scanner(string: greenString).scanHexInt32(&g)
    Scanner(string: blueString).scanHexInt32(&b)
    
    return Color(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
}

public class Theme: Equatable {
    
    public var name: String
    public var parentTheme: Theme?
    
    internal var themeDictionary: [String: Any]
    
    public init?(name: String, themeDictionary: [String: Any]) {
        self.name = name
        self.themeDictionary = themeDictionary
    }
    
    public static func ==(lhs: Theme, rhs: Theme) -> Bool {
        return lhs.name == rhs.name
    }
    
    // MARK: Lazy Accessors for Cache
    
    internal lazy var colorCache: NSCache<NSString, Color> = {
        return NSCache()
    }()
    
    internal lazy var fontCache: NSCache<NSString, Font> = {
        return NSCache()
    }()
    
    internal lazy var viewSpecifierCache: NSCache<NSString, ViewSpecifier> = {
        return NSCache()
    }()
    
    internal lazy var navigationBarSpecifierCache: NSCache<NSString, NavigationBarSpecifier> = {
        return NSCache()
    }()
    
    internal lazy var textLabelSpecifierCache: NSCache<NSString, TextLabelSpecifier> = {
        return NSCache()
    }()
    
    // MARK: Basic Methods to Obtain Data from PLIST
    
    public func object(forKey key:String) -> Any? {
        
        let themeDictionary = self.themeDictionary as NSDictionary
        var obj = themeDictionary.value(forKeyPath: key)
        if obj == nil, let parentTheme = self.parentTheme {
            obj = parentTheme.object(forKey: key)
        }
        return obj
    }
    
    public func dictionary(forKey key: String) -> [String: Any]? {
        let obj = self.object(forKey: key) as? [String: Any]
        return obj
    }
    
    public func dictionary(fromObject object:Any?) -> [String: Any]? {
        return object as? [String: Any]
    }
    
    // MARK: Basic Data Types
    
    public func bool(forKey key: String) -> Bool {
        let obj = self.object(forKey: key)
        return self.bool(forObject: obj)
    }
    
    public func bool(forObject object: Any?) -> Bool {
        guard let object = object as? NSNumber else {
            return false
        }
        return object.boolValue
    }
    
    public func string(forKey key: String) -> String? {
        let obj = self.object(forKey: key)
        return self.string(fromObject: obj)
    }
    
    internal func string(fromObject object: Any?) -> String? {
        guard let object = object else {
            return nil
        }
        if let object = object as? String {
            return object
        }
        else if let object = object as? NSNumber {
            return object.stringValue
        }
        return nil
    }
    
    public func integer(forKey key:String) -> Int {
        let obj = self.object(forKey: key)
        return self.integer(fromObject: obj)
    }
    
    public func integer(fromObject object:Any?) -> Int {
        guard let object = object as? NSNumber else {
            return 0
        }
        return object.intValue
    }
    
    public func float(forKey key:String) -> Float {
        let obj = self.object(forKey: key)
        return self.float(fromObject: obj)
    }
    
    internal func float(fromObject object: Any?) -> Float {
        guard let object = object as? NSNumber else {
            return 0
        }
        return object.floatValue
    }
    
    public func timeInterval(forKey key:String) -> TimeInterval {
        let obj = self.object(forKey: key)
        return self.timeInterval(fromObject: obj)
    }
    
    public func timeInterval(fromObject object: Any?) -> TimeInterval {
        guard let object = object as? NSNumber else {
            return 0
        }
        return object.doubleValue
    }
    
    // MARK: Advanced Data Types
    
    public func edgeInsets(forKey key: String) -> EdgeInsets {
        let insetsDictionary = self.dictionary(forKey: key)
        let edgeInsets = self.edgeInsets(fromDictionary: insetsDictionary)
        return edgeInsets
    }
    
    internal func edgeInsets(fromDictionary dictionary: [String: Any]?) -> EdgeInsets {
        let left = CGFloat(self.float(fromObject: dictionary?["left"]))
        let top = CGFloat(self.float(fromObject: dictionary?["top"]))
        let right = CGFloat(self.float(fromObject: dictionary?["right"]))
        let bottom = CGFloat(self.float(fromObject: dictionary?["bottom"]))
        
        let edgeInsets = EdgeInsets(top: top, left: left, bottom: bottom, right: right)
        return edgeInsets
    }
    
    public func color(forKey key: String) -> Color {
        guard let cachedColor = self.colorCache.object(forKey: key as NSString) else {
            let colorDictionary = self.dictionary(forKey: key)
            let color = self.color(fromDictionary: colorDictionary)
            self.colorCache.setObject(color, forKey: key as NSString)
            return color
        }
        return cachedColor
    }
    
    internal func color(fromDictionary dictionary: [String: Any]?) -> Color {

        guard let dictionary = dictionary else {
            return Color.black
        }
        
        var color: Color?
        let alphaObject = dictionary["alpha"]
        if let hexString = dictionary["hex"] as? String {
            color = colorWithHexString(hexString: hexString)
            if let alphaObject = alphaObject {
                let alpha = self.float(fromObject: alphaObject)
                color = color?.withAlphaComponent(CGFloat(alpha))
            }
        }
        else if let alphaObject = alphaObject {
            let alpha = self.float(fromObject: alphaObject)
            if alpha == 0 {
                color = Color.clear
            }
        }
        
        if color == nil {
            color = Color.black
        }
        
        return color!
    }
    
    public func font(forKey key:String, sizeAdjustment: Float) -> Font {
        let cacheKey = key.appendingFormat("_%.2f", sizeAdjustment)
        guard let cachedFont = self.fontCache.object(forKey: cacheKey as NSString) else {
            let fontDictionary = self.dictionary(forKey: key)
            let font = self.font(fromDictionary: fontDictionary, sizeAdjustment: sizeAdjustment)
            self.fontCache.setObject(font, forKey: cacheKey as NSString)
            return font
        }
        return cachedFont
    }
    
    internal func font(fromDictionary dictionary: [String: Any]?, sizeAdjustment: Float) -> Font {
        let fontName = self.string(fromObject: dictionary?["name"])
        var fontSize = CGFloat(self.float(fromObject: dictionary?["size"]))
        
        fontSize += CGFloat(sizeAdjustment)
        
        if fontSize < 1.0 {
            fontSize = 15.0
        }
        
        var font: Font?
        if let fontName = fontName {
            if stringIsEmpty(s: fontName) {
                font = Font.systemFont(ofSize: fontSize)
            }
            else {
                font = Font(name: fontName, size: fontSize)
            }
        }

        if font == nil {
            font = Font.systemFont(ofSize: fontSize)
        }
        return font!
    }
    
    public func point(forKey key: String) -> CGPoint {
        let dictionary = self.dictionary(forKey: key)
        return self.point(fromDictionary: dictionary)
    }
    
    internal func point(fromDictionary dictionary: [String: Any]?) -> CGPoint {
        let x = CGFloat(self.float(fromObject: dictionary?["x"]))
        let y = CGFloat(self.float(fromObject: dictionary?["y"]))
        let point = CGPoint(x: x, y: y)
        return point
    }
    
    public func size(forKey key: String) -> CGSize {
        let dictionary = self.dictionary(forKey: key)
        return self.size(fromDictionary: dictionary)
    }
    
    internal func size(fromDictionary dictionary: [String: Any]?) -> CGSize {
        let width = CGFloat(self.float(fromObject: dictionary?["width"]))
        let height = CGFloat(self.float(fromObject: dictionary?["height"]))
        let size = CGSize(width: width, height: height)
        return size
    }

    func textCaseTransform(forKey key: String) -> TextCaseTransform {
        let s = self.string(forKey: key)
        return self.textCaseTransform(fromString: s)
    }
    
    internal func textCaseTransform(fromString string: String?) -> TextCaseTransform {
        guard let string = string else {
            return .none
        }
        if string.caseInsensitiveCompare("lowercase") == .orderedSame {
            return .lower
        }
        else if string.caseInsensitiveCompare("uppercase") == .orderedSame {
            return .upper
        }
        return .none
    }
    
    public func viewSpecifier(forKey key: String) -> ViewSpecifier? {
        guard let cachedSpecifier = self.viewSpecifierCache.object(forKey: key as NSString) else {
            let dictionary = self.dictionary(forKey: key)
            let viewSpecifier = self.viewSpecifier(fromDictionary: dictionary)
            if let viewSpecifier = viewSpecifier {
                self.viewSpecifierCache.setObject(viewSpecifier, forKey: key as NSString)
            }
            return viewSpecifier
        }
        return cachedSpecifier
    }
    
    internal func viewSpecifier(fromDictionary dictionary: [String: Any]?) -> ViewSpecifier? {
        guard let dictionary = dictionary else {
            return nil
        }
        
        let viewSpecifier = ViewSpecifier()
        
        let sizeDictionary = self.dictionary(fromObject: dictionary["size"])
        viewSpecifier.size = self.size(fromDictionary: sizeDictionary)
        
        let positionDictionary = self.dictionary(fromObject: dictionary["position"])
        viewSpecifier.position = self.point(fromDictionary: positionDictionary)
        
        if let backgroundColorDictionary = self.dictionary(fromObject: dictionary["backgroundColor"]) {
            viewSpecifier.backgroundColor = self.color(fromDictionary: backgroundColorDictionary)
        }
        
        if let highlightedBackgroundColorDictionary = self.dictionary(fromObject: dictionary["highlightedBackgroundColor"]) {
            viewSpecifier.highlightedBackgroundColor = self.color(fromDictionary: highlightedBackgroundColorDictionary)
        }
		
		if let disabledBackgroundColorDictionary = self.dictionary(fromObject: dictionary["disabledBackgroundColor"]) {
			viewSpecifier.disabledBackgroundColor = self.color(fromDictionary: disabledBackgroundColorDictionary)
		}
        
        let edgeInsetsDictionary = self.dictionary(fromObject: dictionary["padding"])
        viewSpecifier.padding = self.edgeInsets(fromDictionary: edgeInsetsDictionary)
        
        return viewSpecifier
    }

    private func textAlignment(fromObject object: Any?) -> NSTextAlignment {
        var alignmentString = self.string(fromObject: object)
        if !stringIsEmpty(s: alignmentString) {
            alignmentString = alignmentString?.lowercased()
			if let str = alignmentString {
				switch str {
				case "left":
					return .left
				case "center":
					return .center
				case "right":
					return .right
				case "justified":
					return .justified
				case "natural":
					return .natural
				default:
					break
				}
			}
        }
        return .left
    }

    private func lineBreakMode(fromObject object: Any?) -> NSLineBreakMode {
        var linebreakString = self.string(fromObject: object)
        if !stringIsEmpty(s: linebreakString) {
            linebreakString = linebreakString?.lowercased()
            if linebreakString == "wordwrap" {
                return .byWordWrapping
            }
            else if linebreakString == "charwrap" {
                return .byCharWrapping
            }
            else if linebreakString == "clip" {
                return .byClipping
            }
            else if linebreakString == "truncatehead" {
                return .byTruncatingHead
            }
            else if linebreakString == "truncatetail" {
                return .byTruncatingTail
            }
            else if linebreakString == "truncatemiddle" {
                return .byTruncatingMiddle
            }
        }
        return .byTruncatingTail
    }
    
    public func textLabelSpecifier(forKey key: String) -> TextLabelSpecifier? {
        return self.textLabelSpecifier(forKey: key, sizeAdjustment: 0)
    }
    
    public func textLabelSpecifier(forKey key: String, sizeAdjustment: Float) -> TextLabelSpecifier? {
        let cacheKey = key.appendingFormat("_%.2f", sizeAdjustment)
        guard let cachedSpecifier = self.textLabelSpecifierCache.object(forKey: cacheKey as NSString) else {
            let dictionary = self.dictionary(forKey: key)
            let labelSpecifier = self.textLabelSpecifier(fromDictionary: dictionary, sizeAdjustment: sizeAdjustment)
            if let labelSpecifier = labelSpecifier {
                self.textLabelSpecifierCache.setObject(labelSpecifier, forKey: cacheKey as NSString)
            }
            return labelSpecifier
        }
        return cachedSpecifier
    }
    
    public func textLabelSpecifier(fromDictionary dictionary: [String: Any]?, sizeAdjustment: Float) -> TextLabelSpecifier? {
        
        guard let dictionary = dictionary else {
            return nil
        }
        
        let labelSpecifier = TextLabelSpecifier()
        
        let fontDictionary = self.dictionary(fromObject: dictionary["font"])
        labelSpecifier.font = self.font(fromDictionary: fontDictionary, sizeAdjustment: sizeAdjustment)
		
		if let boldFontDictionary = self.dictionary(fromObject: dictionary["boldFont"]) {
			labelSpecifier.boldFont = self.font(fromDictionary: boldFontDictionary, sizeAdjustment: sizeAdjustment)
		}
		
		if let italicFontDictionary = self.dictionary(fromObject: dictionary["italicFont"]) {
			labelSpecifier.italicFont = self.font(fromDictionary: italicFontDictionary, sizeAdjustment: sizeAdjustment)
		}
        
        let sizeDictionary = self.dictionary(fromObject: dictionary["size"])
        labelSpecifier.size = self.size(fromDictionary: sizeDictionary)
        
        labelSpecifier.sizeToFit = self.bool(forObject: dictionary["sizeToFit"])
        
        let positionDictionary = self.dictionary(fromObject: dictionary["position"])
        labelSpecifier.position = self.point(fromDictionary: positionDictionary)
        
        if let numberOfLines = dictionary["numberOfLines"] {
            labelSpecifier.numberOfLines = self.integer(fromObject: numberOfLines)
        }
        else {
            labelSpecifier.numberOfLines = 1
        }
        
        labelSpecifier.paragraphSpacing = self.float(fromObject: dictionary["paragraphSpacing"])
        labelSpecifier.paragraphSpacingMultiple = self.float(fromObject: dictionary["paragraphSpacingMultiple"])
        labelSpecifier.paragraphSpacingBefore = self.float(fromObject: dictionary["paragraphSpacingBefore"])
        labelSpecifier.paragraphSpacingBeforeMultiple = self.float(fromObject: dictionary["paragraphSpacingBeforeMultiple"])
        
        labelSpecifier.lineSpacingMultiple = self.float(fromObject: dictionary["lineSpacingMultiple"])
        
        let alignmentString = self.string(fromObject: dictionary["alignment"])
        labelSpecifier.alignment = self.textAlignment(fromObject: alignmentString)
        
        let lineBreakString = self.string(fromObject: dictionary["lineBreakMode"])
        labelSpecifier.lineBreakMode = self.lineBreakMode(fromObject: lineBreakString)
        
        let textTransformString = self.string(fromObject: dictionary["textTransform"])
        labelSpecifier.textTransform = self.textCaseTransform(fromString: textTransformString)
        
        if let colorDictionary = self.dictionary(fromObject: dictionary["color"]) {
            labelSpecifier.color = self.color(fromDictionary: colorDictionary)
        }
        
        if let highlightedColorDictionary = self.dictionary(fromObject: dictionary["highlightedColor"]) {
            labelSpecifier.highlightedColor = self.color(fromDictionary: highlightedColorDictionary)
        }
        
        if let disabledColorDictionary = self.dictionary(fromObject: dictionary["disabledColor"]) {
            labelSpecifier.disabledColor = self.color(fromDictionary: disabledColorDictionary)
        }
        
        if let backgroundColorDictionary = self.dictionary(fromObject: dictionary["backgroundColor"]) {
            labelSpecifier.backgroundColor = self.color(fromDictionary: backgroundColorDictionary)
        }
        
        if let highlightedBackgroundColorDictionary = self.dictionary(fromObject: dictionary["highlightedBackgroundColor"]) {
            labelSpecifier.highlightedBackgroundColor = self.color(fromDictionary: highlightedBackgroundColorDictionary)
        }
        
        if let disabledBackgroundColorDictionary = self.dictionary(fromObject: dictionary["disabledBackgroundColor"]) {
            labelSpecifier.disabledBackgroundColor = self.color(fromDictionary: disabledBackgroundColorDictionary)
        }
        
        let edgeInsetsDictionary = self.dictionary(fromObject: dictionary["padding"])
        labelSpecifier.padding = self.edgeInsets(fromDictionary: edgeInsetsDictionary)
        
        let allAttributes = [
            NSAttributedString.Key.font,
            NSAttributedString.Key.foregroundColor,
            NSAttributedString.Key.backgroundColor,
            NSAttributedString.Key.paragraphStyle]
        labelSpecifier.attributes = labelSpecifier.attributes(forKeys: allAttributes)
        return labelSpecifier
    }
    
    // MARK: Other Public Helper Methods
    
    public func contains(key: String) -> Bool {
        guard let _ = self.themeDictionary[key] else {
            return false
        }
        return true
    }
    
    public func containsOrInherits(key: String) -> Bool {
        guard let _ = self.object(forKey: key) else {
            return false
        }
        return true
    }
    
    public func clearFontCache() {
        self.fontCache.removeAllObjects()
    }
    
    public func clearColorCache() {
        self.colorCache.removeAllObjects()
    }
    
    public func clearViewSpecifierCache() {
        self.viewSpecifierCache.removeAllObjects()
    }
    
    public func clearNavigationBarSpecifierCache() {
        self.navigationBarSpecifierCache.removeAllObjects()
    }
    
    public func clearTextLabelSpecifierCache() {
        self.textLabelSpecifierCache.removeAllObjects()
    }
}


