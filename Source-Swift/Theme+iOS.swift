//
//  Theme+iOS.swift
//  CurrencyConverter_iOS
//
//  Created by Hon Cheng Muh on 13/10/18.
//  Copyright © 2018 Clean Shaven Apps Pte. Ltd. All rights reserved.
//

import UIKit

public extension Theme {
    
    private func curve(fromObject object: Any?) -> UIView.AnimationOptions {
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
    
    func statusBarStyle(forKey key: String) -> UIStatusBarStyle {
        let obj = self.object(forKey: key)
        return self.statusBarStyle(fromObject: obj)
    }
    
    private func statusBarStyle(fromObject object: Any?) -> UIStatusBarStyle {
        guard let statusBarStyleString = self.string(fromObject: object)?.lowercased(), stringIsEmpty(s: statusBarStyleString) == false else {
            return .default
        }
        
        switch statusBarStyleString {
        case "darkcontent":
			if #available(iOSApplicationExtension 13.0, *) {
				return .darkContent
			} else {
				// Fallback on earlier versions
				return .default
			}
        case "lightcontent":
            return .lightContent
        default:
            return .default
        }
    }
	
	func scrollViewIndicatorStyle(forKey key: String) -> UIScrollView.IndicatorStyle {
		let obj = self.object(forKey: key)
        return self.scrollViewIndicatorStyle(fromObject: obj)
	}
	
	private func scrollViewIndicatorStyle(fromObject object: Any?) -> UIScrollView.IndicatorStyle {
        guard let scrollViewIndicatorStyleString = self.string(fromObject: object)?.lowercased(), stringIsEmpty(s: scrollViewIndicatorStyleString) == false else {
            return .default
        }
        
        switch scrollViewIndicatorStyleString {
        case "white":
			return .default
        case "black":
            return .black
        default:
            return .default
        }
	}
	
	func userInterfaceStyle(forKey key: String) -> UIUserInterfaceStyle {
		let obj = self.object(forKey: key)
        return self.userInterfaceStyle(fromObject: obj)
	}
	
	private func userInterfaceStyle(fromObject object: Any?) -> UIUserInterfaceStyle {
        guard let userInterfaceStyleString = self.string(fromObject: object)?.lowercased(), stringIsEmpty(s: userInterfaceStyleString) == false else {
            return .unspecified
        }
        
        switch userInterfaceStyleString {
        case "light":
			return .light
        case "dark":
            return .dark
        default:
            return .unspecified
        }
	}
    
    /** Where the possible values are extralight, light, dark, regular, prominent */
    func blueEffectStyle(forKey key: String) -> UIBlurEffect.Style {
        let obj = self.object(forKey: key)
        return blurEffectStyle(fromObject: obj)
    }
    
    private func blurEffectStyle(fromObject object: Any?) -> UIBlurEffect.Style {
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
    
    /** Where the possible values are whitelarge, white, gray. Defaults to gray */
    func activityIndicatorViewStyle(forKey key: String) -> UIActivityIndicatorView.Style {
        let obj = self.object(forKey: key)
        return activityIndicatorViewStyle(fromObject: obj)
    }
    
    private func activityIndicatorViewStyle(fromObject object: Any?) -> UIActivityIndicatorView.Style {
        guard let barStyleString = string(fromObject: object)?.lowercased(), stringIsEmpty(s: barStyleString) == false else {
            return .gray
        }
        
        switch barStyleString {
        case "whitelarge":
            return .whiteLarge
        case "white":
            return .white
        case "gray":
            return .gray
        default:
            return .gray
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
    
//    public func textLabelSpecifier(forKey key: String) -> TextLabelSpecifier? {
//        return self.textLabelSpecifier(forKey: key, sizeAdjustment: 0)
//    }
//    
//    public func textLabelSpecifier(forKey key: String, sizeAdjustment: Float) -> TextLabelSpecifier? {
//        let cacheKey = key.appendingFormat("_%.2f", sizeAdjustment)
//        guard let cachedSpecifier = self.textLabelSpecifierCache.object(forKey: cacheKey as NSString) else {
//            let dictionary = self.dictionary(forKey: key)
//            let labelSpecifier = self.textLabelSpecifier(fromDictionary: dictionary, sizeAdjustment: sizeAdjustment)
//            if let labelSpecifier = labelSpecifier {
//                self.textLabelSpecifierCache.setObject(labelSpecifier, forKey: cacheKey as NSString)
//            }
//            return labelSpecifier
//        }
//        return cachedSpecifier
//    }
//    
//    public func textLabelSpecifier(fromDictionary dictionary: [String: Any]?, sizeAdjustment: Float) -> TextLabelSpecifier? {
//        
//        guard let dictionary = dictionary else {
//            return nil
//        }
//        
//        let labelSpecifier = TextLabelSpecifier()
//        
//        let fontDictionary = self.dictionary(fromObject: dictionary["font"])
//        labelSpecifier.font = self.font(fromDictionary: fontDictionary, sizeAdjustment: sizeAdjustment)
//        
//        let sizeDictionary = self.dictionary(fromObject: dictionary["size"])
//        labelSpecifier.size = self.size(fromDictionary: sizeDictionary)
//        
//        labelSpecifier.sizeToFit = self.bool(forObject: dictionary["sizeToFit"])
//        
//        let positionDictionary = self.dictionary(fromObject: dictionary["position"])
//        labelSpecifier.position = self.point(fromDictionary: positionDictionary)
//        
//        if let numberOfLines = dictionary["numberOfLines"] {
//            labelSpecifier.numberOfLines = self.integer(fromObject: numberOfLines)
//        }
//        else {
//            labelSpecifier.numberOfLines = 1
//        }
//        
//        labelSpecifier.paragraphSpacing = self.float(fromObject: dictionary["paragraphSpacing"])
//        labelSpecifier.paragraphSpacingMultiple = self.float(fromObject: dictionary["paragraphSpacingMultiple"])
//        labelSpecifier.paragraphSpacingBefore = self.float(fromObject: dictionary["paragraphSpacingBefore"])
//        labelSpecifier.paragraphSpacingBeforeMultiple = self.float(fromObject: dictionary["paragraphSpacingBeforeMultiple"])
//        
//        labelSpecifier.lineSpacingMultiple = self.float(fromObject: dictionary["lineSpacingMultiple"])
//        
//        let alignmentString = self.string(fromObject: dictionary["alignment"])
//        labelSpecifier.alignment = self.textAlignment(fromObject: alignmentString)
//        
//        let lineBreakString = self.string(fromObject: dictionary["lineBreakMode"])
//        labelSpecifier.lineBreakMode = self.lineBreakMode(fromObject: lineBreakString)
//        
//        let textTransformString = self.string(fromObject: dictionary["textTransform"])
//        labelSpecifier.textTransform = self.textCaseTransform(fromString: textTransformString)
//        
//        if let colorDictionary = self.dictionary(fromObject: dictionary["color"]) {
//            labelSpecifier.color = self.color(fromDictionary: colorDictionary)
//        }
//        
//        if let highlightedColorDictionary = self.dictionary(fromObject: dictionary["highlightedColor"]) {
//            labelSpecifier.highlightedColor = self.color(fromDictionary: highlightedColorDictionary)
//        }
//        
//        if let disabledColorDictionary = self.dictionary(fromObject: dictionary["disabledColor"]) {
//            labelSpecifier.disabledColor = self.color(fromDictionary: disabledColorDictionary)
//        }
//        
//        if let backgroundColorDictionary = self.dictionary(fromObject: dictionary["backgroundColor"]) {
//            labelSpecifier.backgroundColor = self.color(fromDictionary: backgroundColorDictionary)
//        }
//        
//        if let highlightedBackgroundColorDictionary = self.dictionary(fromObject: dictionary["highlightedBackgroundColor"]) {
//            labelSpecifier.highlightedBackgroundColor = self.color(fromDictionary: highlightedBackgroundColorDictionary)
//        }
//        
//        if let disabledBackgroundColorDictionary = self.dictionary(fromObject: dictionary["disabledBackgroundColor"]) {
//            labelSpecifier.disabledBackgroundColor = self.color(fromDictionary: disabledBackgroundColorDictionary)
//        }
//        
//        let edgeInsetsDictionary = self.dictionary(fromObject: dictionary["padding"])
//        labelSpecifier.padding = self.edgeInsets(fromDictionary: edgeInsetsDictionary)
//        
//        let allAttributes = [
//            NSAttributedStringKey.font,
//            NSAttributedStringKey.foregroundColor,
//            NSAttributedStringKey.backgroundColor,
//            NSAttributedStringKey.paragraphStyle]
//        labelSpecifier.attributes = labelSpecifier.attributes(forKeys: allAttributes)
//        return labelSpecifier
//    }
    
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
    
}

public extension Theme {
    
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

public class AnimationSpecifier {
    public var delay: TimeInterval = 0
    public var duration: TimeInterval = 0
    public var curve: UIView.AnimationOptions = .curveEaseInOut
}

public class NavigationBarSpecifier {
    
    public var translucent: Bool = false
    public var barStyle: UIBarStyle = .default
    public var popoverBackgroundColor: UIColor?
    public var barColor: UIColor?
    public var tintColor: UIColor?
    public var titleLabelSpecifier: TextLabelSpecifier?
    public var buttonsLabelSpecifier: TextLabelSpecifier?
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
                NSAttributedString.Key.font,
                NSAttributedString.Key.foregroundColor])
            navigationBar.titleTextAttributes = attributes
        }
        
        if let buttonsLabelSpecifier = self.buttonsLabelSpecifier {
            let attributes = buttonsLabelSpecifier.attributes(forKeys: [
                NSAttributedString.Key.font,
                NSAttributedString.Key.foregroundColor])
            if let containingClass = containingClass {
                UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self, containingClass]).setTitleTextAttributes(attributes, for: .normal)
            }
            else {
                UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleTextAttributes(attributes, for: .normal)
            }
        }
    }
}

public class TextLabelSpecifier {
    
    var font: UIFont?
	var boldFont: UIFont?
	var italicFont: UIFont?
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
    var attributes: [NSAttributedString.Key: Any]?
    
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
    
    private lazy var defaultTextLabelAttributes = {
		return [NSAttributedString.Key.font,
				NSAttributedString.Key.foregroundColor,
                NSAttributedString.Key.backgroundColor,
                NSAttributedString.Key.paragraphStyle]
    }()
    
	func attributedString(withText text: String, forState state: UIControl.State = .normal, generateMissingColorsUsingAlphaOfNormalColors alpha: CGFloat? = nil) -> NSAttributedString {
        
        var customForeground: UIColor?
        var customBackground: UIColor?
        
        switch state {
        case .normal:
            customForeground = self.color
            customBackground = self.backgroundColor
        case .highlighted:
            customForeground = self.highlightedColor
            customBackground = self.highlightedBackgroundColor
        case .disabled:
            customForeground = self.disabledColor
            customBackground = self.disabledBackgroundColor
        default:
            // We're generating optional custom foreground or background colors.
            // If an invalid state is provided then we just ignore it and pass
            // no custom colors
            break
        }
        
        // Generate missing colors if necessary
        switch state {
        case .highlighted, .disabled:
            if let alpha = alpha {
                if customForeground == nil, let normalForeground = self.color {
                    customForeground = normalForeground.withAlphaComponent(alpha)
                }
                
                if customBackground == nil, let normalBackground = self.backgroundColor {
                    customBackground = normalBackground.withAlphaComponent(alpha)
                }
            }
        default:
            break
        }
        
        let attributes = self.attributes(forKeys: defaultTextLabelAttributes, customForegroundColor: customForeground, customBackgroundColor: customBackground)
        
        return self.attributedString(withText: text, attributes: attributes)
    }
    
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
    
	func attributes(forKeys keys: [NSAttributedString.Key], customForegroundColor: UIColor? = nil, customBackgroundColor: UIColor? = nil) -> [NSAttributedString.Key: Any] {
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
    
    func apply(toButton button: UIButton, title: String, states: [UIControl.State]) {
        for state in states {
            let attributedTitle = attributedString(withText: title, forState: state)
            button.setAttributedTitle(attributedTitle, for: state)
        }
    }
    
    func apply(toButton button: UIButton, titleForNormalAndHighlightedState title: String, generateMissingHighlightedColorsUsingColorsWithAlphaComponent alphaComponent: CGFloat? = 0.5) {
        let normalTitle = attributedString(withText: title)
        button.setAttributedTitle(normalTitle, for: .normal)
        
        let highlightedTitle = attributedString(withText: title, forState: .highlighted, generateMissingColorsUsingAlphaOfNormalColors: alphaComponent)
        button.setAttributedTitle(highlightedTitle, for: .highlighted)
    }
    
    func apply(toButton button: UIButton, titleForDisabledState title: String) {
        let disabledTitle = self.attributedString(withText: title)
        button.setAttributedTitle(disabledTitle, for: .disabled)
    }
}



