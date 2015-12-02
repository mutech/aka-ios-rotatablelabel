//
//  AKARotatableLabel.h
//  AKARotatableLabelFramework
//
//  Created by Michael Utech on 02.12.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

@import UIKit;

IB_DESIGNABLE
/**
 * Imperfect but usable implementation of a label that can display text at rotation angles
 * of 0º, 90º, 180º and 270º.
 *
 * See project README.md for more details
 */
@interface AKARotatableLabel : UILabel

/**
 * Rotation angle in range [0.0 .. 360.0]. Please note that angles are
 * rounded to the closest multiple of 90º.
 */
@property(nonatomic) IBInspectable CGFloat rotationAngle;

@end
