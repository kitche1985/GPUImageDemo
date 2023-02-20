//
//  GPUImageFourMaskFilter.m
//  GPUImageDemo
//
//  Created by Lokie on 2023/2/20.
//

#import "GPUImageFourMaskFilter.h"

@implementation GPUImageFourMaskFilter
NSString *const kGPUImageFourMaskFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate; // 纹理1的坐标
 varying highp vec2 textureCoordinate2; // 纹理2的坐标
 varying highp vec2 textureCoordinate3;
 varying highp vec2 textureCoordinate4;
 varying highp vec2 textureCoordinate5;
 uniform sampler2D inputImageTexture;  // 原视频或者上一纹理
 uniform sampler2D inputImageTexture2; // mask1
 uniform sampler2D inputImageTexture3; // mask2
 uniform sampler2D inputImageTexture4; // mask3
 uniform sampler2D inputImageTexture5; // mask4
 void main()
 {
    highp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    gl_FragColor = vec4(textureColor.rgb, 1.0);
 }
);


- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageFourMaskFragmentShaderString]))
    {
        return nil;
    }
    
   // intensityUniform = [filterProgram uniformIndex:@"intensity"];
    //self.intensity = 0.75f;
    
    return self;
}
@end
