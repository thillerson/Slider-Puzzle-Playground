//
//  GameTile.m
//  SliderPuzzle
//
//  Created by Tony Hillerson on 3/8/12.
//  Copyright (c) 2012 Tack Mobile, LLC. All rights reserved.
//

#import "GameTile.h"

@implementation GameTile
@synthesize row, column, isEmptyTile, tileImage, moveDelta;

- (void) setIsEmptyTile:(BOOL)empty {
    isEmptyTile = empty;
    self.backgroundColor = [UIColor clearColor];
    [self setNeedsDisplay];
}

- (BOOL) hasTraveledOverHalfOfOwnSize {
    int xDelta = self.moveDelta.x;
    int yDelta = self.moveDelta.y;
    NSLog(@"xDelta %d, yDelta %d", xDelta, yDelta);
    return ((abs(xDelta) >= self.frame.size.width/2) || (abs(yDelta) >= self.frame.size.height/2));
}

- (void) drawRect:(CGRect)rect {
    if (self.isEmptyTile) {
        [super drawRect:rect];
    } else {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, self.bounds, self.tileImage);
    }
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
