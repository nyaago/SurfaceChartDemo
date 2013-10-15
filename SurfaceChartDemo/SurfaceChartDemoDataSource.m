//
//  SurfaceChartDemoDataSource.m
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/15.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

#import "SurfaceChartDemoDataSource.h"
#import "ColorUtils.h"

@implementation SurfaceChartDemoDataSource

- (NSInteger) xAxisMax {
  return 14000;
}
- (NSInteger) yAxisMax {
  return 2500;
}

- (NSInteger) zAxisMax {
  return 100;
}
- (NSInteger) xAxisMin {
  return 0;
  
}
- (NSInteger) yAxisMin {
  return -2500;
  
}
- (NSInteger) zAxisMin {
  return 0;
  
}
- (NSInteger) xAxisScale {
  return 1000;
  
}
- (NSInteger) yAxisScale {
  return 500;
}
- (NSInteger) zAxisScale {
  return 10;
}
- (NSInteger) xAxisScaleForValue {
  return 1000;
}
- (NSInteger) zAxisScaleForValue {
  return 10;
}

- (NSString *) xAxisName:(NSInteger)x {
  return [NSString stringWithFormat:@"%d", x];
}
- (NSString *) yAxisName:(NSInteger)y {
  return [NSString stringWithFormat:@"%d", y];
  
}
- (NSString *) zAxisName:(NSInteger)z {
  return [NSString stringWithFormat:@"%d", z];

}

- (NSString *) xAxisTitle {
    return @"x-axis";
}
- (NSString *) yAxisTitle {
  return @"y-axis";
  
}
- (NSString *) zAxisTitle {
  return @"z-axis";
}

- (NSInteger) yWithX:(NSInteger)x z:(NSInteger)z{
  if(x > 5000) {
    return x / 10 + z;
  }
  else {
    return -x / 10 + z;
  }
}

- (GLColor *) colorForY:(NSInteger)y {
  NSInteger hue = [ColorUtils valueToHue:y max:[self yAxisMax] min:[self yAxisMin]
                                hueWidth:300 minHue:255];
  return [[GLColor alloc] initWithHue:(float)hue/255.0f saturation:1.0f brightness:1.0f];
}



@end
