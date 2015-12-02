//
//  AKARotatableLabel.m
//  AKARotatableLabelFramework
//
//  Created by Michael Utech on 02.12.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "AKARotatableLabel.h"


#import <tgmath.h>

#import "AKARotatableLabel.h"

typedef NS_ENUM(NSUInteger, AKADirection) {
    DirectionEast = 0,
    DirectionNorth = 1,
    DirectionWest = 2,
    DirectionSouth = 3
};

@interface AKARotatableLabel ()

@property(nonatomic) IBOutlet UILabel* label;

@property(nonatomic, readonly) AKADirection direction;

@end

@implementation AKARotatableLabel

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        id angle = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(rotationAngle))];
        if ([angle isKindOfClass:[NSNumber class]])
        {
            self.rotationAngle = [angle doubleValue];
        }

#if 0
        // Since we are (now) storing all properties in both this instance and the label,
        // we don't need to serialize it anymore, which saves some complications.
        id label = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(label))];
        if ([label isKindOfClass:[UILabel class]])
        {
            self.label = label;
        }
#endif
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // Make sure label will not be encoded as subview, setter with nil will remove it.
    UILabel* label = self.label;
    self.label = nil;

    [super encodeWithCoder:aCoder];

    if (self.rotationAngle != 0.0)
    {
        [aCoder encodeObject:@(self.rotationAngle) forKey:NSStringFromSelector(@selector(rotationAngle))];
    }

    self.label = label;

#if 0
    if (label)
    {
        [aCoder encodeObject:label forKey:NSStringFromSelector(@selector(label))];
    }
#endif
}

#pragma mark - Properties

- (void)setRotationAngle:(CGFloat)rotationAngle
{
    if (_rotationAngle != rotationAngle)
    {
        _rotationAngle = rotationAngle;
        // Round to multiple of 90º and normalize (self.direction does this):
        _rotationAngle = self.direction * 90.0;

        [self updateTransformation];
    }
}

- (AKADirection)direction
{
    CGFloat nineties = self.rotationAngle / 90.0;
    NSInteger result = (lrint(nineties) % 4);
    if (result < 0)
    {
        result = 4 - result;
    }
    NSAssert(result >= DirectionEast && result <= DirectionSouth, @"Bug, please check computation of property direction in in AKARotateView");

    return (AKADirection)result;
}

@synthesize label = _label;
- (UILabel *)label
{
    if (_label == nil)
    {
        // Create on first use, createLabel will initialize it using property
        // values from self (super).
        self.label = [self createLabel];
    }
    return _label;
}

- (void)setLabel:(UILabel *)label
{
    if (label != _label)
    {
        // If there is already a label set up, discard it and remove it from subviews
        if (_label)
        {
            if (label.superview == self)
            {
                [label removeFromSuperview];
            }
            _label = nil;
        }

        // Label will not be set up when assigned to setter, this is done in createLabel.
        // We assume you have a reason to call it directly and don't override its settings.
        _label = label;

        if (_label)
        {
            //self.label.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:_label];
            [_label sizeToFit];
        }
        [self updateTransformation];
    }
}

- (CGSize)intrinsicContentSize
{
    CGSize result = [super intrinsicContentSize];
    [self.label sizeToFit];

    // TODO: This is one of the weak spots of this implementation. Documentation warns not to use
    // frame of transformed views. We might compute that manually later
    result = self.label.frame.size;

    return result;
}

#pragma mark - Rotation and translation

- (void)updateTransformation
{
    self.label.transform = CGAffineTransformIdentity;
    [self.label sizeToFit];
    CGSize labelSize = self.label.frame.size;

    CGAffineTransform rotation = CGAffineTransformMakeRotation((self.rotationAngle / 360.0) *
                                                               (2 * M_PI));

    switch (self.direction)
    {
        case DirectionNorth:
            self.label.transform = CGAffineTransformTranslate(rotation,
                                                              labelSize.width/2 - labelSize.height/2,
                                                              labelSize.width/2 - labelSize.height/2);
            break;

        case DirectionEast:
            break;

        case DirectionWest:
            self.label.transform = rotation;
            break;

        case DirectionSouth:
            self.label.transform = CGAffineTransformTranslate(rotation,
                                                              -(labelSize.width/2 - labelSize.height/2),
                                                              -(labelSize.width/2 - labelSize.height/2));
            break;
    }
    [self invalidateIntrinsicContentSize];
    [self setNeedsLayout];
}

#pragma mark - Creating and initializing rotated labels

- (UILabel*)createLabel
{
    UILabel* label = [[UILabel alloc] initWithFrame:self.bounds];

    [self setupLabelWithValuesFromSuper:label];

    return label;
}

- (void)setupLabelWithValuesFromSuper:(UILabel*)label
{
    label.text = super.text;
    label.attributedText = super.attributedText;
    label.font = super.font;
    label.textColor = super.textColor;
    label.textAlignment = super.textAlignment;
    label.lineBreakMode = super.lineBreakMode;
    label.enabled = super.enabled;
    label.allowsDefaultTighteningForTruncation = super.allowsDefaultTighteningForTruncation;
    label.baselineAdjustment = super.baselineAdjustment;
    label.minimumScaleFactor = super.minimumScaleFactor;
    label.numberOfLines = super.numberOfLines;
    label.adjustsFontSizeToFitWidth = super.adjustsFontSizeToFitWidth;
    label.minimumFontSize = super.minimumFontSize;

    label.highlightedTextColor = super.highlightedTextColor;
    label.highlighted = super.highlighted;
    label.preferredMaxLayoutWidth = super.preferredMaxLayoutWidth;

#if 1
    label.backgroundColor = super.backgroundColor;
    label.shadowColor = super.shadowColor;
    label.shadowOffset = super.shadowOffset;
    label.clipsToBounds = super.clipsToBounds;
#endif
}

#pragma mark - Setter forwarding to rotated labels

- (void)setText:(NSString *)text
{
    super.text = text;
    self.label.text = text;
    [self updateTransformation];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    super.attributedText = attributedText;
    self.label.attributedText = attributedText;
    [self updateTransformation];
}

- (void)setFont:(UIFont *)font
{
    super.font = font;
    self.label.font = font;
    [self updateTransformation];
}

- (void)setTextColor:(UIColor *)textColor
{
    super.textColor = textColor;
    self.label.textColor = textColor;
    [self updateTransformation];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    super.backgroundColor = backgroundColor;
    //self.label.backgroundColor = backgroundColor;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    super.textAlignment = textAlignment;
    self.label.textAlignment = textAlignment;
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
    super.lineBreakMode = lineBreakMode;
    self.label.lineBreakMode = lineBreakMode; [self updateTransformation];
}

- (void)setEnabled:(BOOL)enabled
{
    super.enabled = enabled;
    self.label.enabled = enabled;
}

- (void)setAllowsDefaultTighteningForTruncation:(BOOL)allowsDefaultTighteningForTruncation
{
    super.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation;
    self.label.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation;
    [self updateTransformation];
}

- (void)setBaselineAdjustment:(UIBaselineAdjustment)baselineAdjustment
{
    super.baselineAdjustment = baselineAdjustment;
    self.label.baselineAdjustment = baselineAdjustment;
    [self updateTransformation];
}

- (void)setMinimumScaleFactor:(CGFloat)minimumScaleFactor
{
    super.minimumScaleFactor = minimumScaleFactor;
    self.label.minimumScaleFactor = minimumScaleFactor;
    [self updateTransformation];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines
{
    super.numberOfLines = numberOfLines;
    self.label.numberOfLines = numberOfLines;
    [self updateTransformation];
}

- (void)setAdjustsFontSizeToFitWidth:(BOOL)adjustsFontSizeToFitWidth
{
    super.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth;
    self.label.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth;
    [self updateTransformation];
}

- (void)setMinimumFontSize:(CGFloat)minimumFontSize
{
    super.minimumFontSize = minimumFontSize;
    self.label.minimumFontSize = minimumFontSize;
    [self updateTransformation];
}

- (void)setHighlightedTextColor:(UIColor *)highlightedTextColor
{
    super.highlightedTextColor = highlightedTextColor;
    self.label.highlightedTextColor = highlightedTextColor;
}

- (void)setHighlighted:(BOOL)highlighted
{
    super.highlighted = highlighted;
    self.label.highlighted = highlighted;
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    super.shadowColor = shadowColor;
    //self.label.shadowColor = shadowColor;
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    super.shadowOffset = shadowOffset;
    //self.label.shadowOffset = shadowOffset;
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth
{
    super.preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    self.label.preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    [self updateTransformation];
}


- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    super.userInteractionEnabled = userInteractionEnabled;
    self.label.userInteractionEnabled = userInteractionEnabled;
}

- (void)setClipsToBounds:(BOOL)clipsToBounds
{
    super.clipsToBounds = clipsToBounds;
    //self.label.clipsToBounds = clipsToBounds;
}

#pragma mark - Obsolete / Not working

#if 0

- (NSString *)text { return _label ? nil : super.text; }
- (NSAttributedString *)attributedText { return _label ? nil : super.attributedText; }
- (UIFont *)font { return _label ? _label.font : super.font; }
- (UIColor *)textColor { return _label ? _label.textColor : super.textColor; }

- (UIColor *)backgroundColor { return _label ? _label.backgroundColor : super.backgroundColor; }

#endif

#if 0

- (NSTextAlignment)textAlignment { return self.label.textAlignment; }
- (NSLineBreakMode)lineBreakMode { return self.label.lineBreakMode; }
- (BOOL)isEnabled { return self.label.enabled; }
- (BOOL)allowsDefaultTighteningForTruncation { return self.label.allowsDefaultTighteningForTruncation; }
- (UIBaselineAdjustment)baselineAdjustment { return self.label.baselineAdjustment; }
- (CGFloat)minimumScaleFactor { return self.label.minimumScaleFactor; }
- (NSInteger)numberOfLines { return self.label.numberOfLines; }
- (BOOL)adjustsFontSizeToFitWidth { return self.label.adjustsFontSizeToFitWidth; }
- (CGFloat)minimumFontSize { return self.label.minimumFontSize; }

#endif

#if 0

- (UIColor *)highlightedTextColor { return self.label.highlightedTextColor; }
- (BOOL)isHighlighted { return self.label.highlighted; }
- (UIColor *)shadowColor { return self.label.shadowColor; }
- (CGSize)shadowOffset { return self.label.shadowOffset; }
- (CGFloat)preferredMaxLayoutWidth { return self.label.preferredMaxLayoutWidth; }
- (BOOL)isUserInteractionEnabled { return self.label.userInteractionEnabled; }
- (BOOL)clipsToBounds { return self.label.clipsToBounds; }

#endif

#if 0

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines { return [self.label textRectForBounds:bounds limitedToNumberOfLines:numberOfLines]; }

- (void)drawTextInRect:(CGRect)rect { [self.label drawTextInRect:rect]; }

- (void)sizeToFit { [self.label sizeToFit]; }
- (CGSize)sizeThatFits:(CGSize)size { return [self.label sizeThatFits:size]; }

- (void)decreaseSize:(id)sender { [self.label decreaseSize:sender]; [self updateTransformation]; }
- (void)increaseSize:(id)sender { [self.label increaseSize:sender]; [self updateTransformation]; }

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize { return [self.label systemLayoutSizeFittingSize:targetSize]; }

#endif

@end
