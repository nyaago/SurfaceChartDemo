//
//  GLColor.h
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/15.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLColor : NSObject

@property (nonatomic) float red;
@property (nonatomic) float blue;
@property (nonatomic) float green;
@property (nonatomic) float alpha;

- (id) initWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

- (id) initWithRed:(float)red green:(float)green blue:(float)blue;

- (id) initWithHue:(float)hue saturation:(float)saturation brightness:(float)brightness
             alpha:(float)alpha;

- (id) initWithHue:(float)hue saturation:(float)saturation brightness:(float)brightness;

- (float *) rgbArray;

- (float *) rgbaArray;

- (void) copyRgbToArray:(float *)dest withIndex:(NSInteger)index;

- (void) copyRgbaToArray:(float *)dest  withIndex:(NSInteger)index;

@end
