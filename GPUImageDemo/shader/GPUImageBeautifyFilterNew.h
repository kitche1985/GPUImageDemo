//
//  GPUImageBeautifyFilter.h
//  BeautifyFaceDemo
//
//  Created by guikz on 16/4/28.
//  Copyright © 2016年 guikz. All rights reserved.
//

#import "GPUImageFramework.h"

@class GPUImageCombinationNewFilter;

@interface GPUImageBeautifyFilterNew : GPUImageFilterGroup {
    GPUImageBilateralFilter *bilateralFilter;
    GPUImageCannyEdgeDetectionFilter *cannyEdgeFilter;
    GPUImageCombinationNewFilter *combinationFilter;
    GPUImageHSBFilter *hsbFilter;
}

@property (nonatomic,assign) CGFloat mopiAlpha;
@end
