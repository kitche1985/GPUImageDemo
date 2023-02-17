//
//  GPUImageMoPi1Filter.m
//  GPUImage
//
//  Created by lotus on 2020/5/18.
//  Copyright © 2020 Brad Larson. All rights reserved.
//

#import "GPUImageMoPi1Filter.h"

@interface GPUImageMoPi1Filter(){
    GPUImagePicture * f_h_img;
    int showArea;
}
 
@end
  
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kMoPi1FragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 uniform sampler2D inputImageTexture; // src
 uniform sampler2D inputImageTexture2; // src1
 
 uniform highp vec2 singleStepOffset;
 
 uniform lowp float blurAlpha; //0.59
 uniform lowp float  flwAlpha;
 uniform highp float sharpen;//0.35
 uniform highp int nType;//
// uniform highp int showArea;//0 1
 
 highp vec2 blurCoordinates[24];
 
 void main(){
     
     lowp vec4 fhMask = texture2D(inputImageTexture2, textureCoordinate2);
     highp vec3 iColor = texture2D(inputImageTexture, textureCoordinate).rgb;
     blurCoordinates[0] = textureCoordinate.xy + singleStepOffset * vec2(0.0, -10.0);
     blurCoordinates[1] = textureCoordinate.xy + singleStepOffset * vec2(0.0, 10.0);
     blurCoordinates[2] = textureCoordinate.xy + singleStepOffset * vec2(-10.0, 0.0);
     blurCoordinates[3] = textureCoordinate.xy + singleStepOffset * vec2(10.0, 0.0);
     blurCoordinates[4] = textureCoordinate.xy + singleStepOffset * vec2(5.0, -8.0);
     blurCoordinates[5] = textureCoordinate.xy + singleStepOffset * vec2(5.0, 8.0);
     blurCoordinates[6] = textureCoordinate.xy + singleStepOffset * vec2(-5.0, 8.0);
     blurCoordinates[7] = textureCoordinate.xy + singleStepOffset * vec2(-5.0, -8.0);
     blurCoordinates[8] = textureCoordinate.xy + singleStepOffset * vec2(8.0, -5.0);
     blurCoordinates[9] = textureCoordinate.xy + singleStepOffset * vec2(8.0, 5.0);
     blurCoordinates[10] = textureCoordinate.xy + singleStepOffset * vec2(-8.0, 5.0);
     blurCoordinates[11] = textureCoordinate.xy + singleStepOffset * vec2(-8.0, -5.0);
     blurCoordinates[12] = textureCoordinate.xy + singleStepOffset * vec2(0.0, -6.0);
     blurCoordinates[13] = textureCoordinate.xy + singleStepOffset * vec2(0.0, 6.0);
     blurCoordinates[14] = textureCoordinate.xy + singleStepOffset * vec2(6.0, 0.0);
     blurCoordinates[15] = textureCoordinate.xy + singleStepOffset * vec2(-6.0, 0.0);
     blurCoordinates[16] = textureCoordinate.xy + singleStepOffset * vec2(-4.0, -4.0);
     blurCoordinates[17] = textureCoordinate.xy + singleStepOffset * vec2(-4.0, 4.0);
     blurCoordinates[18] = textureCoordinate.xy + singleStepOffset * vec2(4.0, -4.0);
     blurCoordinates[19] = textureCoordinate.xy + singleStepOffset * vec2(4.0, 4.0);
     blurCoordinates[20] = textureCoordinate.xy + singleStepOffset * vec2(-2.0, -2.0);
     blurCoordinates[21] = textureCoordinate.xy + singleStepOffset * vec2(-2.0, 2.0);
     blurCoordinates[22] = textureCoordinate.xy + singleStepOffset * vec2(2.0, -2.0);
     blurCoordinates[23] = textureCoordinate.xy + singleStepOffset * vec2(2.0, 2.0);
     
     highp vec4 sampleColor = texture2D(inputImageTexture, textureCoordinate) * 22.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[0]);
     sampleColor += texture2D(inputImageTexture, blurCoordinates[1]);
     sampleColor += texture2D(inputImageTexture, blurCoordinates[2]);
     sampleColor += texture2D(inputImageTexture, blurCoordinates[3]);
     sampleColor += texture2D(inputImageTexture, blurCoordinates[4]);
     sampleColor += texture2D(inputImageTexture, blurCoordinates[5]);
     sampleColor += texture2D(inputImageTexture, blurCoordinates[6]);
     sampleColor += texture2D(inputImageTexture, blurCoordinates[7]);
     sampleColor += texture2D(inputImageTexture, blurCoordinates[8]);
     sampleColor += texture2D(inputImageTexture, blurCoordinates[9]);
     sampleColor += texture2D(inputImageTexture, blurCoordinates[10]);
     sampleColor += texture2D(inputImageTexture, blurCoordinates[11]);
     sampleColor += texture2D(inputImageTexture, blurCoordinates[12]) * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[13]) * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[14]) * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[15]) * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[16]) * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[17]) * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[18]) * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[19]) * 2.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[20]) * 3.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[21]) * 3.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[22]) * 3.0;
     sampleColor += texture2D(inputImageTexture, blurCoordinates[23]) * 3.0;
     
     highp vec3 meanColor = sampleColor.rgb / 62.0;
     
     lowp vec3 diffColor = (iColor - meanColor) * 7.07;
//    lowp vec3 diffColor = (iColor - meanColor) * 6.06;
     lowp vec3 varColor = min(diffColor * diffColor, 1.0);
     
     lowp float theta = 0.1;
     mediump float p = clamp((min(iColor.r, meanColor.r - 0.1) - 0.2) * 4.0, 0.0, 1.0);
     mediump float meanVar = (varColor.r + varColor.g + varColor.b) / 3.0;
     mediump float kMin;
     lowp vec3 resultColor;
      
    kMin = (1.0 - meanVar / (meanVar + theta)) * p * blurAlpha * pow(max(fhMask.r - 0.25, 0.0), 0.5);
    resultColor = mix(iColor.rgb, meanColor.rgb, kMin);
    
    lowp float curFlwAlpha = flwAlpha * pow(fhMask.g, 0.65);
    
    if(flwAlpha > 0.0 && fhMask.g > 0.0){
       lowp vec3 tempC = mix(iColor.rgb,  meanColor.rgb, (1.0 - meanVar / (meanVar + theta)) * p * (3.0));
       resultColor = tempC * curFlwAlpha + resultColor * (1.0 - curFlwAlpha);
    }
     
     mediump float sum = 0.25*iColor.g;
     sum += 0.125 *texture2D(inputImageTexture,textureCoordinate.xy + singleStepOffset * vec2(1.0, .0)).g;
     sum += 0.125 *texture2D(inputImageTexture,textureCoordinate.xy + singleStepOffset * vec2(-1.0, .0)).g;
     sum += 0.125 *texture2D(inputImageTexture,textureCoordinate.xy + singleStepOffset * vec2(.0, 1.0)).g;
     sum += 0.125 *texture2D(inputImageTexture,textureCoordinate.xy + singleStepOffset * vec2(.0, -1.0)).g;
     sum += 0.0625*texture2D(inputImageTexture,textureCoordinate.xy + singleStepOffset * vec2(1.0, 1.0)).g;
     sum += 0.0625*texture2D(inputImageTexture,textureCoordinate.xy + singleStepOffset * vec2(-1.0, -1.0)).g;
     sum += 0.0625*texture2D(inputImageTexture,textureCoordinate.xy + singleStepOffset * vec2(1.0, -1.0)).g;
     sum += 0.0625*texture2D(inputImageTexture,textureCoordinate.xy + singleStepOffset * vec2(-1.0, 1.0)).g;

     mediump float hPass = iColor.g-sum+0.5;
     mediump float flag = step(0.5, hPass);
     highp vec3 color = mix(max(vec3(0.0), (2.0*hPass + resultColor - 1.0)), min(vec3(1.0), (resultColor + 2.0*hPass - 1.0)), flag);
     
     color = mix(resultColor.rgb, color.rgb, sharpen * (1.0 - curFlwAlpha));
//    color = mix(iColor.rgb, color.rgb, sharpen);
    
     gl_FragColor = vec4(color,1.0);
     
 }
 
 );
#else
 
#endif

@implementation GPUImageMoPi1Filter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kMoPi1FragmentShaderString])) {
        return nil;
    }
    
    //f_h_img
    
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"maccoLab" ofType:@"bundle"]];
    NSString *lutImg = [bundle pathForResource:@"f_h_mask" ofType:@"png"];
//    NSString * url = @"https://v3f.imacco.com/makeup/mkjson/f_h_mask.png";
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
//    UIImage * mpI = [UIImage imageWithData:data];
    UIImage * mpI = [UIImage imageNamed:lutImg];
//    UIImage * mpII = [UIImage imageWithCGImage:mpI.CGImage scale:mpI.scale orientation:UIImageOrientationLeftMirrored];
//
    f_h_img = [[GPUImagePicture alloc] initWithImage:mpI];
    
    _ftFilter = [[GPUImageFaceTexFilter alloc] init];
    [f_h_img addTarget:_ftFilter];
    
    [_ftFilter addTarget:self atTextureLocation:1];
    
    self.blurAlpha = 0.1;
    self.sharpen = 0.7;
    self.flwAlpha = 1;
//    showArea = 0;
    
    [f_h_img processImage];
    mpI = nil;
    
    return self;
}

-(void)dealloc{
    [f_h_img removeAllTargets];
    f_h_img = nil;
    
//    NSLog(@"remove GPUImageMoPi1Filter");
    
}

-(void)removeTest{
    [_ftFilter removeAllTargets];
    [f_h_img removeAllTargets];
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    [super setInputSize:newSize atIndex:textureIndex];
     
    if(textureIndex == 0){
//        float fscale = newSize.height / 480.0;
//        float fscale = 1.35;
        float fscale = 1.95;
        CGPoint offset = CGPointMake(fscale / inputTextureSize.width, fscale / inputTextureSize.height);
        [self setPoint:offset forUniformName:@"singleStepOffset"];
    }
}
 
-(void)setSharpen:(CGFloat)sharpen{
    _sharpen = sharpen;
    [self setFloat:sharpen forUniformName:@"sharpen"];
}

-(void)setBlurAlpha:(CGFloat)blurAlpha{
    _blurAlpha = blurAlpha * 2;
//    NSLog(@"_blurAlpha %f", _blurAlpha);
    [self setFloat:_blurAlpha forUniformName:@"blurAlpha"];
}

-(void)setFlwAlpha:(CGFloat)flwAlpha{
    _flwAlpha = flwAlpha * 1.0;
    [self setFloat:_flwAlpha forUniformName:@"flwAlpha"];
}



@end
