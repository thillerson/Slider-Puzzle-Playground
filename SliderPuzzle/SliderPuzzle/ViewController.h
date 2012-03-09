//
//  ViewController.h
//  SliderPuzzle
//
//  Created by Tony Hillerson on 3/6/12.
//  Copyright (c) 2012 Tack Mobile, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController {
    int x,y;
}

@property(strong, nonatomic) NSMutableArray *gameGrid;

@end
