//
//  ImageSlicer.h
//  SliderPuzzle
//
//  Created by Tony Hillerson on 3/14/12.
//  Copyright (c) 2012 Tack Mobile, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageSlicer : NSObject {
    CGContextRef sizedContext;
}

@property(nonatomic) CGImageRef unslicedImage;
@property(nonatomic) CGImageRef sizedImage;
@property(nonatomic) NSInteger rows;
@property(nonatomic) NSInteger columns;
@property(nonatomic) CGSize tileSize;
@property(strong, nonatomic) NSMutableSet *slices;
@property(strong, nonatomic) NSMutableArray *unservedSlices;

- (id) initWithUnslicedImage:(CGImageRef)image rows:(NSInteger)rows columns:(NSInteger)columns tileSize:(CGSize)size;
- (CGImageRef) serveRandomSlice;


@end
