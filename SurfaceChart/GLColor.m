//
//  GLColor.m
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/15.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

#import "GLColor.h"

@interface GLColor () {
  CGFloat _rgba[4];
  CGFloat _rgb[3];
}

@end

@implementation GLColor

- (id) initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
  self = [super init];
  if(self) {
    self.red = red;
    self.blue = blue;
    self.green = green;
    self.alpha = alpha;
  }
  return self;
}

- (id) initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
  return [self initWithRed:red green:green blue:blue alpha:1.0f];
}

- (id) initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness
             alpha:(CGFloat)alpha {
  self = [super init];
  if(self) {
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
    [color getRed:&_red green:&_green blue:&_blue alpha:&_alpha];
  }
  return self;
}

- (id) initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness {
  return [self initWithHue:hue saturation:saturation brightness:brightness alpha:1.0f];
}


- (CGFloat *) rgbArray {
  _rgb[0] = self.red;
  _rgb[1] = self.green;
  _rgb[2] = self.blue;
  return _rgb;
}

- (CGFloat *) rgbaArray {
  _rgba[0] = self.red;
  _rgba[1] = self.green;
  _rgba[2] = self.blue;
  _rgba[3] = self.alpha;
  return _rgba;
}

- (void) copyRgbToArray:(CGFloat *)dest withIndex:(NSInteger)index;
 {
  CGFloat *src = [self rgbArray];
  memcpy(dest + index, src, 4 * sizeof(CGFloat));
}

- (void) copyRgbaToArray:(CGFloat *)dest  withIndex:(NSInteger)index{
  CGFloat *src = [self rgbaArray];
  memcpy(dest + index, src, 3 * sizeof(CGFloat));
}


@end
