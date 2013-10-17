//
//  Shader.fsh
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/15.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

precision mediump float;
varying  vec2 texcoordVarying;
uniform sampler2D texture;

void main()
{
//  gl_FragColor = colorVarying;
  gl_FragColor = texture2D(texture, texcoordVarying);
//  gl_FragColor = vec4(0.5, 0.5, 0.7, 0.3);
//  gl_FragColor = colorVarying;

}