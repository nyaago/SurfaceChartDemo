//
//  ColorUtils.m
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/15.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

#import "ColorUtils.h"

@implementation ColorUtils


+ (NSInteger) valueToHue:(NSInteger)value max:(NSInteger)max min:(NSInteger)min
                hueWidth:(NSInteger)hueWidth minHue:(NSInteger)minHue {
  int hue =  minHue
  -  (int)(((float)(value - min)) /  ((float)((float)max - (float)min) /  (float)hueWidth));
  if(hue < 0) {
    hue = 0;
  }
  return hue;
}


@end
