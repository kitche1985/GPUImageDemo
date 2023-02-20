//
//  ViewController.m
//  GPUImageDemo
//
//  Created by sun on 2023/2/13.
//

#import "ViewController.h"
#import "CollectionTagCell.h"

#import "GPUImageBeautifyFilterNew.h"
#import "GPUImageMTBeatufyFIlter.h"
#import "GPUImageFourMaskFilter.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>{
    CGRect oldFrame;
    CGRect largeFrame;
    
}
@property(nonatomic, strong)UIImage * lutImg;
@property (strong, nonatomic)GPUImagePicture * mopilutPic;
//美白
@property (strong, nonatomic)GPUImageMTBeatufyFIlter * mtbFilter;
//磨皮
@property (strong, nonatomic) GPUImageBeautifyFilterNew *moPiFileterNew;

@property (strong, nonatomic) GPUImageTransformFilter * fixOrientationFilter;


@property (strong, nonatomic) GPUImageView *filterView;

@property (strong, nonatomic) UICollectionView *collectionView;

//滑竿
@property (strong, nonatomic) UISlider *slider;


//美白等点击文本数据源
@property (strong, nonatomic) NSArray<NSString *> * titles;
//存放 具体数据的 float value
@property (strong, nonatomic) NSMutableArray<NSNumber *> *values;
//镜头切换按钮
@property (strong, nonatomic) UIButton *button;

@property (assign, nonatomic) BOOL isFront;

//当前选中项
@property (assign, nonatomic) NSInteger selectIndex;

@property(nonatomic, strong)UIImage * mask1Img;
@property(nonatomic, strong)UIImage * mask2Img;

@property (strong, nonatomic)GPUImagePicture * mask1;

@property (strong, nonatomic)GPUImagePicture * mask2;

@property (strong, nonatomic)GPUImagePicture * mask3;

@property (strong, nonatomic)GPUImagePicture * mask4;
@end

@implementation ViewController

//-(GPUImageFilter *)mopiAndWhite{
//
//    //    GPUImageFilterGroup * defaultBeautifyFilter = [[GPUImageFilterGroup alloc] init];
//
//    GPUImageMTBeatufyFIlter * whiteFilter = [[GPUImageMTBeatufyFIlter alloc] init];
//
//    //self.mopilutPic = [[GPUImagePicture alloc] initWithImage:self.lutImg];
//    //_whiteAlpha = 0.75;
//
//    return whiteFilter;
//
//}

-(GPUImageFilter*)fixOrientation{
    
    self.fixOrientationFilter = [[GPUImageTransformFilter alloc] init];
    return (GPUImageFilter*)self.fixOrientationFilter;
}

// 初始化美白
-(GPUImageFilter *)mopiAndWhite{

    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"maccoLab" ofType:@"bundle"]];
    NSString *lutImgStr = [bundle pathForResource:@"lookUp" ofType:@"png"];
    self.lutImg = [UIImage imageNamed:lutImgStr];
    
    GPUImageMTBeatufyFIlter * whiteFilter = [[GPUImageMTBeatufyFIlter alloc] init];

    self.mopilutPic = [[GPUImagePicture alloc] initWithImage:self.lutImg];

    whiteFilter.intensity = self.values[0].floatValue;
    self.mtbFilter = whiteFilter;
    
    [self.mopilutPic addTarget:whiteFilter atTextureLocation:1];
    
    [self.mopilutPic processImage];
    
    return (GPUImageFilter*)whiteFilter;
}

-(GPUImageFilter*)loadFourMaskEample:(GPUImageFilter*) latestTarget {
    
    GPUImageFourMaskFilter * fourMaskFilter = [[GPUImageFourMaskFilter alloc] init];
    // 上一个Filter处理的结果，对应uniform sampler2D inputImageTexture
    [latestTarget addTarget:fourMaskFilter atTextureLocation:0];
    
    // 从maccoLab这个文件夹下加载lookup.png image的纹理，对应 uniform sampler2D inputImageTexture2，以此类推
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"maccoLab" ofType:@"bundle"]];
    NSString *mask1Path = [bundle pathForResource:@"lookUp" ofType:@"png"];
    
    // 架子啊
    self.mask1Img = [UIImage imageNamed:mask1Path];
    self.mask1 = [[GPUImagePicture alloc] initWithImage:self.mask1Img];
    [self.mask1 addTarget:fourMaskFilter atTextureLocation:1];
    [self.mask1 processImage];
    
    NSString *mask2Path = [bundle pathForResource:@"lookUp" ofType:@"png"];
    self.mask2Img= [UIImage imageNamed:mask2Path];
    self.mask2 = [[GPUImagePicture alloc] initWithImage:self.mask2Img];
    [self.mask2 addTarget:fourMaskFilter atTextureLocation:2];
    [self.mask2 processImage];
    
    NSString *mask3Path = [bundle pathForResource:@"lookUp" ofType:@"png"];
    UIImage *maskImg3 = [UIImage imageNamed:mask3Path];
    self.mask3 = [[GPUImagePicture alloc] initWithImage:maskImg3];
    [self.mask3 addTarget:fourMaskFilter atTextureLocation:3];
    
    NSString *mask4Path = [bundle pathForResource:@"lookUp" ofType:@"png"];
    UIImage *maskImg4 = [UIImage imageNamed:mask4Path];
    self.mask4 = [[GPUImagePicture alloc] initWithImage:maskImg4];
    [self.mask4 addTarget:fourMaskFilter atTextureLocation:4];
    
    
    return (GPUImageFilter*)fourMaskFilter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isFront = true;
    self.titles = @[@"美白", @"磨皮", @"法令纹",@"黑眼圈", @"祛痘"];
    self.values = [NSMutableArray arrayWithObjects:@(0.85),@(0.6),@(0.0),@(0.0),@(0.0), nil];
    

    
    GPUImageFilterGroup * filter = [[GPUImageFilterGroup alloc] init];
    GPUImageFilter * pLastFilter;
    
    //fix orientation
    GPUImageFilter * orientationFilter = [self fixOrientation];
    pLastFilter = orientationFilter;
    
  

    
//     磨皮
    self.moPiFileterNew = [[GPUImageBeautifyFilterNew alloc] init];
    [self.moPiFileterNew setMopiAlpha:self.values[1].floatValue];
    [pLastFilter addTarget:self.moPiFileterNew];
    pLastFilter =(GPUImageFilter *)self.moPiFileterNew;
//    pLastFilter = moPiFileterNew;
    
    
    // 美白
    GPUImageFilter * defaultBeautifyFilter = [self mopiAndWhite];
    [pLastFilter addTarget:defaultBeautifyFilter];
    pLastFilter = defaultBeautifyFilter;
    
    GPUImageFilter* fourMaskFileter = [self loadFourMaskEample:defaultBeautifyFilter];
    [pLastFilter addTarget:fourMaskFileter];
    pLastFilter = fourMaskFileter;

    filter.initialFilters = [[NSArray alloc] initWithObjects:orientationFilter, nil];
    filter.terminalFilter = pLastFilter;
    
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    
    
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = NO;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
   
    [videoCamera addTarget:filter];
//    [videoCamera addTarget:self.fixOrientationFilter];
      
//    GPUImageFilter * defaultBeautifyFilter = nil;
//    if(eftList == nil){
//    defaultBeautifyFilter = [self mopiAndWhite];
    
    //[videoCamera addTarget:defaultBeautifyFilter];
    
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    self.filterView = filterView;
        
    [filter addTarget:filterView];
    

    [videoCamera startCameraCapture];
    
    double delayInSeconds = 0.1;
    dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
        
        videoCamera.audioEncodingTarget = nil;
        NSLog(@"Movie completed");
        
    });
    
    [self updateOrientation:true];
    [self.view addSubview:filterView];
    
    [self.view addSubview:self.button];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.slider];
    
    //设置滑竿为美白值
    self.slider.value = self.values[0].floatValue;
    
    oldFrame = self.view.frame;
    largeFrame = CGRectMake(0 - CGRectGetWidth(self.view.frame), 0 - CGRectGetHeight(self.view.frame), 3 * oldFrame.size.width, 3 * oldFrame.size.height);  //3倍放大限制
    
    // 缩放手势
   UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
   [filterView addGestureRecognizer:pinchGesture];
   
   // 移动手势
   UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
   [filterView addGestureRecognizer:panGesture];
}






- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.titles.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionTagCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellID" forIndexPath:indexPath];
    cell.nameLabel.text = self.titles[indexPath.item];
    cell.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.4];
    if (self.selectIndex == indexPath.item) {
        cell.nameLabel.textColor = UIColor.redColor;
    }else {
        cell.nameLabel.textColor = UIColor.blackColor;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectIndex = indexPath.item;
    [collectionView reloadData];
    self.slider.value = self.values[self.selectIndex].floatValue;
    
}

-(void)updateOrientation:(BOOL)isFront{
    self.fixOrientationFilter.affineTransform =
    CGAffineTransformMakeScale(isFront ? -1 : 1 , 1);
}

- (void)updateSliderValue:(id)sender
{
    self.values[self.selectIndex] = [NSNumber numberWithFloat: [(UISlider *)sender value]];
    switch (self.selectIndex) {
        case 0://美白
            self.mtbFilter.intensity = self.values[self.selectIndex].floatValue;
            break;
        case  1:
            [self.moPiFileterNew setMopiAlpha:self.values[self.selectIndex].floatValue];
            break;
        default:
            //别的实现
            break;
    }
    //[(GPUImageSepiaFilter *)filter setIntensity:[(UISlider *)sender value]];
}


- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.estimatedItemSize = CGSizeMake(40, 70);
        flowLayout.minimumLineSpacing = 10;
//        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 60, CGRectGetWidth(self.view.frame), 60) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.4];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerNib:[UINib nibWithNibName:@"CollectionTagCell" bundle:nil] forCellWithReuseIdentifier:@"CellID"];
    }
    return _collectionView;
}

-(UIButton *)button {
    if(!_button) {
        _button = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 50, 20, 45, 45)];
        [_button setTitle:@"切换" forState:UIControlStateNormal];
        [_button setBackgroundColor:[UIColor.blackColor colorWithAlphaComponent: 0.5]];
        [_button addTarget:self action:@selector(onChangeWindow) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _button;
}

-(void)onChangeWindow {
    self.isFront = !self.isFront;
    
    [videoCamera rotateCamera];
    [self updateOrientation:self.isFront];
}


-(UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(25, CGRectGetMinY(self.collectionView.frame) - 50, CGRectGetWidth(self.view.frame) - 50, 50)];
        _slider.minimumValue = 0.0;
        _slider.maximumValue = 1.0;
        [_slider addTarget:self action:@selector(updateSliderValue:) forControlEvents:UIControlEventValueChanged];
    }
    return  _slider;
}


// 处理缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGesture
{
    
    UIView *view = pinchGesture.view;
    
    if (pinchGesture.state == UIGestureRecognizerStateBegan || pinchGesture.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGesture.scale, pinchGesture.scale);
        if (self.filterView.frame.size.width <= oldFrame.size.width ) {
            [UIView beginAnimations:nil context:nil]; // 开始动画
            [UIView setAnimationDuration:0.5f]; // 动画时长
            /**
             *  固定一倍
             */
            view.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
            view.center = self.view.center;
            [UIView commitAnimations]; // 提交动画
        }
        if (self.filterView.frame.size.width > 3 * oldFrame.size.width) {
            [UIView beginAnimations:nil context:nil]; // 开始动画
            [UIView setAnimationDuration:0.5f]; // 动画时长
            /**
             *  固定三倍
             */
            view.transform = CGAffineTransformMake(3, 0, 0, 3, 0, 0);
            [UIView commitAnimations]; // 提交动画
        }

        pinchGesture.scale = 1;
    }
}

#pragma mark 处理拖拉
-(void)panView:(UIPanGestureRecognizer *)panGesture
{
    UIView *view = panGesture.view;
    if (panGesture.state == UIGestureRecognizerStateBegan || panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGesture setTranslation:CGPointZero inView:view.superview];
    }
}
@end
