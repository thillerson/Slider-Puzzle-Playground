//
//  ViewController.m
//  SliderPuzzle
//
//  Created by Tony Hillerson on 3/6/12.
//  Copyright (c) 2012 Tack Mobile, LLC. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize draggable;
@synthesize xLock;
@synthesize yLock;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.draggable = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.draggable.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.draggable];
    self.draggable.center = self.view.center;
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = (UITouch *)[[touches objectsPassingTest:^BOOL(UITouch *candidate, BOOL *stop) {
        if (candidate.view == self.draggable) {
            BOOL finish = YES;
            stop = &finish;
            return YES;
        }
        return NO;
    }] anyObject];
    CGPoint newLocation = self.draggable.center;
    if (![self.xLock isOn]) {
        newLocation.y = [touch locationInView:self.view].y;
    }
    if (![self.yLock isOn]) {
        newLocation.x = [touch locationInView:self.view].x;
    }
    if (touch) self.draggable.center = newLocation;
}

- (void)viewDidUnload {
    [self setXLock:nil];
    [self setYLock:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
