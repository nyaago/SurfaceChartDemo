//
//  ShaderUtils.m
//  TachoMeterDemo
//
//  Created by nyaago on 2013/10/18.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

#import "ShaderLoader.h"

@interface ShaderLoader()

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;

@end

@implementation ShaderLoader

- (id) init {
  return [super init];
}

- (GLuint)loadShaders:(NSString *)name
{
  NSString *vertShaderPathname, *fragShaderPathname;
  
  // Create shader program.
  _program = glCreateProgram();
  
  
  // Create and compile vertex shader.
  vertShaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:@"vsh"];
  if (![self compileShader:&_vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
    NSLog(@"Failed to compile vertex shader");
    return -1;
  }
  
  // Create and compile fragment shader.
  fragShaderPathname = [[NSBundle mainBundle] pathForResource:name ofType:@"fsh"];
  if (![self compileShader:&_fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
    NSLog(@"Failed to compile fragment shader");
    return -1;
  }
  
  // Attach vertex shader to program.
  glAttachShader(_program, _vertShader);
  
  // Attach fragment shader to program.
  glAttachShader(_program, _fragShader);
  
  return _program;
}

- (void) releaseShaders {
  if (_vertShader) {
    glDetachShader(_program, _vertShader);
    glDeleteShader(_vertShader);
  }
  if (_fragShader) {
    glDetachShader(_program, _fragShader);
    glDeleteShader(_fragShader);
  }
 
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

- (BOOL)linkProgram
{
  GLint status;
  glLinkProgram(_program);
  
#if defined(DEBUG)
  GLint logLength;
  glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0) {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetProgramInfoLog(_program, logLength, &logLength, log);
    NSLog(@"Program link log:\n%s", log);
    free(log);
  }
#endif
  
  glGetProgramiv(_program, GL_LINK_STATUS, &status);
  if (status == 0) {
    if (_vertShader) {
      glDeleteShader(_vertShader);
      _vertShader = 0;
    }
    if (_fragShader) {
      glDeleteShader(_fragShader);
      _fragShader = 0;
    }
    if (_program) {
      glDeleteProgram(_program);
      _program = 0;
    }

    return NO;
  }
  
  return YES;
}


- (BOOL)validateProgram
{
  GLint logLength, status;
  
  glValidateProgram(_program);
  glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &logLength);
  if (logLength > 0) {
    GLchar *log = (GLchar *)malloc(logLength);
    glGetProgramInfoLog(_program, logLength, &logLength, log);
    NSLog(@"Program validate log:\n%s", log);
    free(log);
  }
  
  glGetProgramiv(_program, GL_VALIDATE_STATUS, &status);
  if (status == 0) {
    return NO;
  }
  
  return YES;
}


@end
