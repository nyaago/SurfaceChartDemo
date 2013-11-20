//
//  TextImage.m
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/16.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

#import "TextImage.h"

@interface TextImage() {
  CGContextRef _bitmapContext;
}
@end

@implementation TextImage

- (id) init {
  self = [super init];
  if(self) {
    _color = [UIColor blackColor];
    _font = [UIFont systemFontOfSize:14];
    _backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f];
  }
  return self;
}

- (CGSize) textSize:(NSString *)text {
	//実際の描画サイズを取得
	CGSize size = [self realTextSize:text];
  NSInteger bmpWidth = 64;// ２のべき乗で最小64
  while(size.width > bmpWidth){
    bmpWidth *= 2;
  }
  size.width = bmpWidth;
  size.height = bmpWidth;
  return size;
}

- (CGFloat) textWidth:(NSString *)text {
	//実際の描画サイズを取得
	CGSize size = [self realTextSize:text];
  return size.width;
}

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (CGSize) realTextSize:(NSString *)text {
  CGSize fontSize;
  if([text respondsToSelector:@selector(sizeWithAttributes:)]) {
    fontSize = [text sizeWithAttributes:@{NSFontAttributeName:self.font}];
  }
  else {
    fontSize = [text sizeWithFont:_font constrainedToSize:CGSizeMake(512,512)
         lineBreakMode:NSLineBreakByWordWrapping];

  }
  return fontSize;
}
#pragma GCC diagnostic warning "-Wdeprecated-declarations"


- (Byte *)drawStringToTexture:(NSString *)text 
{
  CGSize size = [self textSize:text];

  _bitmapBuffer = (Byte *)malloc(sizeof(Byte) * size.height * size.width * 4);
  memset(_bitmapBuffer, 0,sizeof(Byte) * size.height * size.width * 4 );
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  _bitmapContext = CGBitmapContextCreate(
                        _bitmapBuffer,  // 利用するメモリ領域
                        size.width,   // 作成するContextの横幅
                        size.height,  // 作成するContextの縦幅
                        8, // bits per component
                        4 * size.width, // 1行あたりのバイト数
                        colorSpace,  // 色の指定方法
                        kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast // 透明度の指定方法
                        );
  
  CGFloat red;
  CGFloat green;
  CGFloat blue;
  CGFloat alpha;
  [self.backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
  
  CGContextSetRGBFillColor(_bitmapContext, red, green, blue, alpha);
  CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
  CGContextFillRect(_bitmapContext, rect);
  UIGraphicsPushContext(_bitmapContext);
  [self.color set];
  
  [self drawText:text font:self.font x:0.0f y:0.0f color:self.color context:_bitmapContext];
  
  UIGraphicsPopContext();
  _image =CGBitmapContextCreateImage(_bitmapContext);
  return _bitmapBuffer;
}

- (void) releaseImage {
  if(_bitmapBuffer) {
    CGImageRelease(_image);
    _image = NULL;
    free(_bitmapBuffer);
    CGContextRelease(_bitmapContext);
    _bitmapContext = NULL;
  }
  
}


- (void) drawText:(NSString *)text font:(UIFont *)font x:(CGFloat)x y:(CGFloat)y
            color:(UIColor *)color
          context:(CGContextRef)context {
  if([text respondsToSelector:@selector(drawAtPoint:withAttributes:)]) {
    [self drawTextIOS7:text font:font x:x y:y color:color context:context];
  }
  else {
    [self drawTextLegacy:text font:font x:x y:y color:color context:context];
  }
}


// for IOS7
- (void) drawTextIOS7:(NSString *)text font:(UIFont *)font x:(CGFloat)x y:(CGFloat)y
                color:(UIColor *)color
              context:(CGContextRef)context {
  NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                              font, NSFontAttributeName,
                              color, NSForegroundColorAttributeName,
                              nil];
  
  [text drawAtPoint:CGPointMake(x, y) withAttributes:attributes];
}


// for IOS6
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wconversion"
- (void) drawTextLegacy:(NSString *)text font:(UIFont *)font x:(CGFloat)x y:(CGFloat)y
                  color:(UIColor *)color
                context:(CGContextRef)context {
  CGSize size = [self textSize:text];
  CGRect rect = CGRectMake(x, y, size.width, size.height);
  [text drawInRect:rect withFont:font lineBreakMode:UILineBreakModeWordWrap];
}
#pragma GCC diagnostic warning "-Wdeprecated-declarations"
#pragma GCC diagnostic warning "-Wconversion"


@end
