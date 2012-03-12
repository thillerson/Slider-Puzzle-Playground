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
- (NSSet *) tilesAdjacentToTile:(GameTile *)tile;
- (CGRect) rectForRow:(NSInteger)row column:(NSInteger)column;
- (void) animateTileToEmptyTile:(GameTile *)tile;
- (void) makeMovesIfAnyExistForTile:(GameTile *)tile;
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

- (NSSet *) tilesAdjacentToTile:(GameTile *)tile {
    int row = tile.row;
    int col = tile.column;
    GameTile *foundTile = nil;
    NSMutableSet *set = [NSMutableSet set];
    foundTile = [self tileAtRow:row + 1 column:col];
    if (foundTile) [set addObject:foundTile];
    foundTile = [self tileAtRow:row column:col + 1];
    if (foundTile) [set addObject:foundTile];
    foundTile = [self tileAtRow:row + 1 column:col + 1];
    if (foundTile) [set addObject:foundTile];
    foundTile = [self tileAtRow:row - 1 column:col];
    if (foundTile) [set addObject:foundTile];
    foundTile = [self tileAtRow:row column:col - 1];
    if (foundTile) [set addObject:foundTile];
    foundTile = [self tileAtRow:row - 1 column:col - 1];
    if (foundTile) [set addObject:foundTile];
    foundTile = [self tileAtRow:row - 1 column:col + 1];
    if (foundTile) [set addObject:foundTile];
    foundTile = [self tileAtRow:row + 1 column:col - 1];
    if (foundTile) [set addObject:foundTile];
    return set;
}

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
    NSSet *adjacentTiles = [self tilesAdjacentToTile:tile];
    
    NSLog(@"Adjacent to empty tile %d", [adjacentTiles containsObject:self.emptyTile]);
    NSLog(@"tapped: %@, empty: %@", tile, self.emptyTile);
    if ([adjacentTiles containsObject:self.emptyTile] && (tile.row == self.emptyTile.row || tile.column == self.emptyTile.column)) {
        [self animateTileToEmptyTile:tile];
    }
}

#pragma mark - Positioning

- (void) animateTileToEmptyTile:(GameTile *)tile {
    __block GameTile *animatedTile = tile;
    CGRect tileRect = animatedTile.frame;
    self.emptyTile.frame = tileRect;
    __block CGRect emptyTileRect = [self rectForRow:self.emptyTile.row column:self.emptyTile.column];
    [animatedTile swapCoordinatesWith:self.emptyTile];
    NSLog(@"animatedTile: %@, empty: %@", animatedTile, self.emptyTile);
    [UIView animateWithDuration:kAnimationSpeed
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         animatedTile.frame = emptyTileRect;
                     }
                     completion:NULL];
}

- (CGRect) rectForRow:(NSInteger)row column:(NSInteger)column {
    return CGRectMake((column * kTileSize) + gameBoardX, (row * kTileSize) + gameBoardY, kTileSize, kTileSize);
}

#pragma mark - Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    __block UITouch *firstTouch = nil;
    [[event allTouches] enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
        if ([touch.view isKindOfClass:[GameTile class]]) {
            *stop = YES;
            firstTouch = touch;
        }
    }];
    if (firstTouch) {
        [self makeMovesIfAnyExistForTile:(GameTile *)firstTouch.view];
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
}

@end
