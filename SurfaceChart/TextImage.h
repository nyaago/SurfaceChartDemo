//
//  TextImage.h
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/16.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextImage : NSObject {
  Byte *_bitmapBuffer;
  CGImageRef _image;
}

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *backgroundColor;

- (CGFloat) textWidth:(NSString *)text;
- (CGSize) textSize:(NSString *)text;
- (void) releaseImage;
- (Byte *) drawStringToTexture:(NSString *)text;

@end
