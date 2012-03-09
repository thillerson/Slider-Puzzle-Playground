//
//  GameTile.m
//  SliderPuzzle
//
//  Created by Tony Hillerson on 3/8/12.
//  Copyright (c) 2012 Tack Mobile, LLC. All rights reserved.
//

#import "GameTile.h"

@implementation GameTile
@synthesize row, column, isEmptyTile;

- (void) highlight {
    if (!isEmptyTile) self.backgroundColor = [UIColor redColor];
}

- (void) normal {
    if (!isEmptyTile) self.backgroundColor = [UIColor blackColor];
}

@end
