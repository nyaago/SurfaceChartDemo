//
//  FloatArray.m
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/15.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

#import "FloatArray.h"

@interface FloatArray()


@end

@implementation FloatArray


- (id) initWithCount:(NSInteger)count {
  self = [super init];
  if(self) {
    _count = count;
    _array = (CGFloat *)malloc(sizeof(CGFloat) * count);
    _position = 0;
  }
  return self;
}

- (void) putValue:(CGFloat)value {
  *(_array + _position) = value;
  _position += 1;
}

- (void) putValues:(CGFloat [])values count:(NSInteger)count {
  memcpy(_array + _position, values, sizeof(CGFloat) * count);
  _position += count;
}

- (NSInteger) advancePosition:(NSInteger)count {
  _position += count;
  return _position;
}

- (void) dealloc {
  free(_array);
}


@end
