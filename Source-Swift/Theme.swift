//
//  Theme.swift
//  DB5Demo-Swift
//
//  Created by Hon Cheng Muh on 12/1/17.
//  Copyright © 2017 Clean Shaven Apps Pte. Ltd. All rights reserved.
//

import UIKit

enum TextCaseTransform {
    case none
    case upper
    case lower
}

func stringIsEmpty(s: String?) -> Bool {
    guard let s = s else {
        return true
    }
    return s.count == 0
}

// Picky. Crashes by design.
func colorWithHexString(hexString: String?) -> UIColor {
    
    guard let hexString = hexString else {
        return UIColor.black
    }
    if stringIsEmpty(s: hexString) {
        return UIColor.black
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
    
    return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1.0)
}

class Theme: Equatable {
    
    var name: String
    var parentTheme: Theme?
    
    private var themeDictionary: [String: Any]
    
    init?(name: String, themeDictionary: [String: Any]) {
        self.name = name
        self.themeDictionary = themeDictionary
    }
    
    static func ==(lhs: Theme, rhs: Theme) -> Bool {
        return lhs.name == rhs.name
    }
    
    // MARK: Lazy Accessors for Cache
    
    private lazy var colorCache: NSCache<NSString, UIColor> = {
        return NSCache()
    }()
    
    private lazy var fontCache: NSCache<NSString, UIFont> = {
        return NSCache()
    }()
    
    private lazy var viewSpecifierCache: NSCache<NSString, ViewSpecifier> = {
        return NSCache()
    }()
    
    private lazy var navigationBarSpecifierCache: NSCache<NSString, NavigationBarSpecifier> = {
        return NSCache()
    }()
    
    private lazy var textLabelSpecifierCache: NSCache<NSString, TextLabelSpecifier> = {
        return NSCache()
    }()
    
    // MARK: Basic Methods to Obtain Data from PLIST
    
    func object(forKey key:String) -> Any? {
        
        let themeDictionary = self.themeDictionary as NSDictionary
        var obj = themeDictionary.value(forKeyPath: key)
        if obj == nil, let parentTheme = self.parentTheme {
            obj = parentTheme.object(forKey: key)
        }
        return obj
    }
    
    func dictionary(forKey key: String) -> [String: Any]? {
        let obj = self.object(forKey: key) as? [String: Any]
        return obj
    }
    
    func dictionary(fromObject object:Any?) -> [String: Any]? {
        return object as? [String: Any]
    }
    
    // MARK: Basic Data Types
    
    func bool(forKey key: String) -> Bool {
        let obj = self.object(forKey: key)
        return self.bool(forObject: obj)
    }
    
    func bool(forObject object: Any?) -> Bool {
        guard let object = object as? NSNumber else {
            return false
        }
        return object.boolValue
    }
    
    func string(forKey key: String) -> String? {
        let obj = self.object(forKey: key)
        return self.string(fromObject: obj)
    }
    
    private func string(fromObject object: Any?) -> String? {
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
    
    func integer(forKey key:String) -> Int {
        let obj = self.object(forKey: key)
        return self.integer(fromObject: obj)
    }
    
    func integer(fromObject object:Any?) -> Int {
        guard let object = object as? NSNumber else {
            return 0
        }
        return object.intValue
    }
    
    func float(forKey key:String) -> Float {
        let obj = self.object(forKey: key)
        return self.float(fromObject: obj)
    }
    
    private func float(fromObject object: Any?) -> Float {
        guard let object = object as? NSNumber else {
            return 0
        }
        return object.floatValue
    }
    
    func timeInterval(forKey key:String) -> TimeInterval {
        let obj = self.object(forKey: key)
        return self.timeInterval(fromObject: obj)
    }
    
    func timeInterval(fromObject object: Any?) -> TimeInterval {
        guard let object = object as? NSNumber else {
            return 0
        }
        return object.doubleValue
    }
    
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
    
    func color(forKey key: String) -> UIColor {
        guard let cachedColor = self.colorCache.object(forKey: key as NSString) else {
            let colorDictionary = self.dictionary(forKey: key)
            let color = self.color(fromDictionary: colorDictionary)
            self.colorCache.setObject(color, forKey: key as NSString)
            return color
        }
        return cachedColor
    }
    
    private func color(fromDictionary dictionary: [String: Any]?) -> UIColor {

        guard let dictionary = dictionary else {
            return UIColor.black
        }
        
        var color: UIColor?
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
                color = UIColor.clear
            }
        }
        
        if color == nil {
            color = UIColor.black
        }
        
        return color!
    }
    
    func edgeInsets(forKey key: String) -> UIEdgeInsets {
        let insetsDictionary = self.dictionary(forKey: key)
        let edgeInsets = self.edgeInsets(fromDictionary: insetsDictionary)
        return edgeInsets
    }
    
    private func edgeInsets(fromDictionary dictionary: [String: Any]?) -> UIEdgeInsets {
        let left = CGFloat(self.float(fromObject: dictionary?["left"]))
        let top = CGFloat(self.float(fromObject: dictionary?["top"]))
        let right = CGFloat(self.float(fromObject: dictionary?["right"]))
        let bottom = CGFloat(self.float(fromObject: dictionary?["bottom"]))
        
        let edgeInsets = UIEdgeInsetsMake(top, left, bottom, right)
        return edgeInsets
    }
    
//    func font(forKey key: String) -> UIFont? {
//    }

    
    func font(forKey key:String, sizeAdjustment: Float) -> UIFont {
        let cacheKey = key.appendingFormat("_%.2f", sizeAdjustment)
        guard let cachedFont = self.fontCache.object(forKey: cacheKey as NSString) else {
            let fontDictionary = self.dictionary(forKey: key)
            let font = self.font(fromDictionary: fontDictionary, sizeAdjustment: sizeAdjustment)
            self.fontCache.setObject(font, forKey: cacheKey as NSString)
            return font
        }
        return cachedFont
        
        
    }
    
    private func font(fromDictionary dictionary: [String: Any]?, sizeAdjustment: Float) -> UIFont {
        let fontName = self.string(fromObject: dictionary?["name"])
        var fontSize = CGFloat(self.float(fromObject: dictionary?["size"]))
        
        fontSize += CGFloat(sizeAdjustment)
        
        if fontSize < 1.0 {
            fontSize = 15.0
        }
        
        var font: UIFont?
        if let fontName = fontName {
            if stringIsEmpty(s: fontName) {
                font = UIFont.systemFont(ofSize: fontSize)
            }
            else {
                font = UIFont(name: fontName, size: fontSize)
            }
        }

        if font == nil {
            font = UIFont.systemFont(ofSize: fontSize)
        }
        return font!
    }
    
    func point(forKey key: String) -> CGPoint {
        let dictionary = self.dictionary(forKey: key)
        return self.point(fromDictionary: dictionary)
    }
    
    private func point(fromDictionary dictionary: [String: Any]?) -> CGPoint {
        let x = CGFloat(self.float(fromObject: dictionary?["x"]))
        let y = CGFloat(self.float(fromObject: dictionary?["y"]))
        let point = CGPoint(x: x, y: y)
        return point
    }
    
    func size(forKey key: String) -> CGSize {
        let dictionary = self.dictionary(forKey: key)
        return self.size(fromDictionary: dictionary)
    }
    
    private func size(fromDictionary dictionary: [String: Any]?) -> CGSize {
        let width = CGFloat(self.float(fromObject: dictionary?["width"]))
        let height = CGFloat(self.float(fromObject: dictionary?["height"]))
        let size = CGSize(width: width, height: height)
        return size
    }
    
    private func curve(fromObject object: Any?) -> UIViewAnimationOptions {
        guard let curveString = self.string(fromObject: object) else {
            return .curveEaseInOut
        }
        if stringIsEmpty(s: curveString) {
            return .curveEaseInOut
        }
        
        let lCurveString = curveString.lowercased()
        if lCurveString == "easeinout" {
            return .curveEaseInOut
        }
        else if lCurveString == "easeout" {
            return .curveEaseOut
        }
        else if lCurveString == "easein" {
            return .curveEaseIn
        }
        else if lCurveString == "linear" {
            return .curveLinear
        }
        return .curveEaseInOut
    }
    
    func animationSpecifier(forKey key: String) -> AnimationSpecifier? {
        let animationSpecifier = AnimationSpecifier()
        
        guard let animationDictionary = self.dictionary(forKey: key) else {
            return nil
        }
        
        animationSpecifier.duration = self.timeInterval(fromObject: animationDictionary["duration"])
        animationSpecifier.delay = self.timeInterval(fromObject: animationDictionary["delay"])
        animationSpecifier.curve = self.curve(fromObject: animationDictionary["curve"])
        
        return animationSpecifier
    }
    
    func textCaseTransform(forKey key: String) -> TextCaseTransform {
        let s = self.string(forKey: key)
        return self.textCaseTransform(fromString: s)
    }
    
    private func textCaseTransform(fromString string: String?) -> TextCaseTransform {
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
    
    func viewSpecifier(forKey key: String) -> ViewSpecifier? {
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
    
    private func viewSpecifier(fromDictionary dictionary: [String: Any]?) -> ViewSpecifier? {
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
    
    func navigationBarSpecifier(forKey key: String) -> NavigationBarSpecifier? {
        return self.navigationBarSpecifier(forKey: key, sizeAdjustment:0)
    }
    
    func navigationBarSpecifier(forKey key: String, sizeAdjustment: Float) -> NavigationBarSpecifier? {
        guard let cachedSpecifier = self.navigationBarSpecifierCache.object(forKey: key as NSString) else {
         
            let navigationBarSpecifier = NavigationBarSpecifier()
            guard let dictionary = self.dictionary(forKey: key) else {
                return nil
            }
            
            if let popoverBackgroundColorDictionary = self.dictionary(fromObject: dictionary["popoverBackgroundColor"]) {
                navigationBarSpecifier.popoverBackgroundColor = self.color(fromDictionary: popoverBackgroundColorDictionary)
            }
            
            if let barColorDictionary = self.dictionary(fromObject: dictionary["barColor"]) {
                navigationBarSpecifier.barColor = self.color(fromDictionary: barColorDictionary)
            }
            
            if let tintColorDictionary = self.dictionary(fromObject: dictionary["tintColor"]) {
                navigationBarSpecifier.tintColor = self.color(fromDictionary: tintColorDictionary)
            }
            
            navigationBarSpecifier.titleLabelSpecifier = self.textLabelSpecifier(fromDictionary: dictionary["titleLabel"] as? [String : Any], sizeAdjustment: sizeAdjustment)
            
            navigationBarSpecifier.buttonsLabelSpecifier = self.textLabelSpecifier(fromDictionary: dictionary["buttonsLabel"] as? [String : Any], sizeAdjustment: sizeAdjustment)
			
			// translucent by default (initializer)
			if let translucentObject = dictionary["translucency"] {
				navigationBarSpecifier.translucent = bool(forObject: translucentObject)
			}
			
			let barStyle = self.barStyle(fromObject: dictionary["barStyle"])
			navigationBarSpecifier.barStyle = barStyle;
			
            self.navigationBarSpecifierCache.setObject(navigationBarSpecifier, forKey: key as NSString)
            return navigationBarSpecifier
        }
        return cachedSpecifier
    }
    
    func textLabelSpecifier(forKey key: String) -> TextLabelSpecifier? {
        return self.textLabelSpecifier(forKey: key, sizeAdjustment: 0)
    }
    
    func textLabelSpecifier(forKey key: String, sizeAdjustment: Float) -> TextLabelSpecifier? {
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
    
    func textLabelSpecifier(fromDictionary dictionary: [String: Any]?, sizeAdjustment: Float) -> TextLabelSpecifier? {
        
        guard let dictionary = dictionary else {
            return nil
        }
        
        let labelSpecifier = TextLabelSpecifier()
        
        let fontDictionary = self.dictionary(fromObject: dictionary["font"])
        labelSpecifier.font = self.font(fromDictionary: fontDictionary, sizeAdjustment: sizeAdjustment)
        
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
			NSAttributedStringKey.font,
			NSAttributedStringKey.foregroundColor,
			NSAttributedStringKey.backgroundColor,
			NSAttributedStringKey.paragraphStyle]
        labelSpecifier.attributes = labelSpecifier.attributes(forKeys: allAttributes)
        return labelSpecifier
    }
    
    func dashedBorderSpecifier(forKey key: String) -> DashedBorderSpecifier? {
        guard let dictionary = self.dictionary(fromObject: key) else {
            return nil
        }
        
        let dashedBorderSpecifier = DashedBorderSpecifier()
        
        if let colorDictionary = self.dictionary(fromObject: dictionary["color"]) {
            dashedBorderSpecifier.color = self.color(fromDictionary: colorDictionary)
        }
        
        dashedBorderSpecifier.lineWidth = self.float(fromObject: dictionary["lineWidth"])
        dashedBorderSpecifier.cornerRadius = self.float(fromObject: dictionary["cornerRadius"])
        dashedBorderSpecifier.paintedSegmentLength = self.float(fromObject: dictionary["paintedSegmentLength"])
        dashedBorderSpecifier.spacingSegmentLength = self.float(fromObject: dictionary["spacingSegmentLength"])
        
        let edgeInsetsDictionary = self.dictionary(fromObject: dictionary["insets"])
        dashedBorderSpecifier.insets = self.edgeInsets(fromDictionary: edgeInsetsDictionary)
        
        return dashedBorderSpecifier
    }
    
    func textAlignment(forKey key: String) -> NSTextAlignment {
        let obj = self.object(forKey: key)
        return self.textAlignment(fromObject: obj)
    }

    private func textAlignment(fromObject object: Any?) -> NSTextAlignment {
        var alignmentString = self.string(fromObject: object)
        if !stringIsEmpty(s: alignmentString) {
            alignmentString = alignmentString?.lowercased()
            if alignmentString == "left" {
                return .left
            }
            else if alignmentString == "right" {
                return .right
            }
            else if alignmentString == "justified" {
                return .justified
            }
            else if alignmentString == "natural" {
                return .natural
            }
        }
        return .left
    }
    
    func lineBreakMode(forKey key: String) -> NSLineBreakMode {
        let obj = self.object(forKey: key)
        return self.lineBreakMode(fromObject: obj)
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
    
    func statusBarStyle(forKey key: String) -> UIStatusBarStyle {
        let obj = self.object(forKey: key)
        return statusBarStyle(fromObject: obj)
    }
    
    private func statusBarStyle(fromObject object: Any?) -> UIStatusBarStyle {
		guard let statusBarStyleString = self.string(fromObject: object)?.lowercased(), stringIsEmpty(s: statusBarStyleString) == false else {
			return .default
		}
		
		switch statusBarStyleString {
		case "darkcontent":
			return .default
		case "lightcontent":
			return .lightContent
		default:
			return .default
		}
    }
	
	/** Where the possible values are extralight, light, dark, regular, prominent */
	func blueEffectStyle(forKey key: String) -> UIBlurEffectStyle {
		let obj = self.object(forKey: key)
		return blurEffectStyle(fromObject: obj)
	}
	
	private func blurEffectStyle(fromObject object: Any?) -> UIBlurEffectStyle {
		guard let blurEffectStyleString = self.string(fromObject: object)?.lowercased(), stringIsEmpty(s: blurEffectStyleString) == false else {
			return .extraLight
		}
		
		switch blurEffectStyleString {
		case "extralight":
			return .extraLight
		case "light":
			return .light
		case "dark":
			return .dark
		case "regular":
			return .regular
		case "prominent":
			return .prominent
		default:
			return .extraLight
		}
	}
	
	func barStyle(forKey key: String) -> UIBarStyle {
		let obj = self.object(forKey: key)
		return barStyle(fromObject: obj)
	}
	
	private func barStyle(fromObject object: Any?) -> UIBarStyle {
		guard let barStyleString = string(fromObject: object)?.lowercased(), stringIsEmpty(s: barStyleString) == false else {
			return .default
		}
		
		switch barStyleString {
		case "default":
			return .default
		case "black":
			return .black
		default:
			return .default
		}
	}
    
    func keyboardAppearance(forKey key: String) -> UIKeyboardAppearance {
        let obj = self.object(forKey: key)
        return self.keyboardAppearance(fromObject: obj)
    }
    
    private func keyboardAppearance(fromObject object: Any?) -> UIKeyboardAppearance {
        var keyboardAppearanceString = self.string(fromObject: object)
        if !stringIsEmpty(s: keyboardAppearanceString) {
            keyboardAppearanceString = keyboardAppearanceString?.lowercased()
            if keyboardAppearanceString == "dark" {
                return .dark
            }
            else if keyboardAppearanceString == "light" {
                return .light
            }
        }
        return .default
    }
    
    // MARK: Other Public Helper Methods
    
    func contains(key: String) -> Bool {
        guard let _ = self.themeDictionary[key] else {
            return false
        }
        return true
    }
    
    func containsOrInherits(key: String) -> Bool {
        guard let _ = self.object(forKey: key) else {
            return false
        }
        return true
    }
    
    func clearFontCache() {
        self.fontCache.removeAllObjects()
    }
    
    func clearColorCache() {
        self.colorCache.removeAllObjects()
    }
    
    func clearViewSpecifierCache() {
        self.viewSpecifierCache.removeAllObjects()
    }
    
    func clearNavigationBarSpecifierCache() {
        self.navigationBarSpecifierCache.removeAllObjects()
    }
    
    func clearTextLabelSpecifierCache() {
        self.textLabelSpecifierCache.removeAllObjects()
    }
}

extension Theme {
    
    func view(withViewSpecifierKey viewSpecifierKey: String) -> UIView {
        guard let viewSpecifier = self.viewSpecifier(forKey: viewSpecifierKey) else {
            fatalError("viewSpecifier is nil for key \(viewSpecifierKey)")
        }
        let frame = CGRect(origin: viewSpecifier.position, size: viewSpecifier.size)
        let view = UIView(frame: frame)
        view.backgroundColor = viewSpecifier.backgroundColor
        return view
    }
    
    func label(withText text: String, specifierKey labelSpecifierKey: String) -> UILabel {
        return self.label(withText: text, specifierKey: labelSpecifierKey, sizeAdjustment: 0)
    }
    
    func label(withText text: String, specifierKey labelSpecifierKey: String, sizeAdjustment: Float) -> UILabel {
        guard let textLabelSpecifier = self.textLabelSpecifier(forKey: labelSpecifierKey, sizeAdjustment: sizeAdjustment) else {
            fatalError("label is nil for key \(labelSpecifierKey)")
        }
        return textLabelSpecifier.label(withText: text)
    }
    
    func animate(withAnimationSpecifierKey animationSpecifierKey: String, animations:@escaping (() -> ()), completion:@escaping ((_ finished: Bool) -> ())) {
        
        guard let animationSpecifier = self.animationSpecifier(forKey: animationSpecifierKey) else {
            fatalError("animation specifier is nil for key \(animationSpecifierKey)")
        }
        
        UIView.animate(withDuration: animationSpecifier.duration, delay: animationSpecifier.delay, options: animationSpecifier.curve, animations: animations, completion: completion)
    }
    
}

class AnimationSpecifier {
    var delay: TimeInterval = 0
    var duration: TimeInterval = 0
    var curve: UIViewAnimationOptions = .curveEaseInOut
}

class ViewSpecifier {
    var size = CGSize.zero
    var position = CGPoint.zero
    var backgroundColor: UIColor?
    var highlightedBackgroundColor: UIColor?
	var disabledBackgroundColor: UIColor?
    
    /** Not used when creating a view \c -viewWithViewSpecifierKey:. How padding
     affect the view to be interpreted by interested party. */
    var padding = UIEdgeInsets.zero
}

class NavigationBarSpecifier {
    
    var translucent: Bool = false
	var barStyle: UIBarStyle = .default
    var popoverBackgroundColor: UIColor?
    var barColor: UIColor?
    var tintColor: UIColor?
    var titleLabelSpecifier: TextLabelSpecifier?
    var buttonsLabelSpecifier: TextLabelSpecifier?
    func apply(toNavigationBar navigationBar: UINavigationBar, containedInClass containingClass: UIAppearanceContainer.Type?) {
        
        if let barColor = self.barColor {
            navigationBar.barTintColor = barColor
        }
        if let tintColor = self.tintColor {
            navigationBar.tintColor = tintColor
        }
        
        navigationBar.isTranslucent = self.translucent
        
        if let titleLabelSpecifier = self.titleLabelSpecifier {
            let attributes = titleLabelSpecifier.attributes(forKeys: [
                NSAttributedStringKey.font,
                NSAttributedStringKey.foregroundColor])
            navigationBar.titleTextAttributes = attributes
        }
        
        if let buttonsLabelSpecifier = self.buttonsLabelSpecifier {
            let attributes = buttonsLabelSpecifier.attributes(forKeys: [
				NSAttributedStringKey.font,
				NSAttributedStringKey.foregroundColor])
            if let containingClass = containingClass {
                UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self, containingClass]).setTitleTextAttributes(attributes, for: .normal)
            }
            else {
                UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleTextAttributes(attributes, for: .normal)
            }
        }
    }
}

class TextLabelSpecifier {
    
    var font: UIFont?
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
    
    var alignment: NSTextAlignment = .left
    var lineBreakMode: NSLineBreakMode = .byWordWrapping
    var textTransform: TextCaseTransform = .none
	
	var color: UIColor?
    var highlightedColor: UIColor?
	var disabledColor: UIColor?
	
    var backgroundColor: UIColor?
    var highlightedBackgroundColor: UIColor?
	var disabledBackgroundColor: UIColor?
    
    /** Not used when creating a view \c -labelWithText:specifierKey:sizeAdjustment:
     How padding affect the text label to be interpreted by interested party. */
    var padding: UIEdgeInsets?
    
    /** Attributes representing the font, color, backgroundColor, alignment and lineBreakMode */
    var attributes: [NSAttributedStringKey: Any]?
    
    func label(withText text: String) -> UILabel {
        let frame = CGRect(origin: self.position, size: self.size)
        return self.label(withText: text, frame: frame)
    }
    
    func label(withText text: String, frame: CGRect) -> UILabel {
        let label = UILabel(frame: frame)
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
	
	private lazy var defaultTextLabelAttribute = {
		return [NSAttributedStringKey.font,
				NSAttributedStringKey.foregroundColor,
				NSAttributedStringKey.backgroundColor,
				NSAttributedStringKey.paragraphStyle]
	}()
	
    func attributedString(withText text: String) -> NSAttributedString {
		return self.attributedString(withText: text, attributes: attributes(forKeys: defaultTextLabelAttribute))
    }
	
	/// Returns a highlighted attributed string for use in the attributed title
	/// of the highlighted state of a UIButton, using attributes specified in
	/// the receiver's attributes dictionary, and by applying any transformatio
	/// to the text.
	///
	/// - Parameters:
	///   - text: The text to use for the attributed string
	///   - alphaComponent: If the specifier is missing highlightedColor or
	/// highlightedBackgroundColor, specify a opacity from 0–1 to automatically
	/// generate the highlightedColor and highlightedBackgroundColor based on
	/// the color and backgroundColor
	/// - Returns: An attributed string meant for the highlighted state of a UIButton
	func highlightedAttributedString(withText text: String, generateMissingHighlightedColorsUsingColorsWithAlphaComponent alphaComponent: CGFloat?) -> NSAttributedString {
		var allAttributes = attributes(forKeys: defaultTextLabelAttribute)
		
		let kMinimumAlpha: CGFloat = 0
		let kMaximumAlpha: CGFloat = 1
		
		if let highlightedColor = self.highlightedColor {
			allAttributes[.foregroundColor] = highlightedColor
		} else if let color = self.color, let alpha = alphaComponent, alpha > kMinimumAlpha && alpha < kMaximumAlpha {
			allAttributes[.foregroundColor] = color.withAlphaComponent(alpha)
		}
		
		if let highlightedBackgroundColor = self.highlightedBackgroundColor {
			allAttributes[.backgroundColor] = highlightedBackgroundColor;
		} else if let backgroundColor = self.backgroundColor, let alpha = alphaComponent, alpha > kMinimumAlpha && alpha < kMaximumAlpha {
			allAttributes[.backgroundColor] = backgroundColor.withAlphaComponent(alpha)
		}

		return attributedString(withText: text, attributes: allAttributes)
	}

    func attributedString(withText text: String, attributes: [NSAttributedStringKey: Any]) -> NSAttributedString {
        let transformedText = self.transform(text: text)
        return NSAttributedString(string: transformedText, attributes: attributes)
    }
    
    func fontAndColorAttributes() -> [NSAttributedStringKey: Any] {
        return self.attributes(forKeys: [
            NSAttributedStringKey.font,
            NSAttributedStringKey.foregroundColor,
            NSAttributedStringKey.backgroundColor])
    }
    
    func attributes(forKeys keys: [NSAttributedStringKey]) -> [NSAttributedStringKey: Any] {
        var textAttributes: [NSAttributedStringKey: Any] = [:]
        for key in keys {
            if key == NSAttributedStringKey.paragraphStyle {
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
                    textAttributes[key] = paragraphStyle
                }
            }
            else if key == NSAttributedStringKey.font {
                if let font = self.font {
                    textAttributes[key] = font
                }
            }
            else if key == NSAttributedStringKey.foregroundColor {
                if let color = self.color {
                    textAttributes[key] = color
                }
            }
            else if key == NSAttributedStringKey.backgroundColor {
                if let backgroundColor = self.backgroundColor {
                    textAttributes[key] = backgroundColor
                }
            }
            else {
                assertionFailure("Invalid key \(key) to obtain attribute for")
            }
        }
        
        return textAttributes
    }
    
    func apply(toLabel label: UILabel) {
        self.apply(toLabel: label, withText: nil)
    }
    
    func apply(toLabel label: UILabel, withText text: String?) {
        if let text = text {
            label.text = self.transform(text: text)
        }
        if let font = self.font {
            label.font = font
        }
        label.textAlignment = self.alignment
        label.numberOfLines = self.numberOfLines
        if let color = self.color {
            label.textColor = color
        }
        if let backgroundColor = self.backgroundColor {
            label.backgroundColor = backgroundColor
        }
        if self.sizeToFit {
            label.sizeToFit()
        }
    }

	func apply(toButton button: UIButton, titleForNormalAndHighlightedState title: String, generateMissingHighlightedColorsUsingColorsWithAlphaComponent alphaComponent: CGFloat? = 0.5) {
		let normalTitle = attributedString(withText: title)
		button.setAttributedTitle(normalTitle, for: .normal)
		
		let highlightedTitle = highlightedAttributedString(withText: title, generateMissingHighlightedColorsUsingColorsWithAlphaComponent: alphaComponent)
		button.setAttributedTitle(highlightedTitle, for: .highlighted)
	}
	
	func apply(toButton button: UIButton, titleForDisabledState title: String) {
		let disabledTitle = self.attributedString(withText: title)
		button.setAttributedTitle(disabledTitle, for: .disabled)
	}

}

class DashedBorderSpecifier {
    var lineWidth: Float = 0
    var color: UIColor?
    var cornerRadius: Float = 0
    var paintedSegmentLength: Float = 0
    var spacingSegmentLength: Float = 0
    var insets: UIEdgeInsets = .zero
}

