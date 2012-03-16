//
//  ViewController.h
//  SliderPuzzle
//
//  Created by Tony Hillerson on 3/6/12.
//  Copyright (c) 2012 Tack Mobile, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class GameTile, ImageSlicer;

@interface ViewController : UIViewController {
    int gameBoardX,gameBoardY, emptyColumn, emptyRow;
    CGRect gameBoardBounds;
}

@property(strong, nonatomic) NSMutableSet *allTiles;
@property(strong, nonatomic) GameTile *emptyTile;
@property(strong, nonatomic) NSString *lastTouchCenter;
@property(nonatomic) BOOL lastTouchWasDrag;
@property(strong, nonatomic) GameTile *movedTile;
@property(strong, nonatomic) NSArray *tilesFromTileToEmptyTile;
@property(strong, nonatomic) ImageSlicer *imageSlicer;
@property(strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) IBOutlet UIButton *soundToggleButton;
@property(nonatomic) BOOL playSounds;

- (IBAction)soundToggleTapped:(id)sender;
@end
