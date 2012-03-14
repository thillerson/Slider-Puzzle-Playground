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

- (NSInteger) distanceInRowOrColumnFromTileToAnotherTile:(GameTile *)anotherTile {
    if (self.row == anotherTile.row) {
        return self.column - anotherTile.column;
    } else if (self.column == anotherTile.column) {
        return self.row - anotherTile.row;
    }
    return NAN;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"<GameTile row:%d column:%d empty? %d>", self.row, self.column, self.isEmptyTile];
}

@end
