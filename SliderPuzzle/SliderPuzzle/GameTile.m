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
    self.backgroundColor = [UIColor redColor];
}

- (void) normal {
    self.backgroundColor = (isEmptyTile) ? [UIColor clearColor] : [UIColor blackColor];
}

- (void) swapCoordinatesWith:(GameTile *)anotherTile {
    int anotherRow = anotherTile.row;
    int anotherColumn = anotherTile.column;
    anotherTile.row = self.row;
    anotherTile.column = self.column;
    self.row = anotherRow;
    self.column = anotherColumn;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"<GameTile row:%d column:%d empty? %d>", self.row, self.column, self.isEmptyTile];
}

@end
