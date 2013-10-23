//
//  ShaderUtils.h
//  TachoMeterDemo
//
//  Created by nyaago on 2013/10/18.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Shader の ローディング
 */
@interface ShaderLoader : NSObject

@property (nonatomic) GLuint vertShader;
@property (nonatomic) GLuint fragShader;
@property (nonatomic) GLuint program;

/*!
 Shader の ロード,コンパイル
 */
- (GLuint)loadShaders:(NSString *)name;
- (BOOL)linkProgram;
- (BOOL)validateProgram;
- (void)releaseShaders;

@end
