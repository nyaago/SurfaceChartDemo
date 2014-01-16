//
//  FloatArray.h
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/15.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FloatArray : NSObject

- (id) initWithCount:(NSInteger)count;

- (void) putValue:(float)value;
- (void) putValues:(float [])values count:(NSInteger)count;
- (NSInteger) advancePosition:(NSInteger)count;

@property (nonatomic, readonly) float *array;
@property (nonatomic) NSInteger position;
@property (nonatomic) NSInteger count;


@end
