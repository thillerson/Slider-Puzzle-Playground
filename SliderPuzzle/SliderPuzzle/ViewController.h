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
}

@property(strong, nonatomic) NSMutableArray *gameGrid;
@property(strong, nonatomic) NSMutableSet *allTiles;
@property(strong, nonatomic) GameTile *emptyTile;
@property(strong, nonatomic) GameTile *targetTile;

@end
