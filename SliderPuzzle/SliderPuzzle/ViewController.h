//
//  ViewController.h
//  SliderPuzzle
//
//  Created by Tony Hillerson on 3/6/12.
//  Copyright (c) 2012 Tack Mobile, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameTile;

@interface ViewController : UIViewController {
    int gameBoardX,gameBoardY;
    CGRect gameBoardBounds;
}

@property(strong, nonatomic) NSMutableSet *allTiles;
@property(strong, nonatomic) GameTile *emptyTile;
@property(strong, nonatomic) NSString *lastTouchCenter;
@property(strong, nonatomic) GameTile *movedTile;
@property(strong, nonatomic) NSArray *tilesFromTileToEmptyTile;

@end
