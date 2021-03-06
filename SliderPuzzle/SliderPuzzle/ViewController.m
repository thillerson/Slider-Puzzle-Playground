//
//  ViewController.m
//  SliderPuzzle
//
//  Created by Tony Hillerson on 3/6/12.
//  Copyright (c) 2012 Tack Mobile, LLC. All rights reserved.
//

#import "ViewController.h"
#import "GameTile.h"
#import "ImageSlicer.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

#define kTileSize 68
#define kAnimationSpeed 0.04f

@interface ViewController (Private)
- (void) drawGameContainer;
- (void) createGameGrid;
- (void) addTileAtRow:(NSInteger)row column:(NSInteger)column;
- (GameTile *) tileAtRow:(NSInteger)row column:(NSInteger)column;
- (void) renderTile:(GameTile *)tile;
- (CGRect) rectForRow:(NSInteger)row column:(NSInteger)column;
- (void) animateTile:(GameTile *)tile toRow:(NSInteger)row andColumn:(NSInteger)column;
- (void) makeMovesIfAnyExistForTile:(GameTile *)tile;
- (void) animateTilesTowardsEmptyTileStartingAtTile:(GameTile *)tile;
- (UITouch *) firstTouchThatTouchesATileFromTouches:(NSSet *)touches withEvent:(UIEvent *)event;
- (GameTile *) tileForTouches:(NSSet *)touches withEvent:(UIEvent *)event;
- (BOOL) anotherVisibleTileCollidesWithTile:(GameTile *)tile;
- (NSArray *) tilesBetweenTileAndEmptyTile:(GameTile *)tile;
- (UITouch *) firstTouchThatTouchesTile:(GameTile *)tile fromTouches:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) playClick;
@end

@implementation ViewController
@synthesize emptyTile, allTiles, lastTouchCenter, movedTile, tilesFromTileToEmptyTile, imageSlicer, audioPlayer, playSounds, soundToggleButton, lastTouchWasDrag;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    int w = kTileSize * 4;
    int h = kTileSize * 4;
    gameBoardX = self.view.frame.size.width/2 - w/2;
    gameBoardY = self.view.frame.size.height/2 - h/2;
    gameBoardBounds = CGRectMake(gameBoardX, gameBoardY, w, h);
    [self drawGameContainer];
    emptyColumn = arc4random() % 4;
    emptyRow = arc4random() % 4;
    
    NSURL *clickURL = [[NSBundle mainBundle] URLForResource:@"click" withExtension:@"caff"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:clickURL error:NULL];
    self.playSounds = YES;

    // Using this we could also load an image from the photo library with some simple changes.
    UIImage *img = [UIImage imageNamed:@"globe.jpg"];
    self.imageSlicer = [[ImageSlicer alloc] initWithUnslicedImage:[img CGImage]
                                                             rows:4
                                                          columns:4
                                                         tileSize:CGSizeMake(kTileSize, kTileSize)];

    self.allTiles = [NSMutableSet setWithCapacity:16];
    [self createGameGrid];
}

- (void)viewDidUnload {
    [self setSoundToggleButton:nil];
    [super viewDidUnload];
    self.emptyTile = nil;
    self.allTiles = nil;
    self.lastTouchCenter = nil;
    self.movedTile = nil;
    self.tilesFromTileToEmptyTile = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) drawGameContainer {
    UIView *gameContainer = [[UIView alloc] initWithFrame:CGRectInset(gameBoardBounds, -8, -8)];
    gameContainer.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.6];
    gameContainer.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    gameContainer.layer.borderWidth = 8;
    gameContainer.layer.cornerRadius = 8;
    gameContainer.layer.shadowRadius = 4;
    gameContainer.layer.shadowColor = [[UIColor blackColor] CGColor];
    gameContainer.layer.shadowOffset = CGSizeMake(4, 4);
    gameContainer.layer.shadowOpacity = .6;
    [self.view addSubview:gameContainer];
}

- (void) playClick {
    if (self.playSounds) [self.audioPlayer play];
}

- (IBAction)soundToggleTapped:(id)sender {
    self.playSounds = !self.playSounds;
    NSString *imageName = (self.playSounds) ? @"sound_on.png" : @"sound_off.png";
    [self.soundToggleButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

#pragma mark - Grids and Tiles

- (void) createGameGrid {
    for (int rowI = 0; rowI <= 3; rowI++) { for (int colI = 0; colI <= 3; colI++) { [self addTileAtRow:rowI column:colI]; } }
}

- (void) addTileAtRow:(NSInteger)row column:(NSInteger)column {
    GameTile *tile = [GameTile new];
    tile.tileImage = [self.imageSlicer serveRandomSlice];
    [self.allTiles addObject:tile];
    tile.row = row;
    tile.column = column;
    [self renderTile:tile];
}

- (void) renderTile:(GameTile *)tile {
    tile.frame = [self rectForRow:tile.row column:tile.column];
    if (tile.row == emptyRow && tile.column == emptyColumn) {
        self.emptyTile = tile;
        tile.isEmptyTile = YES;
    }
    [self.view addSubview:tile];
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

- (NSArray *) tilesBetweenTileAndEmptyTile:(GameTile *)tile {
    GameTile *foundTile = nil;
    NSMutableArray *tiles = [NSMutableArray array];
    int i;
    if (self.emptyTile.row == tile.row) {
        if (self.emptyTile.column < tile.column) {
            for (i = self.emptyTile.column + 1; i < tile.column + 1; i++) {
                foundTile = [self tileAtRow:tile.row column:i];
                [tiles addObject:foundTile];
            }
        } else {
            for (i = self.emptyTile.column - 1; i > tile.column - 1; i--) {
                foundTile = [self tileAtRow:tile.row column:i];
                [tiles addObject:foundTile];
            }
        }
    } else if (self.emptyTile.column == tile.column) {
        if (self.emptyTile.row < tile.row) {
            for (i = self.emptyTile.row + 1; i < tile.row + 1; i++) {
                foundTile = [self tileAtRow:i column:tile.column];
                [tiles addObject:foundTile];
            }
        } else {
            for (i = self.emptyTile.row - 1; i > tile.row - 1; i--) {
                foundTile = [self tileAtRow:i column:tile.column];
                [tiles addObject:foundTile];
            }
        }
    }
    return [tiles count] > 0 ? tiles : nil;
}


- (BOOL) anotherVisibleTileCollidesWithTile:(GameTile *)tile {
    __block BOOL collision = NO;
    [self.allTiles enumerateObjectsUsingBlock:^(GameTile *otherTile, BOOL *stop) {
        CGRect tileFrame = tile.frame;
        if (!otherTile.isEmptyTile && otherTile != tile && CGRectIntersectsRect(tileFrame, otherTile.frame)) {
            NSLog(@"Intersects with tile: %@", otherTile);
            *stop = YES;
            collision = YES;
        }
    }];
    return collision;
}

#pragma mark - Positioning

- (void) makeMovesIfAnyExistForTile:(GameTile *)tile {
    if (tile.row == self.emptyTile.row || tile.column == self.emptyTile.column) {
        if (!self.lastTouchWasDrag || [tile hasTraveledOverHalfOfOwnSize]) {
            NSLog(@"moved: %@, empty: %@, delta: %@", tile, self.emptyTile, NSStringFromCGPoint(tile.moveDelta));
            [self animateTilesTowardsEmptyTileStartingAtTile:tile];
        } else {
            NSLog(@"Resetting tiles");
            [self.tilesFromTileToEmptyTile enumerateObjectsUsingBlock:^(GameTile *t, NSUInteger idx, BOOL *stop) {
                [self animateTile:t toRow:t.row andColumn:t.column];
            }];
        }
    }
}

- (void) animateTilesTowardsEmptyTileStartingAtTile:(GameTile *)tile {
    if (tile == self.emptyTile) return;
    
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
    self.emptyTile.frame = [self rectForRow:row column:column];
}

- (void) animateTile:(GameTile *)tile toRow:(NSInteger)row andColumn:(NSInteger)column {
    NSLog(@"Animating tile %@ to row: %d, column: %d", tile, row, column);
    __block GameTile *animatedTile = tile;
    __block CGRect targetRect = [self rectForRow:row column:column];
    [UIView animateWithDuration:kAnimationSpeed
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         animatedTile.frame = targetRect;
                     }
                     completion:^(BOOL finished) {
                         NSLog(@"Animation Finished at row: %d, column: %d", row, column);
                         animatedTile.row = row;
                         animatedTile.column = column;
                         animatedTile.moveDelta = CGPointZero;
                         [self playClick];
                     }];
}

- (CGRect) rectForRow:(NSInteger)row column:(NSInteger)column {
    return CGRectMake((column * kTileSize) + gameBoardX, (row * kTileSize) + gameBoardY, kTileSize, kTileSize);
}

#pragma mark - Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.movedTile == nil) {
        UITouch *firstTouch = [self firstTouchThatTouchesATileFromTouches:touches withEvent:event];
        self.movedTile = (GameTile *)firstTouch.view;
        self.tilesFromTileToEmptyTile = [self tilesBetweenTileAndEmptyTile:movedTile];
        if (tilesFromTileToEmptyTile) {
            CGPoint touchCenter = [firstTouch locationInView:self.view];
            self.lastTouchCenter = NSStringFromCGPoint(touchCenter);
        }
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.movedTile) {
        self.lastTouchWasDrag = YES;
        UITouch *firstTouch = [self firstTouchThatTouchesTile:self.movedTile fromTouches:touches withEvent:event];
        if (firstTouch) {
            CGPoint touchCenter = [firstTouch locationInView:self.view];
            CGPoint lastCenter = CGPointFromString(self.lastTouchCenter);
            int xDelta = touchCenter.x - lastCenter.x;
            int yDelta = touchCenter.y - lastCenter.y;
            
            [self.tilesFromTileToEmptyTile enumerateObjectsUsingBlock:^(GameTile *tile, NSUInteger idx, BOOL *stop) {
                CGPoint oldTileCenter = tile.center;
                CGPoint newCenter = CGPointMake(oldTileCenter.x, oldTileCenter.y);
                CGPoint currentDelta = tile.moveDelta;
                int tileXDelta = currentDelta.x;
                int tileYDelta = currentDelta.y;
                
                if (tile.row == self.emptyTile.row) {
                    newCenter.x = newCenter.x + xDelta;
                    tileXDelta = tileXDelta + xDelta;
                } else if (tile.column == self.emptyTile.column) {
                    newCenter.y = newCenter.y + yDelta;
                    tileYDelta = tileYDelta + yDelta;
                }
                
                // Lazy perhaps...
                tile.center = newCenter;
                tile.moveDelta = CGPointMake(tileXDelta, tileYDelta);
                BOOL impossibleMove = !CGRectContainsRect(gameBoardBounds, tile.frame) || [self anotherVisibleTileCollidesWithTile:tile];
                if (impossibleMove) {
                    tile.center = oldTileCenter;
                    tile.moveDelta = currentDelta;
                }
            }];
            
            self.lastTouchCenter = NSStringFromCGPoint(touchCenter);
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self makeMovesIfAnyExistForTile:[self tileForTouches:touches withEvent:event]];
    self.lastTouchWasDrag = NO;
    self.lastTouchCenter = nil;
    self.movedTile = nil;
    self.tilesFromTileToEmptyTile = nil;
}

- (UITouch *) firstTouchThatTouchesTile:(GameTile *)tile fromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    __block UITouch *firstTouch = nil;
    [[event allTouches] enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
        if (touch.view == tile) {
            *stop = YES;
            firstTouch = touch;
        }
    }];
    return firstTouch;
}

- (UITouch *) firstTouchThatTouchesATileFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    __block UITouch *firstTouch = nil;
    [[event allTouches] enumerateObjectsUsingBlock:^(UITouch *touch, BOOL *stop) {
        if ([touch.view isKindOfClass:[GameTile class]]) {
            *stop = YES;
            firstTouch = touch;
        }
    }];
    return firstTouch;
}

- (GameTile *) tileForTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *firstTouch = [self firstTouchThatTouchesATileFromTouches:touches withEvent:event];
    GameTile *tile = (GameTile *)firstTouch.view;
    return tile;
}

@end
