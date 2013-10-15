//
//  ColorUtils.h
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/15.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorUtils : NSObject

/**
 * 値を色相にMappingする。最大値が赤(0度）、最小値が青(指定値）となる範囲のMappingとする。
 * @param value
 * @param max
 * @param min
 * @param hueWidth 最大値から最小値までの色相の範囲、ただし、hueForMinがこれより小さい場合は、
 *                大きいほうの値は連続的な色相変化ではなくなる
 * @param minHue 最小値の場合の色相
 * @return 色相値 0度から360度
 */
+ (NSInteger) valueToHue:(NSInteger)value max:(NSInteger)max min:(NSInteger)min
                hueWidth:(NSInteger)hueWidth minHue:(NSInteger)minHue;

@end
