//
//  Shader.fsh
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/15.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//
precision mediump float;

varying lowp vec4 colorVarying;
varying  vec2 texcoordVarying;
uniform sampler2D texture;

void main()
{
  lowp vec4  color= texture2D( texture, texcoordVarying );
  if(colorVarying.r > 0.0 || colorVarying.g > 0.0 || colorVarying.b > 0.0) {
   gl_FragColor = colorVarying ;
  }
  else {
    gl_FragColor = color;
  }
}
