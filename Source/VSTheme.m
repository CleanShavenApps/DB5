//
//  VSTheme.m
//  Q Branch LLC
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2012 Q Branch LLC. All rights reserved.
//

#import "VSTheme.h"


static BOOL stringIsEmpty(NSString *s);
static UIColor *colorWithHexString(NSString *hexString);

@interface VSTextLabelSpecifier ()
// Redeclare for accessors
@property (nonatomic, strong) NSDictionary *attributes;
@end


@interface VSTheme ()

@property (nonatomic, strong) NSDictionary *themeDictionary;
@property (nonatomic, strong) NSCache *colorCache;
@property (nonatomic, strong) NSCache *fontCache;
@property (nonatomic, strong) NSCache *viewSpecifierCache;
@property (nonatomic, strong) NSCache *navigationBarSpecifierCache;
@property (nonatomic, strong) NSCache *textLabelSpecifierCache;
@end


@implementation VSTheme


#pragma mark Init

- (id)initWithDictionary:(NSDictionary *)themeDictionary {
	
	self = [super init];
	if (self == nil)
		return nil;
	
	_themeDictionary = themeDictionary;

	return self;
}

/**
 
 Lazy accessors for Cache
 
 */

#pragma mark - Lazy Accessors for Cache


- (NSCache *)colorCache {
	
	if (!_colorCache)
		_colorCache = [NSCache new];
	
	return _colorCache;
}


- (NSCache *)fontCache {
	
	if (!_fontCache)
		_fontCache = [NSCache new];
	
	return _fontCache;
}


- (NSCache *)viewSpecifierCache {
	
	if (!_viewSpecifierCache)
		_viewSpecifierCache = [NSCache new];
	
	return _viewSpecifierCache;
}


- (NSCache *)navigationBarSpecifierCache {
	
	if (!_navigationBarSpecifierCache)
		_navigationBarSpecifierCache = [NSCache new];
	
	return _navigationBarSpecifierCache;
}


- (NSCache *)textLabelSpecifierCache {
	
	if (!_textLabelSpecifierCache)
		_textLabelSpecifierCache = [NSCache new];
	
	return _textLabelSpecifierCache;
}


/**
 
 Basic Methods To Obtain Data From Plist
 
 */

#pragma mark - Basic Methods To Obtain Data From Plist


- (id)objectForKey:(NSString *)key {

	id obj = [self.themeDictionary valueForKeyPath:key];
	if (obj == nil && self.parentTheme != nil)
		obj = [self.parentTheme objectForKey:key];
	return obj;
}


- (NSDictionary *)dictionaryForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	return [self dictionaryFromObject:obj];
}


- (NSDictionary *)dictionaryFromObject:(id)obj {
	
	if (obj == nil)
		return nil;
	if ([obj isKindOfClass:[NSDictionary class]])
		return obj;
	return nil;
}


/**
 
 Basic Data Types
 
 */

#pragma mark - Basic Data Types


- (BOOL)boolForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	return [self vs_boolForObject:obj];
}


- (BOOL)vs_boolForObject:(id)obj {
	
	if (obj == nil)
		return NO;
	return [obj boolValue];
}


- (NSString *)stringForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	return [self vs_stringFromObject:obj];
}


- (NSString *)vs_stringFromObject:(id)obj {
	if (obj == nil)
		return nil;
	if ([obj isKindOfClass:[NSString class]])
		return obj;
	if ([obj isKindOfClass:[NSNumber class]])
		return [obj stringValue];
	return nil;
}


- (NSInteger)integerForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	return [self vs_integerFromObject:obj];
}


- (NSInteger)vs_integerFromObject:(id)obj {
	
	if (obj == nil)
		return 0;
	return [obj integerValue];
}


- (CGFloat)floatForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	return [self vs_floatFromObject:obj];
}


- (CGFloat)vs_floatFromObject:(id)obj {
	
	if (obj == nil)
		return  0.0f;
	return [obj floatValue];
}


- (NSTimeInterval)timeIntervalForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	return [self vs_timeIntervalFromObject:obj];
}


- (NSTimeInterval)vs_timeIntervalFromObject:(id)obj {
	
	if (obj == nil)
		return 0.0;
	return [obj doubleValue];
}


/**
 
 Advanced Data Types
 
 */

#pragma mark - Advanced Data Types


- (UIImage *)imageForKey:(NSString *)key {
	
	NSString *imageName = [self stringForKey:key];
	if (stringIsEmpty(imageName))
		return nil;
	
	return [UIImage imageNamed:imageName];
}


- (UIColor *)colorForKey:(NSString *)key {

	UIColor *cachedColor = [self.colorCache objectForKey:key];
	if (cachedColor != nil)
		return cachedColor;
    
	NSDictionary *colorDictionary = [self dictionaryForKey:key];
	UIColor *color = [self vs_colorFromDictionary:colorDictionary];
	
	[self.colorCache setObject:color forKey:key];

	return color;
}


- (UIColor *)vs_colorFromDictionary:(NSDictionary *)colorDictionary {
	
	UIColor *color = nil;
	
	if (colorDictionary) {
		NSString *hexString = [self vs_stringFromObject:colorDictionary[@"hex"]];
		id alphaObject = colorDictionary[@"alpha"];
		
		if (hexString) {
			color = colorWithHexString(hexString);
			
			if (alphaObject != nil) {
				CGFloat alpha = [self vs_floatFromObject:colorDictionary[@"alpha"]];
				color = [color colorWithAlphaComponent:alpha];
			}
		}
		else if (alphaObject)
		{
			CGFloat alpha = [self vs_floatFromObject:colorDictionary[@"alpha"]];
			if (alpha == 0)
			{
				color = [UIColor clearColor];
			}
		}
	}
	
	if (color == nil)
		color = [UIColor blackColor];
	
	return color;
}


- (UIEdgeInsets)edgeInsetsForKey:(NSString *)key {

	NSDictionary *insetsDictionary = [self dictionaryForKey:key];
	UIEdgeInsets edgeInsets = [self vs_edgeInsetsFromDictionary:insetsDictionary];
	return edgeInsets;
}


- (UIEdgeInsets)vs_edgeInsetsFromDictionary:(NSDictionary *)insetsDictionary {
	
	CGFloat left = [self vs_floatFromObject:insetsDictionary[@"left"]];
	CGFloat top = [self vs_floatFromObject:insetsDictionary[@"top"]];
	CGFloat right = [self vs_floatFromObject:insetsDictionary[@"right"]];
	CGFloat bottom = [self vs_floatFromObject:insetsDictionary[@"bottom"]];
	
	UIEdgeInsets edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
	return edgeInsets;
}


- (UIFont *)fontForKey:(NSString *)key {
	
	return [self fontForKey:key sizeAdjustment:0];
}


- (UIFont *)fontForKey:(NSString *)key sizeAdjustment:(CGFloat)sizeAdjustment {
	
	NSString *cacheKey = [key stringByAppendingFormat:@"_%.2f", sizeAdjustment];
	UIFont *cachedFont = [self.fontCache objectForKey:cacheKey];
	if (cachedFont != nil)
		return cachedFont;
    
	NSDictionary *fontDictionary = [self dictionaryForKey:key];
	UIFont *font = [self vs_fontFromDictionary:fontDictionary sizeAdjustment:sizeAdjustment];
    
	[self.fontCache setObject:font forKey:cacheKey];
	
	return font;
}


- (UIFont *)vs_fontFromDictionary:(NSDictionary *)fontDictionary sizeAdjustment:(CGFloat)sizeAdjustment {
	
	NSString *fontName = [self vs_stringFromObject:fontDictionary[@"name"]];
	CGFloat fontSize = [self vs_floatFromObject:fontDictionary[@"size"]];
	
	fontSize += sizeAdjustment;
	
	if (fontSize < 1.0f)
		fontSize = 15.0f;
	
	UIFont *font = nil;
    
	if (stringIsEmpty(fontName))
		font = [UIFont systemFontOfSize:fontSize];
	else
		font = [UIFont fontWithName:fontName size:fontSize];
	
	if (font == nil)
		font = [UIFont systemFontOfSize:fontSize];
    
	return font;
}


- (CGPoint)pointForKey:(NSString *)key {

	NSDictionary *pointDictionary = [self dictionaryForKey:key];
	return [self vs_pointFromDictionary:pointDictionary];
}


- (CGPoint)vs_pointFromDictionary:(NSDictionary *)pointDictionary {
	
	CGFloat pointX = [self vs_floatFromObject:pointDictionary[@"x"]];
	CGFloat pointY = [self vs_floatFromObject:pointDictionary[@"y"]];
	
	CGPoint point = CGPointMake(pointX, pointY);
	return point;
}


- (CGSize)sizeForKey:(NSString *)key {

	NSDictionary *sizeDictionary = [self dictionaryForKey:key];
	return [self vs_sizeFromDictionary:sizeDictionary];
}


- (CGSize)vs_sizeFromDictionary:(NSDictionary *)sizeDictionary {
	
	CGFloat width = [self vs_floatFromObject:sizeDictionary[@"width"]];
	CGFloat height = [self vs_floatFromObject:sizeDictionary[@"height"]];
	
	CGSize size = CGSizeMake(width, height);
	return size;
}


- (UIViewAnimationOptions)vs_curveFromObject:(id)obj {
    
	NSString *curveString = [self vs_stringFromObject:obj];
	if (stringIsEmpty(curveString))
		return UIViewAnimationOptionCurveEaseInOut;

	curveString = [curveString lowercaseString];
	if ([curveString isEqualToString:@"easeinout"])
		return UIViewAnimationOptionCurveEaseInOut;
	else if ([curveString isEqualToString:@"easeout"])
		return UIViewAnimationOptionCurveEaseOut;
	else if ([curveString isEqualToString:@"easein"])
		return UIViewAnimationOptionCurveEaseIn;
	else if ([curveString isEqualToString:@"linear"])
		return UIViewAnimationOptionCurveLinear;
    
	return UIViewAnimationOptionCurveEaseInOut;
}


- (VSAnimationSpecifier *)animationSpecifierForKey:(NSString *)key {

	VSAnimationSpecifier *animationSpecifier = [VSAnimationSpecifier new];

	NSDictionary *animationDictionary = [self dictionaryForKey:key];
	
	animationSpecifier.duration = [self vs_timeIntervalFromObject:animationDictionary[@"duration"]];
	animationSpecifier.delay = [self vs_timeIntervalFromObject:animationDictionary[@"delay"]];
	animationSpecifier.curve = [self vs_curveFromObject:animationDictionary[@"delay"]];

	return animationSpecifier;
}


- (VSTextCaseTransform)textCaseTransformForKey:(NSString *)key {

	NSString *s = [self stringForKey:key];
	return [self vs_textCaseTransformFromString:s];
}


- (VSTextCaseTransform)vs_textCaseTransformFromString:(NSString *)s {
	
	if (s == nil)
		return VSTextCaseTransformNone;
	
	if ([s caseInsensitiveCompare:@"lowercase"] == NSOrderedSame)
		return VSTextCaseTransformLower;
	else if ([s caseInsensitiveCompare:@"uppercase"] == NSOrderedSame)
		return VSTextCaseTransformUpper;
	
	return VSTextCaseTransformNone;
}


- (VSViewSpecifier *)vs_viewSpecifierFromDictionary:(NSDictionary *)dictionary {
	
	if (!dictionary)
		return nil;
	
	VSViewSpecifier *viewSpecifier = [VSViewSpecifier new];
	
	NSDictionary *sizeDictionary = [self dictionaryFromObject:dictionary[@"size"]];
	viewSpecifier.size = [self vs_sizeFromDictionary:sizeDictionary];
	
	NSDictionary *positionDictionary = [self dictionaryFromObject:dictionary[@"position"]];
	viewSpecifier.position = [self vs_pointFromDictionary:positionDictionary];
	
	NSDictionary *backgroundColorDictionary = [self dictionaryFromObject:dictionary[@"backgroundColor"]];
	if (backgroundColorDictionary)
		viewSpecifier.backgroundColor = [self vs_colorFromDictionary:backgroundColorDictionary];
	
	NSDictionary *highlightedBackgroundColorDictionary = [self dictionaryFromObject:dictionary[@"highlightedBackgroundColor"]];
	if (highlightedBackgroundColorDictionary)
		viewSpecifier.highlightedBackgroundColor = [self vs_colorFromDictionary:highlightedBackgroundColorDictionary];
	
	NSDictionary *disabledBackgroundColorDictionary = [self dictionaryFromObject:dictionary[@"disabledBackgroundColor"]];
	if (disabledBackgroundColorDictionary)
		viewSpecifier.disabledBackgroundColor = [self vs_colorFromDictionary:disabledBackgroundColorDictionary];

	NSDictionary *edgeInsetsDictionary = [self dictionaryFromObject:dictionary[@"padding"]];
	viewSpecifier.padding = [self vs_edgeInsetsFromDictionary:edgeInsetsDictionary];
	
	return viewSpecifier;
}


- (VSViewSpecifier *)viewSpecifierForKey:(NSString *)key {
	
	VSViewSpecifier *cachedSpecifier = [self.viewSpecifierCache objectForKey:key];
	if (cachedSpecifier != nil)
		return cachedSpecifier;
	
	NSDictionary *dictionary = [self dictionaryForKey:key];
	
	VSViewSpecifier *viewSpecifier = [self vs_viewSpecifierFromDictionary:dictionary];
	
	if (viewSpecifier)
		[self.viewSpecifierCache setObject:viewSpecifier forKey:key];
	
	return viewSpecifier;
}


- (VSNavigationBarSpecifier *)navigationBarSpecifierForKey:(NSString *)key {
	
	return [self navigationBarSpecifierForKey:key sizeAdjustment:0];
}


- (VSNavigationBarSpecifier *)navigationBarSpecifierForKey:(NSString *)key sizeAdjustment:(CGFloat)sizeAdjustment {
	
	VSNavigationBarSpecifier *cachedSpecifier = [self.navigationBarSpecifierCache objectForKey:key];
	if (cachedSpecifier != nil)
		return cachedSpecifier;
	
	VSNavigationBarSpecifier *navigationBarSpecifier = [VSNavigationBarSpecifier new];
	NSDictionary *dictionary = [self dictionaryForKey:key];
	
	if (!dictionary)
		return nil;
	
	NSDictionary *popoverBackgroundColor = [self dictionaryFromObject:dictionary[@"popoverBackgroundColor"]];
	if (popoverBackgroundColor)
		navigationBarSpecifier.popoverBackgroundColor = [self vs_colorFromDictionary:popoverBackgroundColor];
	
	NSDictionary *barColorDictionary = [self dictionaryFromObject:dictionary[@"barColor"]];
	if (barColorDictionary)
		navigationBarSpecifier.barColor = [self vs_colorFromDictionary:barColorDictionary];
	
	NSDictionary *tintColorDictionary = [self dictionaryFromObject:dictionary[@"tintColor"]];
	if (tintColorDictionary)
		navigationBarSpecifier.tintColor = [self vs_colorFromDictionary:tintColorDictionary];
	
	navigationBarSpecifier.titleLabelSpecifier = [self vs_textLabelSpecifierFromDictionary:dictionary[@"titleLabel"] sizeAdjustment:sizeAdjustment];
	
	navigationBarSpecifier.buttonsLabelSpecifier = [self vs_textLabelSpecifierFromDictionary:dictionary[@"buttonsLabel"] sizeAdjustment:sizeAdjustment];
	
	// isTranslucent by default
	id translucentObject = dictionary[@"translucency"];
	BOOL translucent = translucentObject ? [self vs_boolForObject:translucentObject] : YES;
	navigationBarSpecifier.translucent = translucent;
	
	UIBarStyle barStyle = [self vs_barStyleFromObject:dictionary[@"barStyle"]];
	navigationBarSpecifier.barStyle = barStyle;
	
	[self.navigationBarSpecifierCache setObject:navigationBarSpecifier forKey:key];
	
	return navigationBarSpecifier;
}


- (VSTextLabelSpecifier *)textLabelSpecifierForKey:(NSString *)key {
	
	return [self textLabelSpecifierForKey:key sizeAdjustment:0];
}


- (VSTextLabelSpecifier *)textLabelSpecifierForKey:(NSString *)key sizeAdjustment:(CGFloat)sizeAdjustment {
	
	NSString *cacheKey = [key stringByAppendingFormat:@"_%.2f", sizeAdjustment];
	VSTextLabelSpecifier *cachedSpecifier = [self.textLabelSpecifierCache objectForKey:cacheKey];
	if (cachedSpecifier != nil)
		return cachedSpecifier;
	
	NSDictionary *dictionary = [self dictionaryForKey:key];
	
	VSTextLabelSpecifier *labelSpecifier = [self vs_textLabelSpecifierFromDictionary:dictionary sizeAdjustment:sizeAdjustment];
	
	if (labelSpecifier)
		[self.textLabelSpecifierCache setObject:labelSpecifier forKey:cacheKey];
	
	return labelSpecifier;
}


- (VSTextLabelSpecifier *)vs_textLabelSpecifierFromDictionary:(NSDictionary *)dictionary sizeAdjustment:(CGFloat)sizeAdjustment {
	
	if (!dictionary)
		return nil;
	
	VSTextLabelSpecifier *labelSpecifier = [VSTextLabelSpecifier new];
	
	NSDictionary *fontDictionary = [self dictionaryFromObject:dictionary[@"font"]];
	labelSpecifier.font = [self vs_fontFromDictionary:fontDictionary sizeAdjustment:sizeAdjustment];
	
	NSDictionary *sizeDictionary = [self dictionaryFromObject:dictionary[@"size"]];
	labelSpecifier.size = [self vs_sizeFromDictionary:sizeDictionary];
	
	labelSpecifier.sizeToFit = [self vs_boolForObject:dictionary[@"sizeToFit"]];
	
	NSDictionary *positionDictionary = [self dictionaryFromObject:dictionary[@"position"]];
	labelSpecifier.position = [self vs_pointFromDictionary:positionDictionary];
	
	id numberOfLines = dictionary[@"numberOfLines"];
	if (numberOfLines)
		labelSpecifier.numberOfLines = [self vs_integerFromObject:numberOfLines];
	else
		labelSpecifier.numberOfLines = 1;
	
	labelSpecifier.paragraphSpacing = [self vs_floatFromObject:dictionary[@"paragraphSpacing"]];
	labelSpecifier.paragraphSpacingMultiple = [self vs_floatFromObject:dictionary[@"paragraphSpacingMultiple"]];
	
	labelSpecifier.paragraphSpacingBefore = [self vs_floatFromObject:dictionary[@"paragraphSpacingBefore"]];
	labelSpecifier.paragraphSpacingBeforeMultiple = [self vs_floatFromObject:dictionary[@"paragraphSpacingBeforeMultiple"]];
	
	NSString *alignmentString = [self vs_stringFromObject:dictionary[@"alignment"]];
	labelSpecifier.alignment = [self vs_textAlignmentFromObject:alignmentString];
	
	NSString *lineBreakString = [self vs_stringFromObject:dictionary[@"lineBreakMode"]];
	labelSpecifier.lineBreakMode = [self vs_lineBreakModeFromObject:lineBreakString];
	
	NSString *textTransformString = [self vs_stringFromObject:dictionary[@"textTransform"]];
	labelSpecifier.textTransform = [self vs_textCaseTransformFromString:textTransformString];
	
	NSDictionary *colorDictionary = [self dictionaryFromObject:dictionary[@"color"]];
	if (colorDictionary)
		labelSpecifier.color = [self vs_colorFromDictionary:colorDictionary];
	
	NSDictionary *highlightedColorDictionary = [self dictionaryFromObject:dictionary[@"highlightedColor"]];
	if (highlightedColorDictionary)
		labelSpecifier.highlightedColor = [self vs_colorFromDictionary:highlightedColorDictionary];
	
	NSDictionary *disabledColorDictionary = [self dictionaryFromObject:dictionary[@"disabledColor"]];
	if (disabledColorDictionary)
		labelSpecifier.disabledColor = [self vs_colorFromDictionary:disabledColorDictionary];
	
	NSDictionary *backgroundColorDictionary = [self dictionaryFromObject:dictionary[@"backgroundColor"]];
	if (backgroundColorDictionary)
		labelSpecifier.backgroundColor = [self vs_colorFromDictionary:backgroundColorDictionary];
	
	NSDictionary *highlightedBackgroundColorDictionary = [self dictionaryFromObject:dictionary[@"highlightedBackgroundColor"]];
	if (highlightedBackgroundColorDictionary)
		labelSpecifier.highlightedBackgroundColor = [self vs_colorFromDictionary:highlightedBackgroundColorDictionary];
	
	NSDictionary *disabledBackgroundColorDictionary = [self dictionaryFromObject:dictionary[@"disabledBackgroundColor"]];
	if (disabledBackgroundColorDictionary)
		labelSpecifier.disabledBackgroundColor = [self vs_colorFromDictionary:disabledBackgroundColorDictionary];
	
	NSDictionary *edgeInsetsDictionary = [self dictionaryFromObject:dictionary[@"padding"]];
	labelSpecifier.padding = [self vs_edgeInsetsFromDictionary:edgeInsetsDictionary];
	
	// Generate an attributes dictionary that can be used to style an attributed string
	static NSArray *allAttributes = nil;
	if (!allAttributes) {
		
		allAttributes = @[NSFontAttributeName, NSForegroundColorAttributeName, NSBackgroundColorAttributeName, NSParagraphStyleAttributeName];
	}
	labelSpecifier.attributes = [labelSpecifier attributesForKeys:allAttributes];
	
	return labelSpecifier;
}


- (VSDashedBorderSpecifier *)dashedBorderSpecifierForKey:(NSString *)key
{
	NSDictionary *dictionary = [self dictionaryForKey:key];
	
	if (!dictionary)
		return nil;
	
	VSDashedBorderSpecifier *dashedBorderSpecifier = [VSDashedBorderSpecifier new];
	
	NSDictionary *colorDictionary = [self dictionaryFromObject:dictionary[@"color"]];
	if (colorDictionary)
		dashedBorderSpecifier.color = [self vs_colorFromDictionary:colorDictionary];
	
	dashedBorderSpecifier.lineWidth = [self vs_floatFromObject:dictionary[@"lineWidth"]];
	dashedBorderSpecifier.cornerRadius = [self vs_floatFromObject:dictionary[@"cornerRadius"]];
	dashedBorderSpecifier.paintedSegmentLength = [self vs_floatFromObject:dictionary[@"paintedSegmentLength"]];
	dashedBorderSpecifier.spacingSegmentLength = [self vs_floatFromObject:dictionary[@"spacingSegmentLength"]];
	
	NSDictionary *edgeInsetsDictionary = [self dictionaryFromObject:dictionary[@"insets"]];
	dashedBorderSpecifier.insets = [self vs_edgeInsetsFromDictionary:edgeInsetsDictionary];
	
	return dashedBorderSpecifier;
}


- (NSTextAlignment)textAlignmentForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	return [self vs_textAlignmentFromObject:obj];
}


- (NSTextAlignment)vs_textAlignmentFromObject:(id)obj {
    
	NSString *alignmentString = [self vs_stringFromObject:obj];
	
	if (!stringIsEmpty(alignmentString)) {
		alignmentString = [alignmentString lowercaseString];
		if ([alignmentString isEqualToString:@"left"])
			return NSTextAlignmentLeft;
		else if ([alignmentString isEqualToString:@"center"])
			return NSTextAlignmentCenter;
		else if ([alignmentString isEqualToString:@"right"])
			return NSTextAlignmentRight;
		else if ([alignmentString isEqualToString:@"justified"])
			return NSTextAlignmentJustified;
		else if ([alignmentString isEqualToString:@"natural"])
			return NSTextAlignmentNatural;
	}
    
	return NSTextAlignmentLeft;
}


- (NSLineBreakMode)lineBreakModeForKey:(NSString *)key {

	id obj = [self objectForKey:key];
	return [self vs_lineBreakModeFromObject:obj];
}


- (NSLineBreakMode)vs_lineBreakModeFromObject:(id)obj {
    
	NSString *linebreakString = [self vs_stringFromObject:obj];
	
	if (!stringIsEmpty(linebreakString)) {
		linebreakString = [linebreakString lowercaseString];
		if ([linebreakString isEqualToString:@"wordwrap"])
			return NSLineBreakByWordWrapping;
		else if ([linebreakString isEqualToString:@"charwrap"])
			return NSLineBreakByCharWrapping;
		else if ([linebreakString isEqualToString:@"clip"])
			return NSLineBreakByClipping;
		else if ([linebreakString isEqualToString:@"truncatehead"])
			return NSLineBreakByTruncatingHead;
		else if ([linebreakString isEqualToString:@"truncatetail"])
			return NSLineBreakByTruncatingTail;
		else if ([linebreakString isEqualToString:@"truncatemiddle"])
			return NSLineBreakByTruncatingMiddle;
	}
    
	return NSLineBreakByTruncatingTail;
}


- (UIStatusBarStyle)statusBarStyleForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	return [self vs_statusBarStyleFromObject:obj];
}


- (UIStatusBarStyle)vs_statusBarStyleFromObject:(id)obj {
    
	NSString *statusBarStyleString = [self vs_stringFromObject:obj];
	
	if (!stringIsEmpty(statusBarStyleString)) {
		statusBarStyleString = [statusBarStyleString lowercaseString];
		if ([statusBarStyleString isEqualToString:@"darkcontent"])
			return UIStatusBarStyleDefault;
		else if ([statusBarStyleString isEqualToString:@"lightcontent"])
			return UIStatusBarStyleLightContent;
	}
    
	return UIStatusBarStyleDefault;
}


- (UIBlurEffectStyle)blurEffectStyleForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	return [self vs_blurEffectStyleFromObject:obj];
}


- (UIBlurEffectStyle)vs_blurEffectStyleFromObject:(id)obj {
	
	NSString *statusBarStyleString = [self vs_stringFromObject:obj];
	
	if (!stringIsEmpty(statusBarStyleString)) {
		statusBarStyleString = [statusBarStyleString lowercaseString];
		if ([statusBarStyleString isEqualToString:@"extralight"])
			return UIBlurEffectStyleExtraLight;
		else if ([statusBarStyleString isEqualToString:@"light"])
			return UIBlurEffectStyleLight;
		else if ([statusBarStyleString isEqualToString:@"dark"])
			return UIBlurEffectStyleDark;
		else if ([statusBarStyleString isEqualToString:@"regular"])
			return UIBlurEffectStyleRegular;
		else if ([statusBarStyleString isEqualToString:@"prominent"])
			return UIBlurEffectStyleProminent;
	}
	
	return UIBlurEffectStyleExtraLight;
}


- (UIActivityIndicatorViewStyle)activityIndicatorViewStyleForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	return [self vs_activityIndicatorViewStyleFromObject:obj];
}


- (UIActivityIndicatorViewStyle)vs_activityIndicatorViewStyleFromObject:(id)obj {
	
	NSString *styleString = [self vs_stringFromObject:obj];
	
	if (!stringIsEmpty(styleString)) {
		styleString = [styleString lowercaseString];
		if ([styleString isEqualToString:@"whitelarge"])
			return UIActivityIndicatorViewStyleWhiteLarge;
		else if ([styleString isEqualToString:@"white"])
			return UIActivityIndicatorViewStyleWhite;
		else if ([styleString isEqualToString:@"gray"])
			return UIActivityIndicatorViewStyleGray;
	}
	
	// Default: Gray
	return UIActivityIndicatorViewStyleGray;
}



- (UIBarStyle)barStyleForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	return [self vs_barStyleFromObject:obj];
}


- (UIBarStyle)vs_barStyleFromObject:(id)obj {
	
	NSString *barStyleString = [self vs_stringFromObject:obj];
	
	if (!stringIsEmpty(barStyleString)) {
		barStyleString = [barStyleString lowercaseString];
		if ([barStyleString isEqualToString:@"default"])
			return UIBarStyleDefault;
		else if ([barStyleString isEqualToString:@"black"])
			return UIBarStyleBlack;
	}
	
	return UIBarStyleDefault;
}


- (UIKeyboardAppearance)keyboardAppearanceForKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	return [self vs_keyboardAppearanceFromObject:obj];
}


- (UIKeyboardAppearance)vs_keyboardAppearanceFromObject:(id)obj {
	
	NSString *keyboardAppearanceString = [self vs_stringFromObject:obj];
	
	if (!stringIsEmpty(keyboardAppearanceString)) {
		keyboardAppearanceString = [keyboardAppearanceString lowercaseString];
		if ([keyboardAppearanceString isEqualToString:@"dark"])
			return UIKeyboardAppearanceDark;
		else if ([keyboardAppearanceString isEqualToString:@"light"])
			return UIKeyboardAppearanceLight;
	}
	
	return UIKeyboardAppearanceDefault;
}


/**
 
 Other Public Helper Methods
 
 */

#pragma mark - Other Public Helper Methods


- (BOOL)containsKey:(NSString *)key {
	
	id obj = [self.themeDictionary valueForKeyPath:key];

	if (obj == nil)
		return NO;
	
	return YES;
}


- (BOOL)containsOrInheritsKey:(NSString *)key {
	
	id obj = [self objectForKey:key];
	
	if (obj == nil)
		return NO;
	
	return YES;
}


- (void)clearFontCache {
	
	[self.fontCache removeAllObjects];
}


- (void)clearColorCache {
	
	[self.colorCache removeAllObjects];
}


- (void)clearViewSpecifierCache {
	
	[self.viewSpecifierCache removeAllObjects];
}


- (void)clearNavigationBarSpecifierCache {
	
	[self.navigationBarSpecifierCache removeAllObjects];
}

- (void)clearTextLabelSpecifierCache {
	
	[self.textLabelSpecifierCache removeAllObjects];
}


@end


@implementation VSTheme (Animations)


- (void)animateWithAnimationSpecifierKey:(NSString *)animationSpecifierKey animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {

    VSAnimationSpecifier *animationSpecifier = [self animationSpecifierForKey:animationSpecifierKey];

    [UIView animateWithDuration:animationSpecifier.duration delay:animationSpecifier.delay options:animationSpecifier.curve animations:animations completion:completion];
}


@end


@implementation VSTheme (Labels)


- (UILabel *)labelWithText:(NSString *)text specifierKey:(NSString *)labelSpecifierKey {
	
	return [self labelWithText:text specifierKey:labelSpecifierKey sizeAdjustment:0];
}


- (UILabel *)labelWithText:(NSString *)text specifierKey:(NSString *)labelSpecifierKey sizeAdjustment:(CGFloat)sizeAdjustment {
	
	VSTextLabelSpecifier *textLabelSpecifier = [self textLabelSpecifierForKey:labelSpecifierKey sizeAdjustment:sizeAdjustment];
	
	return [textLabelSpecifier labelWithText:text];
}

@end


@implementation VSTheme (View)

- (UIView *)viewWithViewSpecifierKey:(NSString *)viewSpecifierKey {
	
	VSViewSpecifier *viewSpecifier = [self viewSpecifierForKey:viewSpecifierKey];
	
	CGRect frame;
	frame.size = viewSpecifier.size;
	frame.origin = viewSpecifier.position;
	
	UIView *view = [[UIView alloc] initWithFrame:frame];
	
	view.backgroundColor = viewSpecifier.backgroundColor;
	
	return view;
}

@end


#pragma mark -


@implementation VSAnimationSpecifier

@end


@implementation VSViewSpecifier

- (UIColor *)backgroundColorForState:(UIControlState)state {
	
	UIColor *color = nil;
	
	switch (state) {
		case UIControlStateNormal: {
			color = self.backgroundColor;
			break;
		}
			
		case UIControlStateHighlighted: {
			color = self.highlightedBackgroundColor;
			break;
		}
			
		case UIControlStateDisabled: {
			color = self.disabledBackgroundColor;
			break;
		}
			
		default:
			break;
	}
	
	return color;
}

@end


@implementation VSNavigationBarSpecifier

- (void)applyToNavigationBar:(UINavigationBar *)navigationBar containedInClass:(Class)containingClass {
	
	if (self.barColor)
	{
		navigationBar.barTintColor = self.barColor;
	}
	
	if (self.tintColor)
	{
		navigationBar.tintColor = self.tintColor;
	}
	
	navigationBar.translucent = self.translucent;
	
	if (self.titleLabelSpecifier)
	{
		NSDictionary *attributes =
		[self.titleLabelSpecifier attributesForKeys:@[NSFontAttributeName, NSForegroundColorAttributeName]];
		
		if (attributes)
		{
			navigationBar.titleTextAttributes = attributes;
		}
	}

	if (self.buttonsLabelSpecifier)
	{
		NSDictionary *attributes =
		[self.buttonsLabelSpecifier attributesForKeys:@[NSFontAttributeName, NSForegroundColorAttributeName]];
		
		if (attributes)
		{
			if (containingClass)
			{
				[[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class], containingClass]]
				 setTitleTextAttributes:attributes
				 forState:UIControlStateNormal];
			}
			else
			{
				[[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]]
				 setTitleTextAttributes:attributes
				 forState:UIControlStateNormal];
			}
		}
	}
}

@end


@implementation VSTextLabelSpecifier

- (UILabel *)labelWithText:(NSString *)text {
	
	CGRect frame;
	frame.size = self.size;
	frame.origin = self.position;

	return [self labelWithText:text frame:frame];
}

- (UILabel *)labelWithText:(NSString *)text frame:(CGRect)frame {
	
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	[self applyToLabel:label withText:text];
	return label;
}

- (NSString *)transformText:(NSString *)originalText {
	
	NSString *transformedText = nil;
	
	switch (self.textTransform) {
		case VSTextCaseTransformUpper:
		{
			transformedText = [originalText uppercaseString];
			break;
		}
			
		case VSTextCaseTransformLower:
		{
			transformedText = [originalText lowercaseString];
			break;
		}
			
		case VSTextCaseTransformNone:
		default:
		{
			transformedText = originalText;
			break;
		}
	}
	
	return transformedText;
}

- (NSArray *)vs_defaultTextLabelAttributes {
	return @[NSFontAttributeName, NSForegroundColorAttributeName, NSBackgroundColorAttributeName, NSParagraphStyleAttributeName];
}

- (NSAttributedString *)attributedStringWithText:(NSString *)text {

	return [self attributedStringWithText:text attributes:[self attributesForKeys:[self vs_defaultTextLabelAttributes]]];
}

- (NSAttributedString *)attributedStringWithText:(NSString *)text forState:(UIControlState)state generateMissingColorsUsingAlphaOfNormalColors:(NSNumber *)alpha {

	UIColor *customForeground = nil;
	UIColor *customBackground = nil;
	
	switch (state) {
		case UIControlStateNormal: {
			customForeground = self.color;
			customBackground = self.backgroundColor;
			break;
		}
			
		case UIControlStateHighlighted: {
			customForeground = self.highlightedColor;
			customBackground = self.highlightedBackgroundColor;
			break;
		}
			
		case UIControlStateDisabled: {
			customForeground = self.disabledColor;
			customBackground = self.disabledBackgroundColor;
			break;
		}
			
		default: {
			// We're generating optional custom foreground or background colors.
			// If an invalid state is provided then we just ignore it and pass
			// no custom colors
			break;
		}
	}
	
	// Generate missing colors if necessary
	switch (state) {
		case UIControlStateHighlighted:
		case UIControlStateDisabled: {
			if (alpha != nil) {
				if (customForeground == nil) {
					customForeground = [self.color colorWithAlphaComponent:alpha.doubleValue];
				}
				
				if (customBackground == nil) {
					customBackground = [self.backgroundColor colorWithAlphaComponent:alpha.doubleValue];
				}
			}
			break;
		}
			
		default:
			break;
	}
	
	NSDictionary *attributes = [self attributesForKeys:[self vs_defaultTextLabelAttributes] customForegroundColor:customForeground customBackgroundColor:customBackground];
	
	return [self attributedStringWithText:text attributes:attributes];

}

- (NSAttributedString *)attributedStringWithText:(NSString *)text attributes:(NSDictionary *)attributes {
	
	NSString *transformedText = [self transformText:text];
	
	return [[NSAttributedString alloc] initWithString:transformedText attributes:attributes];
}

- (NSDictionary *)fontAndColorAttributes {
	
	return [self attributesForKeys:@[NSFontAttributeName, NSForegroundColorAttributeName, NSBackgroundColorAttributeName]];
}

- (NSDictionary *)attributesForKeys:(NSArray *)keys {
	
	return [self attributesForKeys:keys customForegroundColor:nil customBackgroundColor:nil];
}

- (NSDictionary *)attributesForKeys:(NSArray *)keys customForegroundColor:(UIColor *)customForegroundColor customBackgroundColor:(UIColor *)customBackgroundColor {
	
	NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] initWithCapacity:[keys count]];
	
	[keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
		
		if ([key isEqualToString:NSParagraphStyleAttributeName]) {
			
			NSMutableParagraphStyle *paragraphStyle =
			[[NSParagraphStyle defaultParagraphStyle] mutableCopy];
			
			paragraphStyle.lineBreakMode = self.lineBreakMode;
			paragraphStyle.alignment = self.alignment;

			if (self.paragraphSpacingMultiple>0 && self.font)
			{
				paragraphStyle.paragraphSpacing = self.font.pointSize * self.paragraphSpacingMultiple;
			}
			else if (self.paragraphSpacing>0)
			{
				paragraphStyle.paragraphSpacing = self.paragraphSpacing;
			}
			
			if (self.paragraphSpacingBeforeMultiple>0 && self.font)
			{
				paragraphStyle.paragraphSpacingBefore = self.font.pointSize * self.paragraphSpacingBeforeMultiple;
			}
			else if (self.paragraphSpacingBefore>0)
			{
				paragraphStyle.paragraphSpacingBefore = self.paragraphSpacingBefore;
			}

			textAttributes[key] = paragraphStyle;
			
		} else if ([key isEqualToString:NSFontAttributeName]) {
			
			if (self.font)
				textAttributes[key] = self.font;
			
		} else if ([key isEqualToString:NSForegroundColorAttributeName]) {
			
			if (customForegroundColor)
				textAttributes[key] = customForegroundColor;
			else if (self.color)
				textAttributes[key] = self.color;
			
		} else if ([key isEqualToString:NSBackgroundColorAttributeName]) {
			
			if (customBackgroundColor)
				textAttributes[key] = customBackgroundColor;
			else if (self.backgroundColor)
				textAttributes[key] = self.backgroundColor;
			
		} else {
			
			NSAssert(0, @"Invalid key %@ to obtain attribute for", key);
			
		}
		
	}];
	
	return [textAttributes copy];
}

- (void)applyToLabel:(UILabel *)label {
	
	[self applyToLabel:label withText:nil];
}

- (void)applyToLabel:(UILabel *)label withText:(NSString *)text {
	
	if (text)
	{
		label.text = [self transformText:text];
	}
	label.font = self.font;
	label.textAlignment = self.alignment;
	label.numberOfLines = self.numberOfLines;
	
	if (self.color)
		label.textColor = self.color;
	
	if (self.backgroundColor)
		label.backgroundColor = self.backgroundColor;
	
	if (self.sizeToFit)
		[label sizeToFit];
}

- (void)applyToButton:(UIButton *)button title:(NSString *)title state:(UIControlState)state {

	NSAttributedString *attributedTitle = [self attributedStringWithText:title forState: state generateMissingColorsUsingAlphaOfNormalColors:nil];
	[button setAttributedTitle:attributedTitle forState:state];
}

- (void)applyToButton:(UIButton *)button titleForNormalAndHighlightedState:(NSString *)title generateMissingHighlightedColorsUsingColorsWithAlphaComponent:(NSNumber *)alphaComponent {
	
	NSAttributedString *normalTitle = [self attributedStringWithText:title];
	[button setAttributedTitle:normalTitle forState:UIControlStateNormal];
	
	NSAttributedString *highlightedTitle = [self attributedStringWithText:title forState:UIControlStateHighlighted generateMissingColorsUsingAlphaOfNormalColors:alphaComponent];
	[button setAttributedTitle:highlightedTitle forState:UIControlStateHighlighted];
}

- (void)applyToButton:(UIButton *)button titleForNormalAndHighlightedState:(NSString *)title {
	
	[self applyToButton:button titleForNormalAndHighlightedState:title generateMissingHighlightedColorsUsingColorsWithAlphaComponent:@0.5];
}

- (void)applyToButton:(UIButton *)button titleForDisabledState:(NSString *)title {
	
	NSAttributedString *disabledTitle = [self attributedStringWithText:title];
	[button setAttributedTitle:disabledTitle forState:UIControlStateDisabled];
}

@end



@implementation VSDashedBorderSpecifier

// Nothing to implement

@end



static BOOL stringIsEmpty(NSString *s) {
	return s == nil || [s length] == 0;
}


static UIColor *colorWithHexString(NSString *hexString) {

	/*Picky. Crashes by design.*/
	
	if (stringIsEmpty(hexString))
		return [UIColor blackColor];

	NSMutableString *s = [hexString mutableCopy];
	[s replaceOccurrencesOfString:@"#" withString:@"" options:0 range:NSMakeRange(0, [hexString length])];
	CFStringTrimWhitespace((__bridge CFMutableStringRef)s);

	NSString *redString = [s substringToIndex:2];
	NSString *greenString = [s substringWithRange:NSMakeRange(2, 2)];
	NSString *blueString = [s substringWithRange:NSMakeRange(4, 2)];

	unsigned int red = 0, green = 0, blue = 0;
	[[NSScanner scannerWithString:redString] scanHexInt:&red];
	[[NSScanner scannerWithString:greenString] scanHexInt:&green];
	[[NSScanner scannerWithString:blueString] scanHexInt:&blue];

	return [UIColor colorWithRed:(CGFloat)red/255.0f green:(CGFloat)green/255.0f blue:(CGFloat)blue/255.0f alpha:1.0f];
}
