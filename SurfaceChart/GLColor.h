//
//  GLColor.h
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/15.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLColor : NSObject

@property (nonatomic) CGFloat red;
@property (nonatomic) CGFloat blue;
@property (nonatomic) CGFloat green;
@property (nonatomic) CGFloat alpha;

- (id) initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

- (id) initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;

- (id) initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness
             alpha:(CGFloat)alpha;

- (id) initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness;

- (CGFloat *) rgbArray;

- (CGFloat *) rgbaArray;

- (void) copyRgbToArray:(CGFloat *)dest withIndex:(NSInteger)index;

- (void) copyRgbaToArray:(CGFloat *)dest  withIndex:(NSInteger)index;

@end
