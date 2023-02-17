//
//  GPUImageMoPi1Filter.h
//  GPUImage
//
//  Created by lotus on 2020/5/18.
//  Copyright © 2020 Brad Larson. All rights reserved.
//

 
#import "GPUImage.h"
#import "GPUImageFaceTexFilter.h"

@interface GPUImageMoPi1Filter : GPUImageTwoInputFilter{
}

//mask 图片是镜像的，切记切记
@property (nonatomic, strong) GPUImageFaceTexFilter  * ftFilter;

/** 磨皮程度 */
@property (nonatomic, assign) CGFloat blurAlpha;

/** 消除法令纹程度 */
@property (nonatomic, assign) CGFloat flwAlpha;

/** 锐利强度 */
@property (nonatomic, assign) CGFloat sharpen;
 

-(void)removeTest;

@end
