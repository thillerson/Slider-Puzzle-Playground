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

@interface ViewController (Private)
- (void) createGameGrid;
- (void) addTileAtRow:(NSInteger)row column:(NSInteger)column;
- (GameTile *) tileAtRow:(NSInteger)row column:(NSInteger)column;
- (void) renderTile:(GameTile *)tile;
- (NSSet *) tilesAdjacentToTile:(GameTile *)tile;
@end

@implementation ViewController
@synthesize gameGrid, targetTile, emptyTile, allTiles;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    int w = kTileSize * 4;
    int h = kTileSize * 4;
    x = self.view.frame.size.width/2 - w/2;
    y = self.view.frame.size.height/2 - h/2;

    self.allTiles = [NSMutableArray arrayWithCapacity:16];
    [self createGameGrid];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.gameGrid = nil;
    self.targetTile = nil;
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
    GameTile *tile = nil;
    if (row > -1 && column > -1 && row < 4 && column < 4) {
        NSMutableArray *columnArray = [self.gameGrid objectAtIndex:row];
        tile = [columnArray objectAtIndex:column];
        if (tile == self.emptyTile) {
            return nil;
        }
    }
    return tile;
}

- (void) createGameGrid {
    self.gameGrid = [NSMutableArray arrayWithCapacity:4];
    for (int rowI = 0; rowI <= 3; rowI++) {
        for (int colI = 0; colI <= 3; colI++) {
            [self addTileAtRow:rowI column:colI];
        }
    }
}

- (void) addTileAtRow:(NSInteger)row column:(NSInteger)column {
    NSLog(@"Creating Game Tile at [%d %d]", row, column);
    NSMutableArray *columnArray = nil;
    if ([self.gameGrid count] ==  row) {
        columnArray = [NSMutableArray arrayWithCapacity:4];
        [self.gameGrid insertObject:columnArray atIndex:row];
    } else {
        columnArray = [self.gameGrid objectAtIndex:row];
    }
    GameTile *tile = [GameTile new];
    [self.allTiles addObject:tile];
    tile.row = row;
    tile.column = column;
    [self renderTile:tile];
    [columnArray insertObject:tile atIndex:column];
}

- (void) renderTile:(GameTile *)tile {
    tile.frame = CGRectMake((tile.row * kTileSize) + x, (tile.column * kTileSize) + y, kTileSize, kTileSize);
    if (tile.row == 3 && tile.column == 3) {
        self.emptyTile = tile;
        tile.isEmptyTile = YES;
    } else {
        tile.backgroundColor = [UIColor blackColor];
        tile.layer.cornerRadius = 2;
        [self.view addSubview:tile];
    }
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
        self.targetTile = (GameTile *)firstTouch.view;
        NSSet *adjacentTiles = [self tilesAdjacentToTile:self.targetTile];
        [adjacentTiles makeObjectsPerformSelector:@selector(highlight)];
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.allTiles makeObjectsPerformSelector:@selector(normal)];
}

@end
