//
//  ViewController.h
//  SliderPuzzle
//
//  Created by Tony Hillerson on 3/6/12.
//  Copyright (c) 2012 Tack Mobile, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property(strong, nonatomic) UIView *draggable;
@property (strong, nonatomic) IBOutlet UISwitch *xLock;
@property (strong, nonatomic) IBOutlet UISwitch *yLock;

@end
