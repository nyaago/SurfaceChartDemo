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
    _array = (float *)malloc(sizeof(float) * count);
    _position = 0;
  }
  return self;
}

- (void) putValue:(float)value {
  *(_array + _position) = value;
  _position += 1;
}

- (void) putValues:(float [])values count:(NSInteger)count {
  memcpy(_array + _position, values, sizeof(float) * count);
  _position += count;
}

- (NSInteger) advancePosition:(NSInteger)count {
  for(int i = 0; i < count; ++i) {
    *(_array + _position) = 0;
  }
  _position += count;
  return _position;
}

- (void) dealloc {
  free(_array);
}

- (void) setPosition:(NSInteger)position {
  _position = position;
  if(_position > _count) {
    NSLog(@"position over " );
  }
}

@end
