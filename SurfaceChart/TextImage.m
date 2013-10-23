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
	CGSize size = [text sizeWithFont:_font constrainedToSize:CGSizeMake(512,512)
              lineBreakMode:NSLineBreakByWordWrapping];
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
	CGSize size = [text sizeWithFont:_font constrainedToSize:CGSizeMake(512,512)
                     lineBreakMode:NSLineBreakByWordWrapping];
  return size.width;
}



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
                        kCGImageAlphaPremultipliedLast // 透明度の指定方法
                        );
  
//  CGContextSetRGBFillColor(_bitmapContext,0,0,0,1.0);
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
  
  [text drawInRect:rect withFont:self.font lineBreakMode:UILineBreakModeWordWrap];
  
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




@end
