//
//  GPUImageMTBeatufyFIlter.m
//  FaceAligmentSdk
//
//  Created by lotus on 2018/2/27.
//  Copyright © 2018年 Jacky. All rights reserved.
//

#import "GPUImageMTBeatufyFIlter.h"


#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageMTLookupFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2; // TODO: This is not used
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2; // lookup texture

// const highp vec3 CbC = vec3(0.5,-0.4187,-0.0813);
// const highp vec3 CrC = vec3(-0.1687,-0.3313,0.5);
 uniform lowp float intensity;

 highp vec3 RGB2Lab(in highp vec3 rgb){
    highp float R = rgb.x;
    highp float G = rgb.y;
    highp float B = rgb.z;
//    // threshold
    highp float T = 0.008856;
//
    highp float X = R * 0.412453 + G * 0.357580 + B * 0.180423;
    highp float Y = R * 0.212671 + G * 0.715160 + B * 0.072169;
    highp float Z = R * 0.019334 + G * 0.119193 + B * 0.950227;
//
//     // Normalize for D65 white point
    X = X / 0.950456;
    Y = Y;
    Z = Z / 1.088754;
//
    //bool xt = false;
//    bool YT;
//    bool ZT;
//    XT = false; YT=false; ZT=false;
//    if(X > T) XT = true;
//    if(Y > T) YT = true;
//    if(Z > T) ZT = true;
//
    highp float Y3 = pow(Y,1.0/3.0);
    highp float fX;
    highp float fY;
    highp float fZ;
    if(X > T) {
        fX = pow(X, 1.0/3.0);
    } else {
        fX = 7.787 * X + 16.0/116.0;
    }
    if(Y > T) {
        fY = Y3;
    } else {
        fY = 7.787 * Y + 16.0/116.0 ;
    }
    
    if(Z > T) {
        fZ = pow(Z,1.0/3.0);
    } else {
        fZ = 7.787 * Z + 16.0/116.0;
    }
    
    
//    if(XT){ fX = pow(X, 1.0/3.0);} else{ fX = 7.787 * X + 16.0/116.0; }
//    if(YT){ fY = Y3; } else{ fY = 7.787 * Y + 16.0/116.0 ; }
//    if(ZT){ fZ = pow(Z,1.0/3.0); } else{ fZ = 7.787 * Z + 16.0/116.0; }
//
    highp float L;
    if(Y > T) {
        L = (116.0 * Y3) - 16.0;
    } else {
        L = 903.3 * Y;
    }
    highp float a = 500.0 * ( fX - fY );
    highp float b = 200.0 * ( fY - fZ );

    return vec3(L,a,b);
 }
 
 highp float skinMast(in highp vec4 color)
 {
    highp vec3 lab = RGB2Lab(color.rgb);
    highp float a = smoothstep(0.45, 0.55, lab.g);
    highp float b = smoothstep(0.46, 0.54, lab.b);
    highp float c = 1.0 - smoothstep(0.9, 1.0, length(lab.gb));
    highp float d = 1.0 - smoothstep(0.98, 1.02, lab.r);
    return min(min(min(a, b), c), d);
//    return 1.0;
 }
 
 highp float isSkin(in highp vec4 color) {
    highp vec3 lab = RGB2Lab(color.rgb);
    highp float l = lab.r;
    highp float a = lab.g;
    highp float b = lab.b;
    
    
    if(a < 0.5 || b < 0.5) {
        return 0.0;
    } else {
        highp float a1 = a*a;
        highp float b1 = b*b;
        highp float c = sqrt(a1 + b1);
//        if(c >=0.9) {
//            return 0.0;
//        } else {
//            if(l < 1.0) {
//                return 1.0;
//            } else {
//                return 0.0;
//            }
////            return 1.0;
//        }
//        if(c <= 0.9) {
//            return 1.0;
//        } else {
//            return 0.0;
//        }
//        if(l < 1.0) {
//            return 1.0;
//        } else {
//            return 0.0;
//        }
        return 1.0;
        
    }
    
 }
 
 
 void main()
 {
//    highp vec3 textureColor2 = texture2D(inputImageTexture, textureCoordinate).rgb;
//    highp float x0 = textureColor2.r;
//    highp float x1 = textureColor2.g;
//    highp float x2 = textureColor2.b;
//    highp float x3 = dot(CbC, textureColor2);
//    highp float x4 = dot(CrC, textureColor2);
//    highp float pos = 0.0;
//    pos = float(x4 <=-0.0615369 ? (x3 <=0.0678488 ? (x3 <=0.0352417 ? 0 : (x2 <=0.686631 ? 0 : 1)) : (x3 <=0.185183 ? 1 : 0)) : (x4 <=-0.029597 ? (x3 <=0.0434402 ? 0 : (x1 <=0.168271 ? 0 : 1)) : 0));
//
    highp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    highp float blueColor = textureColor.b * 15.0;
    highp vec2 quad1;
    //     quad1.y = max(min(4.0,floor(floor(blueColor) / 4.0)),0.0);
    //     quad1.x = max(min(4.0,floor(blueColor) - (quad1.y * 4.0)),0.0);
    quad1.y = floor(floor(blueColor) / 4.0);
    quad1.x = floor(blueColor) - (quad1.y * 4.0);

    highp vec2 quad2;
    //     quad2.y = max(min(floor(ceil(blueColor) / 4.0),4.0),0.0);
    //     quad2.x = max(min(ceil(blueColor) - (quad2.y * 4.0),4.0),0.0);
    quad2.y = floor(ceil(blueColor) / 4.0);
    quad2.x = ceil(blueColor) - (quad2.y * 4.0);

    highp vec2 texPos1;
    texPos1.x = (quad1.x * 0.25) + 0.5/64.0 + ((0.25 - 1.0/64.0) * textureColor.r);
    texPos1.y = (quad1.y * 0.25) + 0.5/64.0 + ((0.25 - 1.0/64.0) * textureColor.g);

    highp vec2 texPos2;
    texPos2.x = (quad2.x * 0.25) + 0.5/64.0 + ((0.25 - 1.0/64.0) * textureColor.r);
    texPos2.y = (quad2.y * 0.25) + 0.5/64.0 + ((0.25 - 1.0/64.0) * textureColor.g);

    lowp vec4 newColor1 = texture2D(inputImageTexture2, texPos1);
    lowp vec4 newColor2 = texture2D(inputImageTexture2, texPos2);

    lowp vec4 newColor = mix(newColor1, newColor2, fract(blueColor));
    textureColor = mix(textureColor, newColor, intensity);
    //     gl_FragColor = mix(textureColor, vec4(newColor.rgb, textureColor.w), intensity);
    //     gl_FragColor = textureColor;

    gl_FragColor = vec4(textureColor.rgb, 1.0);
    
    
    

    
    
//    if(pos == 0.0) {
//        gl_FragColor = vec4(textureColor.rgb, 1.0);
//    } else {
//
//    }
    
 }
 );
#else
#endif

@implementation GPUImageMTBeatufyFIlter

@synthesize intensity = _intensity;

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageMTLookupFragmentShaderString]))
    {
        return nil;
    }
    
    intensityUniform = [filterProgram uniformIndex:@"intensity"];
    self.intensity = 0.75f;
    
    return self;
}

#pragma mark -
#pragma mark Accessors

- (void)setIntensity:(CGFloat)intensity
{
    _intensity = intensity;
    
    [self setFloat:_intensity forUniform:intensityUniform program:filterProgram];
}

@end
