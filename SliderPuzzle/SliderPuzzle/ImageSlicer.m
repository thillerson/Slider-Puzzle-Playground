//
//  ImageSlicer.m
//  SliderPuzzle
//
//  Created by Tony Hillerson on 3/14/12.
//  Copyright (c) 2012 Tack Mobile, LLC. All rights reserved.
//

#import "ImageSlicer.h"

@interface ImageSlicer (Private)
- (void) slice;
- (void) addImageSliceFromRow:(NSInteger)rowI column:(NSInteger)colI;
@end

@implementation ImageSlicer
@synthesize unslicedImage, tileSize, rows, columns, sizedImage, slices, unservedSlices;

- (id) initWithUnslicedImage:(CGImageRef)image rows:(NSInteger)rnum columns:(NSInteger)cnum tileSize:(CGSize)size {
    if (self = [super init]) {
        self.unslicedImage = image;
        self.tileSize = CGSizeMake(size.width, size.height);
        self.rows = rnum;
        self.columns = cnum;
        
        self.slices = [NSMutableSet setWithCapacity:rows*columns];
        [self slice];
        self.unservedSlices = [NSMutableArray arrayWithArray:[self.slices allObjects]];
    }
    return self;
}

- (void) dealloc {
    CGContextRelease(sizedContext);
    CGImageRelease(self.sizedImage);
}

- (void) slice {
    CGSize totalSize = CGSizeMake(self.rows * self.tileSize.width, self.columns * self.tileSize.height);
    sizedContext = CGBitmapContextCreate(NULL,
                                         totalSize.width,
                                         totalSize.height,
                                         8,
                                         totalSize.width * 4, // rgba
                                         CGColorSpaceCreateDeviceRGB(),
                                         kCGImageAlphaNoneSkipFirst);
    
    CGContextDrawImage(sizedContext, CGRectMake(0, 0, totalSize.width, totalSize.height), self.unslicedImage);
    self.sizedImage = CGBitmapContextCreateImage(sizedContext);
    
    for (int rowI = 0; rowI <= 3; rowI++) { for (int colI = 0; colI <= 3; colI++) { [self addImageSliceFromRow:rowI column:colI]; } }
}

- (void) addImageSliceFromRow:(NSInteger)rowI column:(NSInteger)colI {
    CGRect tileRect = CGRectMake(rowI * self.tileSize.width, colI * self.tileSize.height, self.tileSize.width, self.tileSize.height);
    CGImageRef tileImage = CGImageCreateWithImageInRect(self.sizedImage, CGRectMake(tileRect.origin.x, tileRect.origin.y, tileRect.size.width, tileRect.size.height));
    [slices addObject:(__bridge_transfer id)tileImage];
}

- (CGImageRef) serveRandomSlice {
    NSUInteger randomIndex = arc4random() % [self.unservedSlices count];
    CGImageRef ref = (__bridge CGImageRef)[self.unservedSlices objectAtIndex:randomIndex];
    [self.unservedSlices removeObjectAtIndex:randomIndex];
    return ref;
}


@end
