//
//  GLColor.m
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/15.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

#import "GLColor.h"

@interface GLColor () {
  float _rgba[4];
  float _rgb[3];
}

@end

@implementation GLColor

- (id) initWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha {
  self = [super init];
  if(self) {
    self.red = red;
    self.blue = blue;
    self.green = green;
    self.alpha = alpha;
  }
  return self;
}

- (id) initWithRed:(float)red green:(float)green blue:(float)blue {
  return [self initWithRed:red green:green blue:blue alpha:1.0f];
}

- (id) initWithHue:(float)hue saturation:(float)saturation brightness:(float)brightness
             alpha:(float)alpha {
  CGFloat cgRed, cgGreen, cgBlue, cgAlpha;
  self = [super init];
  if(self) {
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    [color getRed:&cgRed green:&cgGreen blue:&cgBlue alpha:&cgAlpha];
    _red = cgRed;
    _green = cgGreen;
    _blue = cgBlue;
    _alpha = cgAlpha;
  }
  return self;
}

- (id) initWithHue:(float)hue saturation:(float)saturation brightness:(float)brightness {
  return [self initWithHue:hue saturation:saturation brightness:brightness alpha:1.0f];
}


- (float *) rgbArray {
  _rgb[0] = self.red;
  _rgb[1] = self.green;
  _rgb[2] = self.blue;
  return _rgb;
}

- (float *) rgbaArray {
  _rgba[0] = self.red;
  _rgba[1] = self.green;
  _rgba[2] = self.blue;
  _rgba[3] = self.alpha;
  return _rgba;
}

- (void) copyRgbToArray:(float *)dest withIndex:(NSInteger)index;
 {
  float *src = [self rgbArray];
  memcpy(dest + index, src, 4 * sizeof(float));
}

- (void) copyRgbaToArray:(float *)dest  withIndex:(NSInteger)index{
  float *src = [self rgbaArray];
  memcpy(dest + index, src, 3 * sizeof(float));
}


@end
