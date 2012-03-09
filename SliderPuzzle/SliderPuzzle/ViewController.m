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
- (void) renderTile:(GameTile *)tile;
@end

@implementation ViewController
@synthesize gameGrid;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    int w = kTileSize * 4;
    int h = kTileSize * 4;
    x = self.view.frame.size.width/2 - w/2;
    y = self.view.frame.size.height/2 - h/2;

    [self createGameGrid];
}

- (void) createGameGrid {
    self.gameGrid = [NSMutableArray arrayWithCapacity:4];
    for (int rowI = 0; rowI <= 3; rowI++) {
        for (int colI = 0; colI <= 3; colI++) {
            if (!(rowI == 3 && colI == 3)) [self addTileAtRow:rowI column:colI];
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
    tile.row = row;
    tile.column = column;
    [self renderTile:tile];
    [columnArray insertObject:tile atIndex:column];
}

- (void) renderTile:(GameTile *)tile {
    tile.frame = CGRectMake((tile.row * kTileSize) + x, (tile.column * kTileSize) + y, kTileSize, kTileSize);
    tile.backgroundColor = [UIColor blackColor];
    tile.layer.cornerRadius = 2;
    [self.view addSubview:tile];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.gameGrid = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
