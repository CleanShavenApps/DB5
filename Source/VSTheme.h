//
//  VSTheme.h
//  Q Branch LLC
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2012 Q Branch LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, VSTextCaseTransform) {
    VSTextCaseTransformNone,
    VSTextCaseTransformUpper,
    VSTextCaseTransformLower
};


@class VSAnimationSpecifier, VSViewSpecifier, VSNavigationBarSpecifier, VSTextLabelSpecifier, VSDashedBorderSpecifier;

@interface VSTheme : NSObject

- (id)initWithDictionary:(NSDictionary *)themeDictionary;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, weak) VSTheme *parentTheme; /*can inherit*/

- (BOOL)boolForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (CGFloat)floatForKey:(NSString *)key;
- (NSTimeInterval)timeIntervalForKey:(NSString *)key;

/** Via \c +UIImage imageNamed: */
- (UIImage *)imageForKey:(NSString *)key;

/** Dictionary with hex key containing 123ABC or #123ABC: 6 digits, leading # allowed but not required, and optional alpha key containing number 0-1 */
- (UIColor *)colorForKey:(NSString *)key;

/** Dictionary with top, left, right, bottoms keys */
- (UIEdgeInsets)edgeInsetsForKey:(NSString *)key;

/** Dictionary with name key containing the fully specified name fo the font, and size key containing size of the font in points */
- (UIFont *)fontForKey:(NSString *)key;

/** Dictionary with name key containing the fully specified name fo the font, and size key containing size of the font in points. Optionally make adjustment to the size of the font by providing a positive or negative value in sizeAdjustment */
- (UIFont *)fontForKey:(NSString *)key sizeAdjustment:(CGFloat)sizeAdjustment;

/** Dictionary with x and y keys */
- (CGPoint)pointForKey:(NSString *)key;

/** Dictionary with width and height keys */
- (CGSize)sizeForKey:(NSString *)key;

/** Dictionary containing the keys duration, delay and curve, where the possible values for curve are easeinout, easeout, easein, linear */
- (VSAnimationSpecifier *)animationSpecifierForKey:(NSString *)key;

/** lowercase or uppercase -- returns VSTextCaseTransformNone */
- (VSTextCaseTransform)textCaseTransformForKey:(NSString *)key;

- (VSViewSpecifier *)viewSpecifierForKey:(NSString *)key;

- (VSNavigationBarSpecifier *)navigationBarSpecifierForKey:(NSString *)key;

- (VSNavigationBarSpecifier *)navigationBarSpecifierForKey:(NSString *)key sizeAdjustment:(CGFloat)sizeAdjustment;

- (VSTextLabelSpecifier *)textLabelSpecifierForKey:(NSString *)key;

/** Optionally make adjustment to the size of the font by providing a positive or negative value in sizeAdjustment */
- (VSTextLabelSpecifier *)textLabelSpecifierForKey:(NSString *)key sizeAdjustment:(CGFloat)sizeAdjustment;

- (VSDashedBorderSpecifier *)dashedBorderSpecifierForKey:(NSString *)key;

/** Where the possible values for text alignment are left, center, right, justified, natural */
- (NSTextAlignment)textAlignmentForKey:(NSString *)key;

/** Where the possible values for line break mode are wordwrap, charwrap, clip, truncatehead, truncatetail, truncatemiddle */
- (NSLineBreakMode)lineBreakModeForKey:(NSString *)key;

/** Where the possible values are darkcontent, lightcontent */
- (UIStatusBarStyle)statusBarStyleForKey:(NSString *)key;

/** Where the possible values are extralight, light, dark, regular, prominent */
- (UIBlurEffectStyle)blurEffectStyleForKey:(NSString *)key;

/** Where the possible values are default, black */
- (UIBarStyle)barStyleForKey:(NSString *)key;

/** Where the possible values are default, dark, light */
- (UIKeyboardAppearance)keyboardAppearanceForKey:(NSString *)key;

/** Returns YES only if the theme explicitly provides the key */
- (BOOL)containsKey:(NSString *)key;

/** Returns YES if either the theme or the parent provides the key */
- (BOOL)containsOrInheritsKey:(NSString *)key;

- (void)clearFontCache;
- (void)clearColorCache;
- (void)clearViewSpecifierCache;
- (void)clearNavigationBarSpecifierCache;
- (void)clearTextLabelSpecifierCache;

@end


@interface VSTheme (Animations)

- (void)animateWithAnimationSpecifierKey:(NSString *)animationSpecifierKey animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

@end


@interface VSTheme (Labels)

- (UILabel *)labelWithText:(NSString *)text specifierKey:(NSString *)labelSpecifierKey;

- (UILabel *)labelWithText:(NSString *)text specifierKey:(NSString *)labelSpecifierKey sizeAdjustment:(CGFloat)sizeAdjustment;

@end


@interface VSTheme (View)

- (UIView *)viewWithViewSpecifierKey:(NSString *)viewSpecifierKey;

@end


@interface VSAnimationSpecifier : NSObject

@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) UIViewAnimationOptions curve;

@end


@interface VSViewSpecifier : NSObject

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, copy) UIColor *backgroundColor;
@property (nonatomic, copy) UIColor *highlightedBackgroundColor;
@property (nonatomic, copy) UIColor *disabledBackgroundColor;

/** Not used when creating a view \c -viewWithViewSpecifierKey:. How padding
 affect the view to be interpreted by interested party. */
@property (nonatomic, assign) UIEdgeInsets padding;

@end


@interface VSNavigationBarSpecifier : NSObject

@property (nonatomic) BOOL translucent;
@property (nonatomic) UIBarStyle barStyle;
@property (nonatomic, copy) UIColor *popoverBackgroundColor;
@property (nonatomic, copy) UIColor *barColor;
@property (nonatomic, copy) UIColor *tintColor;
@property (nonatomic, strong) VSTextLabelSpecifier *titleLabelSpecifier;
@property (nonatomic, strong) VSTextLabelSpecifier *buttonsLabelSpecifier;

/// Specify a containing class to limit the customization to bar button items
/// in the navigation bar of the containing class
- (void)applyToNavigationBar:(UINavigationBar *)navigationBar containedInClass:(Class)containingClass;

@end


@interface VSTextLabelSpecifier : NSObject

@property (nonatomic, assign) UIFont *font;
@property (nonatomic, assign) CGSize size;
/** If YES, \c size should be ignored when creating a text label from it */
@property (nonatomic, assign) BOOL sizeToFit;
@property (nonatomic, assign) CGPoint position;
/** Default: 1 (single line) */
@property (nonatomic, assign) NSInteger numberOfLines;

@property (nonatomic, assign) CGFloat paragraphSpacing;
@property (nonatomic, assign) CGFloat paragraphSpacingBefore;
/// If multiple is > 0, takes precedence over paragraphSpacing
@property (nonatomic, assign) CGFloat paragraphSpacingMultiple;
/// If multiple is > 0, takes precedence over paragraphSpacingBefore
@property (nonatomic, assign) CGFloat paragraphSpacingBeforeMultiple;

@property (nonatomic, assign) NSTextAlignment alignment;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;
@property (nonatomic, assign) VSTextCaseTransform textTransform;
@property (nonatomic, copy) UIColor *color;
@property (nonatomic, copy) UIColor *highlightedColor;
@property (nonatomic, copy) UIColor *disabledColor;
@property (nonatomic, copy) UIColor *backgroundColor;
@property (nonatomic, copy) UIColor *highlightedBackgroundColor;
@property (nonatomic, copy) UIColor *disabledBackgroundColor;

/** Not used when creating a view \c -labelWithText:specifierKey:sizeAdjustment:
 How padding affect the text label to be interpreted by interested party. */
@property (nonatomic, assign) UIEdgeInsets padding;

/** Attributes representing the font, color, backgroundColor, alignment and lineBreakMode */
@property (nonatomic, strong, readonly) NSDictionary *attributes;

- (UILabel *)labelWithText:(NSString *)text;
- (UILabel *)labelWithText:(NSString *)text frame:(CGRect)frame;

/** Returns the originalText after applying the text transformation. */
- (NSString *)transformText:(NSString *)originalText;

/** Returns an attributed string with attributes specified in the receiver's
 attributes dictionary and by applying any transformation to the text */
- (NSAttributedString *)attributedStringWithText:(NSString *)text;

/**
 Returns a highlighted attributed string for use in the attributed title
 of the highlighted state of a UIButton, using attributes specified in the
 receiver's attributes dictionary, and by applying any transformation to the
 text.

 @param text The text to use for the attributed string
 @param alphaComponent If the specifier is missing highlightedColor or
 highlightedBackgroundColor, specify a opacity from 0–1 to automatically
 generate the highlightedColor and highlightedBackgroundColor based on the
 color and backgroundColor
 @return An attributed string meant for the highlighted state of a UIButton
 */
- (NSAttributedString *)highlightedAttributedStringWithText:(NSString *)text generateMissingHighlightedColorsUsingColorsWithAlphaComponent:(NSNumber *)alphaComponent;

/** Returns an attributed string with attributes specified in the attributes
 dictionary and by applying any transformation to the text */
- (NSAttributedString *)attributedStringWithText:(NSString *)text attributes:(NSDictionary *)attributes;

/** Returns the attributes that can be used to make an \c NSAttributedString by
 populating the keys with the appropriate values. Valid keys are
 \c NSFontAttributeName, \c NSParagraphStyleAttributeName,
 \c NSForegroundColorAttributeName, \c NSBackgroundColorAttributeName */
- (NSDictionary *)attributesForKeys:(NSArray *)keys;

/** Convenience accessor that returns the attributes \c NSFontAttributeName,
 \c NSForegroundColorAttributeName, \c NSBackgroundColorAttributeName */
- (NSDictionary *)fontAndColorAttributes;

/**
 Apply the specifier attributes to the label
 */
- (void)applyToLabel:(UILabel *)label;

/**
 Apply the specifier attributes to the label, setting and transforming text
 */
- (void)applyToLabel:(UILabel *)label withText:(NSString *)text;

/**
 Apply the specifier attributes to the button the attributed title for
 normal and highlighted state. If highlighted colors are not specified,
 automatically generate them from the normal color attributes using the
 specified alpha component.

 @param button The button to apply the attributed title for normal and
 highlighted states
 @param title The text to use for the title of the button in normal and
 highlighted states
 @param alphaComponent If nil, does not attempt to generate missing
 highlighted colors. It will fallback to using the normal color attributes.
 */
- (void)applyToButton:(UIButton *)button titleForNormalAndHighlightedState:(NSString *)title generateMissingHighlightedColorsUsingColorsWithAlphaComponent:(NSNumber *)alphaComponent;

/**
 Apply the specifier attributes to the button the attributed title for
 normal and highlighted state. If highlighted colors are not specified,
 automatically generate them from the normal color attributes by fading
 them to 50% of the normal colors.
 */
- (void)applyToButton:(UIButton *)button titleForNormalAndHighlightedState:(NSString *)title;

/**
 Apply the specifier attributes to the button the attributed title for
 disabled state.
 */
- (void)applyToButton:(UIButton *)button titleForDisabledState:(NSString *)title;
@end


@interface VSDashedBorderSpecifier : NSObject

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat paintedSegmentLength;
@property (nonatomic) CGFloat spacingSegmentLength;
@property (nonatomic) UIEdgeInsets insets;

@end
