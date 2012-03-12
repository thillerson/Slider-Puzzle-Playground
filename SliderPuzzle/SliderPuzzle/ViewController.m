//
//  ViewController.m
//  SliderPuzzle
//
//  Created by Tony Hillerson on 3/6/12.
//  Copyright (c) 2012 Tack Mobile, LLC. All rights reserved.
//

#import "ViewController.h"
#import "GameTile.h"
#import <QuartzCore/QuartzCore.h>

#define kTileSize 68
#define kAnimationSpeed 0.04f

@interface ViewController (Private)
- (void) createGameGrid;
- (void) addTileAtRow:(NSInteger)row column:(NSInteger)column;
- (GameTile *) tileAtRow:(NSInteger)row column:(NSInteger)column;
- (void) renderTile:(GameTile *)tile;
- (CGRect) rectForRow:(NSInteger)row column:(NSInteger)column;
- (void) animateTile:(GameTile *)tile toRow:(NSInteger)row andColumn:(NSInteger)column;
- (void) makeMovesIfAnyExistForTile:(GameTile *)tile;
- (void) moveTilesTowardsEmptyTileStartingAtTile:(GameTile *)tile;
- (GameTile *) tileForTouches:(NSSet *)touches withEvent:(UIEvent *)event;
@end

@implementation ViewController
@synthesize emptyTile, allTiles;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    int w = kTileSize * 4;
    int h = kTileSize * 4;
    gameBoardX = self.view.frame.size.width/2 - w/2;
    gameBoardY = self.view.frame.size.height/2 - h/2;

    self.allTiles = [NSMutableSet setWithCapacity:16];
    [self createGameGrid];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.emptyTile = nil;
    self.allTiles = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Grids and Tiles

- (GameTile *) tileAtRow:(NSInteger)row column:(NSInteger)column {
    __block GameTile *tile = nil;
    [self.allTiles enumerateObjectsUsingBlock:^(GameTile *candidate, BOOL *stop) {
        if (candidate.row == row && candidate.column == column) {
            tile = candidate;
            *stop = YES;
        }
    }];
    return tile;
}

- (void) createGameGrid {
    for (int rowI = 0; rowI <= 3; rowI++) {
        for (int colI = 0; colI <= 3; colI++) {
            [self addTileAtRow:rowI column:colI];
        }
    }
}

- (void) addTileAtRow:(NSInteger)row column:(NSInteger)column {
    GameTile *tile = [GameTile new];
    [self.allTiles addObject:tile];
    tile.row = row;
    tile.column = column;
    [self renderTile:tile];
}

- (void) renderTile:(GameTile *)tile {
    tile.frame = [self rectForRow:tile.row column:tile.column];
    if (tile.row == 3 && tile.column == 3) {
        self.emptyTile = tile;
        tile.isEmptyTile = YES;
        tile.backgroundColor = [UIColor clearColor];
    } else {
        tile.backgroundColor = [UIColor blackColor];
        tile.layer.cornerRadius = 2;
    }
    [self.view addSubview:tile];
}

- (void) makeMovesIfAnyExistForTile:(GameTile *)tile {
    if (tile.row == self.emptyTile.row || tile.column == self.emptyTile.column) {
        NSLog(@"tapped: %@, empty: %@", tile, self.emptyTile);
        [self moveTilesTowardsEmptyTileStartingAtTile:tile];
    }
}

- (void) moveTilesTowardsEmptyTileStartingAtTile:(GameTile *)tile {
    if (tile == self.emptyTile) return;

    CGRect tileRect = tile.frame;
    self.emptyTile.frame = tileRect;
    int row = tile.row;
    int column = tile.column;
    
    int i;
    GameTile *tileToMove = nil;
    // Bring In The Brute Force!
    if (self.emptyTile.row == tile.row) {
        if (self.emptyTile.column < tile.column) {
            for (i = self.emptyTile.column + 1; i < tile.column + 1; i++) {
                tileToMove = [self tileAtRow:tile.row column:i];
                [self animateTile:tileToMove toRow:tile.row andColumn:i - 1];
            }
        } else {
            for (i = self.emptyTile.column - 1; i > tile.column - 1; i--) {
                tileToMove = [self tileAtRow:tile.row column:i];
                [self animateTile:tileToMove toRow:tile.row andColumn:i + 1];
            }
        }
    } else if (self.emptyTile.column == tile.column) {
        if (self.emptyTile.row < tile.row) {
            for (i = self.emptyTile.row + 1; i < tile.row + 1; i++) {
                tileToMove = [self tileAtRow:i column:tile.column];
                [self animateTile:tileToMove toRow:i - 1 andColumn:tile.column];
            }
        } else {
            for (i = self.emptyTile.row - 1; i > tile.row - 1; i--) {
                tileToMove = [self tileAtRow:i column:tile.column];
                [self animateTile:tileToMove toRow:i + 1 andColumn:tile.column];
            }
        }
    }
    
    self.emptyTile.row = row;
    self.emptyTile.column = column;
}

#pragma mark - Positioning

- (void) animateTile:(GameTile *)tile toRow:(NSInteger)row andColumn:(NSInteger)column {
    NSLog(@"Animating tile %@ to %d,%d", tile, row, column);
    __block GameTile *animatedTile = tile;
    __block CGRect targetRect = [self rectForRow:row column:column];
    [UIView animateWithDuration:kAnimationSpeed
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         animatedTile.frame = targetRect;
                     }
                     completion:^(BOOL finished) {
                         NSLog(@"Animation Finished");
                         animatedTile.row = row;
                         animatedTile.column = column;
                     }];
    }

- (CGRect) rectForRow:(NSInteger)row column:(NSInteger)column {
    return CGRectMake((column * kTileSize) + gameBoardX, (row * kTileSize) + gameBoardY, kTileSize, kTileSize);
}

#pragma mark - Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self makeMovesIfAnyExistForTile:[self tileForTouches:touches withEvent:event]];
}

- (GameTile *) tileForTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    __block UITouch *firstTouch = nil;
    [[event allTouches] enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
        if ([touch.view isKindOfClass:[GameTile class]]) {
            *stop = YES;
            firstTouch = touch;
        }
    }];
    if (firstTouch) {
        return (GameTile *)firstTouch.view;
    }
    return nil;
}

@end
