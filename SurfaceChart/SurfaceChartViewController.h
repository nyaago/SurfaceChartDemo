//
//  ViewController.h
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/15.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "GLColor.h"

@class SurfaceChartViewController;

@protocol SurfaceChartViewSource <NSObject>

/*!
 @return X軸の最大値
 */
- (NSInteger) xAxisMax;
/*!
 @return Y軸の最大値
 */
- (NSInteger) yAxisMax;
/*!
 @return Z軸の最大値
 */
- (NSInteger) zAxisMax;
/*!
 @return X軸の最小値
 */
- (NSInteger) xAxisMin;
/*!
 @return Y軸の最小値
 */
- (NSInteger) yAxisMin;
/*!
 @return Z軸の最小値
 */
- (NSInteger) zAxisMin;
/*!
 @return X軸のスケール
 */
- (NSInteger) xAxisScale;
/*!
 @return Y軸のスケール
 */
- (NSInteger) yAxisScale;
/*!
 @return Z軸のスケール
 */
- (NSInteger) zAxisScale;
/*!
 @return X軸のスケール
 */
- (NSInteger) xAxisScaleForValue;
/*!
 @return Z軸のスケール
 */
- (NSInteger) zAxisScaleForValue;

/*!
 @return x軸の表示名
 @param x
 */
- (NSString *) xAxisName:(NSInteger)x;
/*!
 @return y軸の表示名
 @param y
 */
- (NSString *) yAxisName:(NSInteger)y;
/*!
 @return z軸の表示名
 @param z
 */
- (NSString *) zAxisName:(NSInteger)z;

/*!
 @return x軸のタイトル
 */
- (NSString *) xAxisTitle;
/*!
 @return y軸のタイトル
 */
- (NSString *) yAxisTitle;
/*!
 @return z軸のタイトル
 */
- (NSString *) zAxisTitle;

/*!
 @return y軸の値
 @param x
 @param z
 */
- (NSInteger) yWithX:(NSInteger)x z:(NSInteger)z;

/*!
 @param Yの値に対する描画色
 */
- (GLColor *) colorForY:(NSInteger)y;



@end


@interface SurfaceChartViewController : GLKViewController

/*!
 * レンダリングエリア中のChart 部分の全体を1としての比率 - X
 */
@property (nonatomic) CGFloat rarioToRenderX;
/*!
 * レンダリングエリア中のChart 部分の全体を1としての比率 - X - 横向きのとき
 */
@property (nonatomic) CGFloat rarioToRenderXHor;
/*!
 * レンダリングエリア中のChart 部分の全体を1としての比率 - Y
 */
@property (nonatomic) CGFloat rarioToRenderY;
/*!
 * レンダリングエリア中のChart 部分の全体を1としての比率 - Y - 横向きのとき
 */
@property (nonatomic) CGFloat rarioToRenderYHor;
/*!
 * レンダリングエリア中のChart 部分の全体を1としての比率 - Z
 */
@property (nonatomic) CGFloat rarioToRenderZ;
/*!
 * レンダリングエリア中のChart 部分の全体を1としての比率 - Z
 */
@property (nonatomic) CGFloat ratioToRenderZHor;

/*!
 * 枠の背景色
 */
@property (nonatomic, strong) GLColor *bottomFrameBackgroundColor;

/*!
 * 枠のラインの色
 */
@property (nonatomic, strong) GLColor *frameLineColor;

/*!
 * 値のラインの色
 */

@property (nonatomic, strong) GLColor *textBackgroundColor;

/*!
 * 文字の背景色
 */
@property (nonatomic, strong) GLColor *valueLineColor;


@property (nonatomic) NSInteger scaleFontSize;
@property (nonatomic) NSInteger titleFontSize;

@property (nonatomic, strong) UIColor *scaleFontColor;
@property (nonatomic, strong) UIColor *titleFontColor;

@property (nonatomic, strong) NSObject <SurfaceChartViewSource> *source;

@end
