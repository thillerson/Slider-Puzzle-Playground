//
//  GameTile.h
//  SliderPuzzle
//
//  Created by Tony Hillerson on 3/8/12.
//  Copyright (c) 2012 Tack Mobile, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameTile : UIView

@property(nonatomic) NSInteger row;
@property(nonatomic) NSInteger column;
@property(nonatomic) BOOL isEmptyTile;
@property(nonatomic) CGImageRef tileImage;
@property(nonatomic) CGPoint moveDelta;

- (NSInteger) distanceInRowOrColumnFromTileToAnotherTile:(GameTile *)anotherTile;
- (BOOL) hasTraveledOverHalfOfOwnSize;

@end
