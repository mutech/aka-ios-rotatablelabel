//
//  ViewController.m
//  AKARotatableLabelDemo
//
//  Created by Michael Utech on 02.12.15.
//  Copyright © 2015 AKA Sarl. All rights reserved.
//

#import "ViewController.h"
#import "AKARotatableLabel.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet AKARotatableLabel *rotatableLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
- (IBAction)setRotationAngle:(id)sender;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.segmentedControl.selectedSegmentIndex = (lrint(self.rotatableLabel.rotationAngle/90) % 4);
}

- (IBAction)setRotationAngle:(id)sender
{
    [UIView animateWithDuration:.3 animations:
     ^{
         self.rotatableLabel.rotationAngle =
            90.0 * ((UISegmentedControl*)sender).selectedSegmentIndex;

         [self.view setNeedsLayout];
         [self.view layoutIfNeeded];
     }];
}

@end

