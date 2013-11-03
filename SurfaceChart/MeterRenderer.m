//
//  MeterRenderer.m
//  TachoMeterDemo
//
//  Created by nyaago on 2013/10/21.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

#import "MeterRenderer.h"

@implementation MeterRenderer


- (void)tearDownGL
{
  glDeleteBuffers(1, &_vertexBuffer);
  glDeleteVertexArraysOES(1, &_vertexArray);
  
  self.effect = nil;
  
  if (_program) {
    glDeleteProgram(_program);
    _program = 0;
  }
}


- (void)update
{
  float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
  GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-self.aspect, self.aspect, -1.0f, 1.0f, -100, 100);

//  GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
  self.effect.transform.projectionMatrix = projectionMatrix;
  
  GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
  //  baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
  
  // Compute the model view matrix for the object rendered with GLKit
  GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
  //  modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
  modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
  
  self.effect.transform.modelviewMatrix = modelViewMatrix;
  
  // Compute the model view matrix for the object rendered with ES2
  modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
  //  modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
  modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
  
  _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
  
  _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
  
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
  // Create shader program.
  _program = [self.shaderLoader loadShaders:@"Shader"];
  // Bind attribute locations.
  // This needs to be done prior to linking.
  glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
  //  glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
  glBindAttribLocation(_program, GLKVertexAttribColor, "color");
  
  // Link program.
  if (![self.shaderLoader linkProgram]) {
    NSLog(@"Failed to link program: %d", self.shaderLoader.program);
    return NO;
  }
  
  // Get uniform locations.
  uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
  uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
  
  // Release vertex and fragment shaders.
  [self.shaderLoader releaseShaders];
  return YES;
}

- (BOOL)loadTextureShaders
{
  // Create shader program.
  _textureProgram = [self.textureShaderLoader loadShaders:@"TextureShader"];
  // Bind attribute locations.
  // This needs to be done prior to linking.
  glBindAttribLocation(_textureProgram, GLKVertexAttribPosition, "position");
  //  glBindAttribLocation(_textureProgram, GLKVertexAttribNormal, "normal");
  glBindAttribLocation(_textureProgram, GLKVertexAttribTexCoord0, "texcoord");
  
  // Link program.
  if (![self.textureShaderLoader linkProgram]) {
    NSLog(@"Failed to link program: %d", self.shaderLoader.program);
    return NO;
  }
  
  // Get uniform locations.
  uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_textureProgram, "modelViewProjectionMatrix");
  uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_textureProgram, "normalMatrix");
  
  // Release vertex and fragment shaders.
  [self.textureShaderLoader releaseShaders];
  return YES;
}


#pragma mark - 

/*!
 * 指定したテキストを描画する
 * @param text 描画テキスト
 * @param x 描画位置-openglの座標 -x
 * @param y 描画位置-openglの座標 -y
 * @param z 描画位置-openglの座標 -z
 * @param font フォント
 * @param textColor
 * @param backgroundColor
 */
- (void) drawText:(NSString *)text x:(CGFloat)x y:(CGFloat)y z:(CGFloat)z
             font:(UIFont *)font
        textColor:(UIColor *)textColor
  backgroundColor:(UIColor *)backgroundColor
{
  
  float margin = 0.0f;
  // テキストのビットマップを生成してOpenGLへ
  TextImage *textImage = [[TextImage alloc] init];
  textImage.font = font;
  textImage.color = textColor;
  textImage.backgroundColor = backgroundColor;
  CGSize size = [textImage textSize:text];
  CGFloat tw = [textImage textWidth:text];
  Byte *pixels =  [textImage drawStringToTexture:text];
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, size.width, size.height, 0,
               GL_RGBA, GL_UNSIGNED_BYTE, pixels);
  //
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  
  NSInteger bmpWidth = [textImage textSize:text].width;
  float w = [self pxWidthToOpenGLWidth:bmpWidth];
  float textWidth = [self pxWidthToOpenGLWidth:tw];
  float h = [self pxHeightToOpenGLHeight:font.lineHeight * (1.0f + margin) ];
  float left = x - (textWidth / 2);
  float right = left + w;
  float bottom = bottom = y - (h / 2);
  float top = bottom + h;
  CGFloat  vertex [] =  {
    left, top, z,
    left, bottom, z,
    right, top, z,
    right, bottom, z
  };
  CGFloat  uv[] = {
    0.0f, 1.0f,
    0.0f, ((float)(bmpWidth - font.pointSize * (1.0f + margin)) / bmpWidth),
    1.0f, 1.0f,
    1.0f, ((float)(bmpWidth - font.pointSize * (1.0f + margin)) / bmpWidth),
  };
  //頂点配列の指定
  NSInteger pos =[self texturePositionInValueVertex] * VERTEX_ATTRIB_SIZE ;
  self.vertexs.position = [self texturePositionInValueVertex] * VERTEX_ATTRIB_SIZE ;
  for(int i = 0; i < 4; ++i) {
    [self.vertexs putValue:vertex[i * 3]];
    [self.vertexs putValue:vertex[i * 3 + 1]];
    [self.vertexs putValue:vertex[i * 3 + 2]];
    [self.vertexs advancePosition:VERTEX_COLOR_SIZE];
    [self.vertexs putValue:uv[i*2]];
    [self.vertexs putValue:uv[i*2+1]];
  }
  
  glBufferSubData(GL_ARRAY_BUFFER,
                  sizeof(CGFloat) * pos,
                  4 * VERTEX_ATTRIB_SIZE * sizeof(CGFloat),
                  self.vertexs.array + ( [self texturePositionInValueVertex] * VERTEX_ATTRIB_SIZE));
  //
  glDrawArrays(GL_TRIANGLE_STRIP, [self texturePositionInValueVertex], 4);
  [textImage releaseImage];
  
}

#pragma mark  Functions


- (NSInteger) width {
  return self.view.bounds.size.width;
}

- (NSInteger) height {
  return self.view.bounds.size.height;
}

- (CGFloat) aspect {
  return fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
}

/*!
 * 幅のpx値からのopenGL座標の大きさへ変換
 * @param px 幅のpx値
 * @return openGL座標での大きさ
 */
- (CGFloat) pxWidthToOpenGLWidth:(CGFloat) px {
  return [self aspect] * 2.0f / (float)[self width] * px;
}

/*!
 * 高さのpx値からのopenGL座標の大きさへ変換
 * @param px 高さのpx値
 * @return  openGL座標での大きさ
 */
- (CGFloat) pxHeightToOpenGLHeight:(CGFloat) px {
  return (2.0f / (float)[self height]) * px;
}

- (NSInteger) openGLWidthToPx:(CGFloat)textSize {
  // PX_Width / openGL座標系のwidth * openGL座標系のtextSize
  return (int)((CGFloat)self.width /  ((CGFloat)self.width / (CGFloat)self.height * 2.0f)
               * (CGFloat)textSize);
}

#pragma mark - Override by inherited Class

-(NSInteger) texturePositionInValueVertex {
  return 0;
}



#pragma mark - Private Methods





@end
