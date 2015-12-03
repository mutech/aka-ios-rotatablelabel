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

- (void)setupDefaultValues
{
    self.label = [self createLabel];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupDefaultValues];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        id angle = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(rotationAngle))];
        if ([angle isKindOfClass:[NSNumber class]])
        {
            self.rotationAngle = [angle doubleValue];
        }

        [self setupDefaultValues];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // Make sure label will not be encoded as subview, setter with nil will remove it.
    if (_label.superview == self)
    {
        [_label removeFromSuperview];
    }

    self.label = nil;

    [super encodeWithCoder:aCoder];

    if (self.rotationAngle != 0.0)
    {
        [aCoder encodeObject:@(self.rotationAngle) forKey:NSStringFromSelector(@selector(rotationAngle))];
    }

    if (_label)
    {
        [self addSubview:_label];
    }

#if 0
    if (label)
    {
        [aCoder encodeObject:label forKey:NSStringFromSelector(@selector(label))];
    }
#endif
}

- (void)prepareForInterfaceBuilder
{
    if (_label == nil)
    {
        self.label = [self createLabel];
        [self layoutIfNeeded];
    }
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
        //self.label = [self createLabel];
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
    label.text = self.text;
    label.attributedText = self.attributedText;
    label.font = self.font;
    label.textColor = self.textColor;
    label.textAlignment = self.textAlignment;
    label.lineBreakMode = self.lineBreakMode;
    label.enabled = self.enabled;
    label.allowsDefaultTighteningForTruncation = self.allowsDefaultTighteningForTruncation;
    label.baselineAdjustment = self.baselineAdjustment;
    label.minimumScaleFactor = self.minimumScaleFactor;
    label.numberOfLines = self.numberOfLines;
    label.adjustsFontSizeToFitWidth = self.adjustsFontSizeToFitWidth;
    label.minimumFontSize = self.minimumFontSize;

    label.highlightedTextColor = self.highlightedTextColor;
    label.highlighted = self.highlighted;
    label.preferredMaxLayoutWidth = self.preferredMaxLayoutWidth;

#if 1
    label.backgroundColor = self.backgroundColor ? self.backgroundColor : [UIColor clearColor];
    label.shadowColor = self.shadowColor;
    label.shadowOffset = self.shadowOffset;
    label.clipsToBounds = self.clipsToBounds;
#endif
}

#pragma mark - Disabling wrapper label text drawing

- (void)drawTextInRect:(CGRect)rect
{
    // Prevent the wrapper label to draw any text.
    return;
}

#pragma mark - Setter forwarding to rotated labels

- (void)setText:(NSString *)text
{
    super.text = text;
    self.label.text = text;

    // TODO: check this: I have no idea why, but setting the rotated label's text also resets it's font.
    self.label.font = self.font;

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

- (UIColor *)textColor
{
    UIColor* result = super.textColor;
    return result;
}

- (void)setTextColor:(UIColor *)textColor
{
    super.textColor = [UIColor clearColor];
    self.label.textColor = textColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    super.backgroundColor = backgroundColor;
    self.label.backgroundColor = backgroundColor ? backgroundColor : [UIColor clearColor];
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
    self.label.shadowColor = shadowColor;
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    super.shadowOffset = shadowOffset;
    self.label.shadowOffset = shadowOffset;
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
    self.label.clipsToBounds = clipsToBounds;
}

#pragma mark - Obsolete / Not working / Not needed

#if 0

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines { return [self.label textRectForBounds:bounds limitedToNumberOfLines:numberOfLines]; }


- (void)sizeToFit { [self.label sizeToFit]; }
- (CGSize)sizeThatFits:(CGSize)size { return [self.label sizeThatFits:size]; }

- (void)decreaseSize:(id)sender { [self.label decreaseSize:sender]; [self updateTransformation]; }
- (void)increaseSize:(id)sender { [self.label increaseSize:sender]; [self updateTransformation]; }

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize { return [self.label systemLayoutSizeFittingSize:targetSize]; }

#endif

@end

