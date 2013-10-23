//
//  Shader.vsh
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/15.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;

attribute vec2 texcoord;
varying vec2 texcoordVarying;
uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{
  //  vec3 eyeNormal = normalize(normalMatrix * normal);
  //  vec3 lightPosition = vec3(0.0, 0.0, 1.0);
//  vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0);
  //  float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
  texcoordVarying = texcoord;
  gl_Position = modelViewProjectionMatrix * position;
}
