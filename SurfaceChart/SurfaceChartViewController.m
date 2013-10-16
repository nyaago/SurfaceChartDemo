//
//  ViewController.m
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/15.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

#import "SurfaceChartViewController.h"
#import "FloatArray.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#define VERTEX_POS_SIZE  3
#define VERTEX_COLOR_SIZE  3

#define VERTEX_ATTRIB_SIZE 6

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};


@interface SurfaceChartViewController () {
  GLuint _program;
  GLuint _textureProgram;
  
  GLKMatrix4 _modelViewProjectionMatrix;
  GLKMatrix3 _normalMatrix;
  
  GLuint _vertexArray;
  GLuint _vertexBuffer;

  GLuint _textureVertexArray;
  GLuint _textureVertexBuffer;

  FloatArray *_vertexs;
  /*!
   * vertex pointer の offset - XY軸の枠描画
   */
  NSInteger _firstOfXYAxis;
  /*!
   * vertex pointer の offset - YZ軸の枠描画
   */
  NSInteger _firstOfYZAxis;
  /*!
   * vertex pointer の offset - XZ軸の枠描画
   */
  NSInteger _firstOfXZAxis;
  /*!
   * vertex pointer の offset - 値の描画
   */
  NSInteger _firstOfValue;

  /*!
   * X軸での回転角度
   */
  CGFloat _rotateByAngelX;
  
  /*!
   * Y軸での回転角度
   */
  CGFloat _rotateByAngelY;

  
  
}


@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;



- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation SurfaceChartViewController

- (id) init {
  self = [super init];
  if(self) {
    [self setDefault];
  }
  return self;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  _vertexs = [[FloatArray alloc] initWithCount:[self countValueVertex] * 6];
  
  self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

  if (!self.context) {
    NSLog(@"Failed to create ES context");
  }
  
  GLKView *view = (GLKView *)self.view;
  view.context = self.context;
  view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
  
  [self setupGL];
}

- (void)dealloc
{    
  [self tearDownGL];
  
  if ([EAGLContext currentContext] == self.context) {
    [EAGLContext setCurrentContext:nil];
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];

  if ([self isViewLoaded] && ([[self view] window] == nil)) {
    self.view = nil;
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
      [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
  }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
  [EAGLContext setCurrentContext:self.context];
  
  [self loadShaders];
  [self addVertex];
  
  /*
  self.effect = [[GLKBaseEffect alloc] init];
  self.effect.light0.enabled = GL_TRUE;
  self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
  */
  glEnable(GL_COLOR_ARRAY);
  
  glGenVertexArraysOES(1, &_vertexArray);
  glBindVertexArrayOES(_vertexArray);
  
  glGenBuffers(1, &_vertexBuffer);
  glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
  
  glBufferData(GL_ARRAY_BUFFER, sizeof(CGFloat) + [_vertexs count] , _vertexs.array, GL_STATIC_DRAW);
  //glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
  glEnableVertexAttribArray(GLKVertexAttribPosition);
  glVertexAttribPointer(GLKVertexAttribPosition, VERTEX_POS_SIZE, GL_FLOAT, GL_FALSE,
                        VERTEX_ATTRIB_SIZE * sizeof(GLfloat),
                        BUFFER_OFFSET(0));
  
  glEnableVertexAttribArray(GLKVertexAttribColor);
  glVertexAttribPointer(GLKVertexAttribColor, VERTEX_COLOR_SIZE, GL_FLOAT, GL_FALSE,
                        VERTEX_ATTRIB_SIZE * sizeof(GLfloat),
                        BUFFER_OFFSET(VERTEX_POS_SIZE * sizeof(GLfloat)));

  
  glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
  [EAGLContext setCurrentContext:self.context];
  
  glDeleteBuffers(1, &_vertexBuffer);
  glDeleteVertexArraysOES(1, &_vertexArray);
  
  self.effect = nil;
  
  if (_program) {
    glDeleteProgram(_program);
    _program = 0;
  }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
  float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
//  GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
  GLKMatrix4 projectionMatrix = GLKMatrix4MakeFrustum(-aspect, aspect, -1, 1, 15.0f, 45.0f);
  projectionMatrix = GLKMatrix4Multiply(projectionMatrix,
                                        GLKMatrix4MakeLookAt(0.0f,0.0f, 20.0f,0.0f,0.0f,0.0f,0.0f, 1.0f, 0.0f));
  
  self.effect.transform.projectionMatrix = projectionMatrix;
  
  GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
//  baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
  baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotateByAngelY, 0.0f, 1.0f, 0.0f);
  baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotateByAngelX, 1.0f, 0.0f, 0.0f);
  
  // Compute the model view matrix for the object rendered with GLKit
  GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -0.0f);
//  modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
//  modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
  self.effect.transform.modelviewMatrix = modelViewMatrix;
  
  // Compute the model view matrix for the object rendered with ES2
  modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
//  modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
  modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
  
  _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
  
  _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
  
  //_rotation += self.timeSinceLastUpdate * 0.5f;
  // @TODO - ピンチ中は..Pauseしない..
  self.paused = YES;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
  glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

//glEnable(GL_BLEND);
//glBlendFunc(GL_SRC_ALPHA, GL_ONE);

  glBindVertexArrayOES(_vertexArray);

  // Render the object with GLKit
  // [self.effect prepareToDraw];
  
//  [self drawVertexArray];
  
  // Render the object again with ES2
  glUseProgram(_program);
  
  glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
  glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
  
  glLineWidth(1.0f);
  [self drawVertexArray];
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
  GLuint vertShader, fragShader;
  NSString *vertShaderPathname, *fragShaderPathname;
  
  // Create shader program.
  _program = glCreateProgram();
  
  // Create and compile vertex shader.
  vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
  if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
      NSLog(@"Failed to compile vertex shader");
      return NO;
  }
  
  // Create and compile fragment shader.
  fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
  if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
      NSLog(@"Failed to compile fragment shader");
      return NO;
  }
  
  // Attach vertex shader to program.
  glAttachShader(_program, vertShader);
  
  // Attach fragment shader to program.
  glAttachShader(_program, fragShader);
  
  // Bind attribute locations.
  // This needs to be done prior to linking.
  glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
  glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");

  glBindAttribLocation(_program, GLKVertexAttribColor, "color");
  // Link program.
  if (![self linkProgram:_program]) {
      NSLog(@"Failed to link program: %d", _program);
      
      if (vertShader) {
          glDeleteShader(vertShader);
          vertShader = 0;
      }
      if (fragShader) {
          glDeleteShader(fragShader);
          fragShader = 0;
      }
      if (_program) {
          glDeleteProgram(_program);
          _program = 0;
      }
      
      return NO;
  }
  
  // Get uniform locations.
  uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
  uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
  
  // Release vertex and fragment shaders.
  if (vertShader) {
    glDetachShader(_program, vertShader);
    glDeleteShader(vertShader);
  }
  if (fragShader) {
    glDetachShader(_program, fragShader);
    glDeleteShader(fragShader);
  }
  
  return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
      NSLog(@"Failed to load vertex shader");
      return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
      GLchar *log = (GLchar *)malloc(logLength);
      glGetShaderInfoLog(*shader, logLength, &logLength, log);
      NSLog(@"Shader compile log:\n%s", log);
      free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
      glDeleteShader(*shader);
      return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
      GLchar *log = (GLchar *)malloc(logLength);
      glGetProgramInfoLog(prog, logLength, &logLength, log);
      NSLog(@"Program link log:\n%s", log);
      free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
  GLint logLength, status;
  
  glValidateProgram(prog);
  glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0) {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetProgramInfoLog(prog, logLength, &logLength, log);
    NSLog(@"Program validate log:\n%s", log);
    free(log);
  }
  
  glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
  if (status == 0) {
    return NO;
  }
  
  return YES;
}

#pragma mark Drawing

- (void) addVertex {
  _vertexs.position = 0;
  _firstOfXYAxis = 0;
  _firstOfYZAxis = [self addXYAxisVertex];
  _firstOfXZAxis = [self addYZAxisVertex];
  _firstOfValue = [self addXZAxisVertex];
  [self addValueVertex];
}

- (void) drawVertexArray {
  glDisable(GL_DEPTH_TEST);
  [self drawXYAxisVertex:_firstOfXYAxis];
  [self drawYZAxisVertex:_firstOfYZAxis];
  [self drawXZAxisVertex:_firstOfXZAxis];
  glEnable(GL_DEPTH_TEST);
  [self drawValueVertex:_firstOfValue];
}

/*!
 * 値をTRIANGLEでfillするさいにY座標からマイナスする値 - 線が隠れないように下げる量
 */
#define  SUB_FROM_TRIAGLE_Y  0.003f;
/*!
 * 値部分描画の頂点バッファ生成
 */
-(NSInteger) addValueVertex {
  
  float vertex[3];
  int y;
  
  // === color fill する triangle ===
  for(int x = self.source.xAxisMin; x < self.source.xAxisMax; x += self.source.xAxisScaleForValue) {
    for(int z = self.source.zAxisMin;
        z < self.source.zAxisMax;
        z += self.source.zAxisScaleForValue) {
      
      // 手前左
      y = [self.source yWithX:x z:z];
      vertex[0] = [self xAxisToPoint:x];
      vertex[1] = [self yAxisToPoint:y] - SUB_FROM_TRIAGLE_Y;
      vertex[2] = [self zAxisToPoint:z];
      [_vertexs putValues:vertex count:3];
      [_vertexs putValues:[[self.source colorForY:y] rgbArray] count:3];
      
      // 奥左
      y =  [self.source yWithX:x z:z + [self.source zAxisScaleForValue]];
      vertex[0] = [self xAxisToPoint:x];
      vertex[1] = [self  yAxisToPoint:y] - SUB_FROM_TRIAGLE_Y;
      vertex[2] = [self zAxisToPoint:z + [self.source zAxisScaleForValue]];
      [_vertexs putValues:vertex count:3];
      [_vertexs putValues:[[self.source colorForY:y] rgbArray] count:3];
      
      // 手前右
      y = [self.source yWithX:x + [self.source xAxisScaleForValue] z:z];
      vertex[0] = [self xAxisToPoint:x + [self.source xAxisScaleForValue]];
      vertex[1] = [self yAxisToPoint:y] - SUB_FROM_TRIAGLE_Y;
      vertex[2] = [self zAxisToPoint:z];
      [_vertexs putValues:vertex count:3];
      [_vertexs putValues:[[self.source colorForY:y] rgbArray] count:3];
      
      // 奥右
      y = [self.source yWithX:x + [self.source xAxisScaleForValue] z:z + [self.source zAxisScaleForValue]];
      vertex[0] = [self xAxisToPoint:x + [self.source xAxisScaleForValue]];
      vertex[1] = [self yAxisToPoint:y] - SUB_FROM_TRIAGLE_Y;
      vertex[2] = [self zAxisToPoint:z + [self.source zAxisScaleForValue]];
      [_vertexs putValues:vertex count:3];
      [_vertexs putValues:[[self.source colorForY:y] rgbArray] count:3];
      
    }
  }
  // === line x 軸 ===
  for(int x =  [self.source xAxisMin];
      x < [self.source xAxisMax];
      x += [self.source xAxisScaleForValue]) {
    
    for(int z =  [self.source zAxisMin];
        z <= [self.source zAxisMax];
        z += [self.source zAxisScaleForValue]) {
      
      vertex[0] =  [self xAxisToPoint:x];
      vertex[1] = [self yAxisToPoint:[self.source yWithX:x z:z]];
      vertex[2] = [self zAxisToPoint:z];
      [_vertexs putValues:vertex count:3];
      [_vertexs putValues:[self.valueLineColor rgbArray] count:3];
      
      vertex[0] = [self xAxisToPoint:x + [self.source xAxisScaleForValue]];
      vertex[1] = [self yAxisToPoint:[self.source yWithX:x + [self.source xAxisScaleForValue] z:z]];
      [_vertexs putValues:vertex count:3];
      [_vertexs putValues:[self.valueLineColor rgbArray] count:3];
    }
  }
  // === line z 軸
  for(int z = [self.source zAxisMin];
      z < [self.source zAxisMax];
      z += [self.source zAxisScaleForValue]) {
    
    for(int x = [self.source xAxisMin];
        x <= [self.source xAxisMax];
        x += [self.source xAxisScaleForValue]) {
      vertex[0] =  [self xAxisToPoint:x];
      vertex[1] = [self yAxisToPoint:[self.source yWithX:x z:z]];
      vertex[2] = [self zAxisToPoint:z];
      [_vertexs putValues:vertex count:3];
      [_vertexs putValues:[self.valueLineColor rgbArray] count:3];

      vertex[1] = [self yAxisToPoint:[self.source yWithX:x z:z + [self.source zAxisScaleForValue]]];
      vertex[2] = [self zAxisToPoint:z + [self.source zAxisScaleForValue]];
      [_vertexs putValues:vertex count:3];
      [_vertexs putValues:[self.valueLineColor rgbArray] count:3];
    }
  }
  
  // === 前の部分の縦線
  for(int x = [self.source xAxisMin];
      x <= [self.source xAxisMax];
      x += [self.source xAxisScale]) {
    vertex[0] = [self xAxisToPoint:x];
    vertex[1] = [self yAxisToPoint:[self.source yWithX:x z:[self.source zAxisMax]]];
    vertex[2] = [self maxZOfChart];
    [_vertexs putValues:vertex count:3];
    [_vertexs putValues:[self.valueLineColor rgbArray] count:3];
    vertex[1] = [self yAxisToPoint:[self.source yAxisMin]];
    [_vertexs putValues:vertex count:3];
    [_vertexs putValues:[self.valueLineColor rgbArray] count:3];
  }
  
  // === 左の部分の縦線
  for(int z = [self.source zAxisMin];
      z <= [self.source zAxisMax];
      z += [self.source zAxisScale]) {
    vertex[0] =  -[self maxXOfChart];
    vertex[1] = [self yAxisToPoint:[self.source yWithX:[self.source xAxisMin] z:z]];
    vertex[2] = [self zAxisToPoint:z];
    [_vertexs putValues:vertex count:3];
    [_vertexs putValues:[self.valueLineColor rgbArray] count:3];
    vertex[1] = [self yAxisToPoint:[self.source yAxisMin]];
    [_vertexs putValues:vertex count:3];
    [_vertexs putValues:[self.valueLineColor rgbArray] count:3];
  }
  return _vertexs.position;
}

/*!
 *
 * @return 値描画のための頂点数
 */
-(NSInteger) countValueVertex {
  //
  return ([self scaleCountOfXAxisForValue] -1 ) *  ([self scaleCountOfZAxisForValue] - 1) * 4
  + ([self scaleCountOfXAxisForValue] -1 ) *  ([self scaleCountOfZAxisForValue] ) * 2
  + ([self scaleCountOfXAxisForValue] ) *  ([self scaleCountOfZAxisForValue] - 1 ) * 2
  + ([self scaleCountOfXAxis] * 2)
  + ([self scaleCountOfZAxis] * 2) ;
}

/*!
 * 値の描画
 * @param first 対応する頂点が納めされている頂点バッファ上のoffset
 */
-(void) drawValueVertex:(NSInteger)  first {

  glLineWidth(1.0f);

  int pos = first / 6;
  for(int x =  self.source.xAxisMin; x <  self.source.xAxisMax; x +=  self.source.xAxisScaleForValue) {
    for(int z =  self.source.zAxisMin;
        z <  self.source.zAxisMax;
        z +=  self.source.zAxisScaleForValue) {

      glDrawArrays(GL_TRIANGLE_STRIP, pos, 4);
      pos += 4;
    }
  }
  
  for(int x =  self.source.xAxisMin; x < self.source.xAxisMax; x +=  self.source.xAxisScaleForValue) {
    for(int z = self.source.zAxisMin;
        z <=  self.source.zAxisMax;
        z +=  self.source.zAxisScaleForValue) {
      
      glDrawArrays(GL_LINES, pos , 2);
      pos += 2;
    }
  }
  
  for(int z =  self.source.zAxisMin; z <  self.source.zAxisMax; z += self.source.zAxisScaleForValue) {
    for(int x =  self.source.xAxisMin;
        x <= self.source.xAxisMax;
        x += self.source.xAxisScaleForValue) {
      
      glDrawArrays(GL_LINES, pos , 2);
      pos += 2;
    }
  }
  for(int x =  self.source.xAxisMin; x <=  self.source.xAxisMax; x +=  self.source.xAxisScale) {
    glDrawArrays(GL_LINES, pos , 2);
    pos += 2;
  }
  
  for(int z = self.source.zAxisMin; z <= self.source.zAxisMax; z +=  self.source.zAxisScale) {
    glDrawArrays(GL_LINES, pos , 2);
    pos += 2;
  }
  //glDisable(GL_DEPTH_TEST);
}

/*!
 * XY軸の枠の頂点バッファ生成
 * @return バッファの最後の位置
 */
-(NSInteger) addXYAxisVertex {
  CGFloat vertex[3];
  
  // 枠
  vertex[0] = -[self maxXOfChart];
  vertex[1] = [self maxYOfChart];
  vertex[2] = -[self maxZOfChart];
  [_vertexs putValues:vertex count:3];
  [_vertexs putValues:[self.frameBackgroundColor rgbArray] count:3];

  vertex[0] = -[self maxXOfChart];
  vertex[1] = -[self maxYOfChart];
  [_vertexs putValues:vertex count:3];
  [_vertexs putValues:[self.frameBackgroundColor rgbArray] count:3];

  vertex[0] = [self maxXOfChart];
  vertex[1] = [self maxYOfChart];
  [_vertexs putValues:vertex count:3];
  [_vertexs putValues:[self.frameBackgroundColor rgbArray] count:3];

  vertex[0] = [self maxXOfChart];
  vertex[1] = -[self maxYOfChart];
  [_vertexs putValues:vertex count:3];
  [_vertexs putValues:[self.frameBackgroundColor rgbArray] count:3];
  
  // Y軸線
  for(int y = [self.source yAxisMin];
      y <= [self.source yAxisMax];
      y += [self.source yAxisScale] ) {
    vertex[0] = -[self maxXOfChart];
    vertex[1] = [self yAxisToPoint:y];
    vertex[2] = -[self maxZOfChart];
    [_vertexs putValues:vertex count:3];
    [_vertexs putValues:[self.frameLineColor rgbArray] count:3];

    vertex[0] = [self maxXOfChart];
    [_vertexs putValues:vertex count:3];
    [_vertexs putValues:[self.frameLineColor rgbArray] count:3];
  }
  // X軸線
  for(int x = [self.source xAxisMin];
      x <= [self.source xAxisMax];
      x += [self.source xAxisScale]) {
    vertex[0] = [self xAxisToPoint:x];
    vertex[1] = -[self maxYOfChart];
    vertex[2] = -[self maxZOfChart];
    [_vertexs putValues:vertex count:3];
    [_vertexs putValues:[self.frameLineColor rgbArray] count:3];

    vertex[1] = [self maxYOfChart];
    [_vertexs putValues:vertex count:3];
    [_vertexs putValues:[self.frameLineColor rgbArray] count:3];
  }
  return _vertexs.position;
}

/*!
 * @return XY軸の枠領域の頂点数
 */
-(NSInteger) countXYAxisVertex {
  // X軸 * 2 + Y軸 * 2 + 4（枠の四角形）
  return [self scaleCountOfXAxis] * 2 + [self scaleCountOfYAxis] * 2 + 4;
}

/*!
 * XY軸の枠領域の描画
 * @param first 対応する頂点が納めされている頂点バッファ上のoffset
 */
-(void) drawXYAxisVertex:(NSInteger)first {
  
  int pos = first / 6;
  
  glDrawArrays(GL_TRIANGLE_STRIP, pos, 4);
  pos += 4;
  
  for(int y = [self.source yAxisMin];
      y <= [self.source yAxisMax];
      y += [self.source yAxisScale]) {
    glDrawArrays(GL_LINES, pos , 2);
    pos += 2;
    
  }
  for(int x = [self.source xAxisMin];
      x <= [self.source xAxisMax];
      x += [self.source xAxisScale]) {
    glDrawArrays(GL_LINES, pos , 2);
    pos += 2;
  }
}

/**
 * YZ軸の枠の頂点バッファ生成
 * @return バッファの最後の位置
 */
-(NSInteger) addYZAxisVertex {
  CGFloat vertex[3];
  
  // 枠
  vertex[0] = [self maxXOfChart];
  vertex[1] = -[self maxYOfChart];
  vertex[2] = +[self maxZOfChart];
  [_vertexs putValues:vertex count:3];
  [_vertexs putValues:[self.frameBackgroundColor rgbArray] count:3];

  vertex[1] = -[self maxYOfChart];
  vertex[2] = -[self maxZOfChart];
  [_vertexs putValues:vertex count:3];
  [_vertexs putValues:[self.frameBackgroundColor rgbArray] count:3];

  vertex[1] = +[self maxYOfChart];
  vertex[2] = +[self maxZOfChart];
  [_vertexs putValues:vertex count:3];
  [_vertexs putValues:[self.frameBackgroundColor rgbArray] count:3];

  vertex[1] = +[self maxYOfChart];
  vertex[2] = -[self maxZOfChart];
  [_vertexs putValues:vertex count:3];
  [_vertexs putValues:[self.frameBackgroundColor rgbArray] count:3];

  // Y軸
  for(int y = [self.source yAxisMin];
      y <= [self.source yAxisMax];
      y += [self.source yAxisScale]) {
    vertex[0] = [self maxXOfChart];
    vertex[1] = [self yAxisToPoint:y];
    vertex[2] = [self maxZOfChart];
    [_vertexs putValues:vertex count:3];
    [_vertexs putValues:[self.frameLineColor rgbArray] count:3];

    vertex[2] = -[self maxZOfChart];
    [_vertexs putValues:vertex count:3];
    [_vertexs putValues:[self.frameLineColor rgbArray] count:3];
  }
  
  // Z軸
  for(int z = [self.source zAxisMin];
      z <= [self.source zAxisMax];
      z += [self.source zAxisScale]) {
    vertex[0] = [self maxXOfChart];
    vertex[1] = -[self maxYOfChart];
    vertex[2] = [self zAxisToPoint:z];
    [_vertexs putValues:vertex count:3];
    [_vertexs putValues:[self.frameLineColor rgbArray] count:3];
    
    vertex[1] = [self maxYOfChart];
    [_vertexs putValues:vertex count:3];
    [_vertexs putValues:[self.frameLineColor rgbArray] count:3];
  }
  return _vertexs.position;
}

/*!
 *
 * @return YZ軸の枠領域の頂点数
 */
-(NSInteger) countYZAxisVertex {
  // Y軸 * 2 + Z軸 * 2 + 4（枠の四角形）
  return [self scaleCountOfYAxis] * 2 + [self scaleCountOfZAxis] * 2 + 4;
}

/*!
 * YZ軸の枠領域の描画
 * @param first 対応する頂点が納めされている頂点バッファ上のoffset
 */
-(void) drawYZAxisVertex:(NSInteger)first {
  
  int pos = first / 6;
  
  glDrawArrays(GL_TRIANGLE_STRIP, pos, 4);
  pos += 4;
  
  for(int y = [self.source yAxisMin];
      y <= [self.source yAxisMax];
      y += [self.source yAxisScale]) {
    glDrawArrays(GL_LINES, pos , 2);
    pos += 2;
  }
  for(int z = [self.source zAxisMin];
      z <= [self.source zAxisMax];
      z += [self.source zAxisScale]) {
    glDrawArrays(GL_LINES, pos , 2);
    pos += 2;
  }
}


/*!
 * XZ軸の枠の頂点バッファ生成
 * @return バッファの最後の位置
 */
-(NSInteger) addXZAxisVertex {
  CGFloat vertex[3];
  
  // 枠
  vertex[0] = -[self maxXOfChart];
  vertex[1] = -[self maxYOfChart];
  vertex[2] = +[self maxZOfChart];
  [_vertexs putValues:vertex count:3];
  [_vertexs putValues:[self.bottomFrameBackgroundColor rgbArray] count:3];

  vertex[0] = -[self maxXOfChart];
  vertex[2] = -[self maxZOfChart];
  [_vertexs putValues:vertex count:3];
  [_vertexs putValues:[self.bottomFrameBackgroundColor rgbArray] count:3];

  vertex[0] = +[self maxXOfChart];
  vertex[2] = +[self maxZOfChart];
  [_vertexs putValues:vertex count:3];
  [_vertexs putValues:[self.bottomFrameBackgroundColor rgbArray] count:3];

  vertex[0] = +[self maxXOfChart];
  vertex[2] = -[self maxZOfChart];
  [_vertexs putValues:vertex count:3];
  [_vertexs putValues:[self.bottomFrameBackgroundColor rgbArray] count:3];
  
  // X軸
  for(int x = [self.source xAxisMin];
      x <= [self.source xAxisMax];
      x += [self.source xAxisScale]) {
    vertex[0] = [self  xAxisToPoint:x];
    vertex[1] = -[self maxYOfChart];
    vertex[2] = -[self maxZOfChart];
    [_vertexs putValues:vertex count:3];
    [_vertexs putValues:[self.frameLineColor rgbArray] count:3];

    vertex[2] = +[self maxZOfChart];
    [_vertexs putValues:vertex count:3];
    [_vertexs putValues:[self.frameLineColor rgbArray] count:3];
  }
  
  // Z軸
  for(int z = [self.source zAxisMin];
      z <= [self.source zAxisMax];
      z += [self.source zAxisScale]) {
    vertex[0] = -[self maxXOfChart];
    vertex[1] = -[self maxYOfChart];
    vertex[2] = [self zAxisToPoint:z];
    [_vertexs putValues:vertex count:3];
    [_vertexs putValues:[self.frameLineColor rgbArray] count:3];
    
    vertex[0] = [self maxXOfChart];
    [_vertexs putValues:vertex count:3];
    [_vertexs putValues:[self.frameLineColor rgbArray] count:3];
  }
  return _vertexs.position;
}

/*!
 * @return XZ軸の枠領域の頂点数
 */
-(NSInteger) countXZAxisVertex {
  // X軸 * 2 + Z軸 * 2 + 4（枠の四角形）
  return [self scaleCountOfXAxis] * 2 + [self scaleCountOfZAxis] * 2 + 4;
}

/**
 * XZ軸の枠領域の描画
 * @param gl
 * @param first 対応する頂点が納めされている頂点バッファ上のoffset
 */
-(void) drawXZAxisVertex:(NSInteger)first {
  
  int pos = first / 6;
  
  glDrawArrays(GL_TRIANGLE_STRIP, pos, 4);
  pos += 4;
  
  for(int x = [self.source xAxisMin];
      x <= [self.source xAxisMax];
      x += [self.source xAxisScale]) {
    glDrawArrays(GL_LINES, pos , 2);
    pos += 2;
    
  }
  for(int z = [self.source zAxisMin];
      z <= [self.source zAxisMax];
      z += [self.source zAxisScale]) {
    glDrawArrays(GL_LINES, pos , 2);
    pos += 2;
  }
}


#pragma mark Private Functions


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
 * Y軸の値を描画先のY座標へ変換
 * @param axis Y軸の値
 * @return Y座標
 */
- (CGFloat) yAxisToPoint:(NSInteger)axis {
  return (CGFloat)(axis - self.source.yAxisMin) / (self.source.yAxisMax - self.source.yAxisMin)
  * [self maxYOfChart] * 2 - [self maxYOfChart];
  
}

/*!
 * X軸の値を描画先のX座標へ変換
 * @param axis X軸の値
 * @return X座標
 */
- (CGFloat) xAxisToPoint:(NSInteger)axis {
  return (CGFloat)(axis - self.source.xAxisMin) / (self.source.xAxisMax - self.source.xAxisMin)
  * [self maxXOfChart] * 2 - [self maxXOfChart];
  
}

/*!
 * Z軸の値を描画先のX座標へ変換
 * @param axis Z軸の値
 * @return Z座標
 */
- (CGFloat) zAxisToPoint:(NSInteger)axis {
  return (CGFloat)(axis - self.source.zAxisMin) / (self.source.zAxisMax - self.source.zAxisMin)
  * [self maxZOfChart] * 2 - [self maxZOfChart];
  
}


/*!
 * @return chart描画領域の最大値-X
 */
- (CGFloat) maxXOfChart {
  CGFloat ratio = [self aspect];
  if(ratio > 1.0f) {   //　端末横向き
    return [self rarioToRenderX] * ratio;
  }
  else {               // 端末縦向き
    return [self rarioToRenderXHor] * ratio;
  }
}

/*!
 * @return chart描画領域の最大値-Y
 */
- (CGFloat) maxYOfChart {
  CGFloat ratio = [self aspect];
  if(ratio > 1.0f) {   //　端末横向き
    return [self rarioToRenderY] * ratio;
  }
  else {               // 端末縦向き
    return [self rarioToRenderYHor] * ratio;
  }
}

/*!
 * @return chart描画領域の最大値-Z
 */
- (CGFloat) maxZOfChart {
  CGFloat ratio = [self aspect];
  if(ratio > 1.0f) {   //　端末横向き
    return [self rarioToRenderZ] * ratio;
  }
  else {               // 端末縦向き
    return [self ratioToRenderZHor] * ratio;
  }
}

- (CGFloat) axisXTitle {
  return -[self maxXOfChart] - 0.15f;
}

- (CGFloat) axisYTitle {
  return -[self maxYOfChart] - 0.1f;
}

/*!
 * @return Z軸の目盛り数
 */
- (NSInteger) scaleCountOfZAxis {
  return self.source.zAxisMax - self.source.zAxisMin / self.source.zAxisScale + 1;
}

/*!
 * @return Z軸の目盛り数
 */
- (NSInteger) scaleCountOfZAxisForValue {
  return self.source.zAxisMax - self.source.zAxisMin / self.source.zAxisScaleForValue + 1;
}

/*!
 * @return X軸の目盛り数
 */
- (NSInteger) scaleCountOfXAxisForValue {
  return self.source.xAxisMax - self.source.xAxisMin / self.source.xAxisScaleForValue + 1;
}

/*!
 * @return X軸の目盛り数
 */
- (NSInteger) scaleCountOfXAxis {
  return self.source.xAxisMax - self.source.xAxisMin / self.source.xAxisScale + 1;
}

/*!
 * @return Y軸の目盛り数
 */
- (NSInteger) scaleCountOfYAxis {
  return self.source.yAxisMax - self.source.yAxisMin / self.source.yAxisScale + 1;
}

#pragma mark Private

- (void) setDefault {
  _rarioToRenderX = 0.65f;
  _rarioToRenderXHor = 0.8f;
  _rarioToRenderY = 0.80f;
  _rarioToRenderYHor = 0.75f;
  _rarioToRenderZ = 0.85f;
  _ratioToRenderZHor = 0.75f;
  
  _frameBackgroundColor = [[GLColor alloc]
                           initWithRed:170.0f/255.0f green:170.0f/255.0f blue:170.0f/255.0f];
  _bottomFrameBackgroundColor = [[GLColor alloc]
                                 initWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f];
  _frameLineColor = [[GLColor alloc]
                     initWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f];
  _valueLineColor = [[GLColor alloc] initWithRed:0.0f green:0.0f blue:0.0f];
  _textBackgroundColor = [[GLColor alloc] initWithRed:0.0f green:0.0f blue:0.0f];
  
  _scaleFontSize = 24;
  _titleFontSize = 26;
  _scaleFontColor = [UIColor whiteColor];
  _titleFontColor = [UIColor whiteColor];
  
  _rotateByAngelX = 0.3f;
  _rotateByAngelY = 0.3f;
}

@end
