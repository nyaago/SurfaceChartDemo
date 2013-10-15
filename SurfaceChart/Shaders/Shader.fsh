//
//  Shader.fsh
//  SurfaceChartDemo
//
//  Created by nyaago on 2013/10/15.
//  Copyright (c) 2013年 nyaago. All rights reserved.
//

varying lowp vec4 colorVarying;
uniform sampler2D texture;
void main()
{
  gl_FragColor = colorVarying;
//  if(texcoordVarying) {
//    gl_FragColor = colorVarying + texture2D(texture, texcoordVarying);
//  }
}
