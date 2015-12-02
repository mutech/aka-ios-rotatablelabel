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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.segmentedControl.selectedSegmentIndex = (lrint(self.rotatableLabel.rotationAngle/90) % 4);
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setRotationAngle:(id)sender {
    UISegmentedControl* sc = sender;
    [UIView animateWithDuration:.3 animations:^{
        switch (sc.selectedSegmentIndex)
        {
            case 0:
                self.rotatableLabel.rotationAngle = 0.0;
                break;
            case 1:
                self.rotatableLabel.rotationAngle = 90.0;
                break;
            case 2:
                self.rotatableLabel.rotationAngle = 180.0;
                break;
            case 3:
                self.rotatableLabel.rotationAngle = 270.0;
                break;
            default:
                break;
        }
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];
}

@end

