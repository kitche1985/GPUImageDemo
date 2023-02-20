//
//  GPUImageFiveInputFilter.h
//  filtertest
//
//  Created by chenkai on 8/16/14.
//  Copyright (c) 2014 Chenkai. All rights reserved.
//

//extern NSString *const kGPUImageFiveInputTextureVertexShaderString;

#import "GPUImageFourInputFilter.h"

@interface GPUImageFiveInputFilter : GPUImageFourInputFilter
{
    GPUImageFramebuffer *fifthInputFramebuffer;
    
    GLint filterFifthTextureCoordinateAttribute;
    GLint filterInputTextureUniform5;
    GPUImageRotationMode inputRotation5;
    GLuint filterSourceTexture5;
    CMTime fifthFrameTime;
    
    BOOL hasSetFourthTexture, hasReceivedFifthFrame, fifthFrameWasVideo;
    BOOL fifthFrameCheckDisabled;
}
- (void)disableFifthFrameCheck;



@end
