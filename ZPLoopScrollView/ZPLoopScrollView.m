
//  ZPScrollViewLoop.m
//  RunLoopScrollView
//
//  Created by zp on 16/5/31.
//  Copyright © 2016年 iLogiE MAC. All rights reserved.
//

#define kScrollViewW CGRectGetWidth(self.frame)
#define kScrollViewH CGRectGetHeight(self.frame)
#define kCount 3


#import "ZPLoopScrollView.h"
#import "UIKit+AFNetworking.h"
@interface ZPLoopScrollView ()<UIScrollViewDelegate>
{
    NSUInteger imageCount;
    NSUInteger currentIndex;
    NSTimer     *_timer;
    BOOL        isAnimation ;
    CGFloat     radio;
}
@property (nonatomic,strong)UIScrollView  *scrollView;
@property (nonatomic,strong)UIPageControl *pageControl;
@property (nonatomic,strong)UIImageView  *leftImageView ;
@property (nonatomic,strong)UIImageView  *centerImageView ;
@property (nonatomic,strong)UIImageView  *rightImageView ;



@end
@implementation ZPLoopScrollView

- (void)dealloc
{
    [_timer invalidate];
    _timer =nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        [self setup];
    }
    return self;
}

- (void)setup
{
    /**
     *   创建scrollView
     *  添加图片显示控件
     *
     *  @return
     */
    [self addSubview:self.scrollView];
    
    [self.scrollView addSubview:self.leftImageView];
    [self.scrollView addSubview:self.centerImageView];
    [self.scrollView addSubview:self.rightImageView];
    
    [self addSubview:self.pageControl];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _scrollView.frame = self.bounds;
    _scrollView.contentOffset = CGPointMake(kScrollViewW, 0);
    
    _leftImageView.frame = CGRectMake(0, 0, kScrollViewW, kScrollViewH);
    
    _rightImageView.frame = CGRectMake(2*kScrollViewW, 0, kScrollViewW, kScrollViewH);
    
    _centerImageView.frame = CGRectMake(kScrollViewW, 0, kScrollViewW, kScrollViewH);
    
    CGSize  size =[_pageControl sizeForNumberOfPages:imageCount];
    _pageControl.bounds =CGRectMake(0, 0, size.width, size.height);
    
    if (_pageControllCenterYScale) {
        _pageControl.center =CGPointMake(kScrollViewW/2,kScrollViewH*_pageControllCenterYScale);
    }else
    {
        _pageControl.center =CGPointMake(kScrollViewW/2,kScrollViewH*0.8);
    }
    
}
#pragma mark - Event
#pragma mark  GestureRecognizer
- (void)handlePan:(UIPanGestureRecognizer *)ges
{
    if (isAnimation) {
        return;
    }
    
    if (ges.state == UIGestureRecognizerStateBegan) {
        if (_timer  && ![_timer isValid]) {
            NSLog(@"timer not valid");
            return;
        }
        if (_timer) {
            [_timer setFireDate:[NSDate distantFuture]];
        }
        
    }else if (ges.state == UIGestureRecognizerStateChanged)
    {
        if (_timer  && ![_timer isValid]) {
            NSLog(@"timer not valid");
            return;
        }
        CGPoint currentPoint = [ges translationInView:ges.view];
        radio = currentPoint.x / self.bounds.size.width;
        _scrollView.contentOffset = CGPointMake(kScrollViewW-currentPoint.x, 0);
    }
    else if(ges.state == UIGestureRecognizerStateEnded)
    {
        if (_timer  && ![_timer isValid]) {
            NSLog(@"timer not valid");
            return;
        }
        if (fabs(radio) < 0.4) {
            [_scrollView setContentOffset:CGPointMake(kScrollViewW, 0) animated:YES];
            
            if (_timer) {
                [_timer setFireDate:[NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]]];
            }
            return;
        }
        
        [self reloadImage:fabs(radio) endProgress:1.0];
        if (_timer) {
            [_timer setFireDate:[NSDate dateWithTimeInterval:3 sinceDate:[NSDate date]]];
        }
    }
}
- (void)handleTapImageIndex:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateBegan) {
        if ([_delegate respondsToSelector:@selector(scrollViewLoopWillStartClick:index:)]) {
            [_delegate scrollViewLoopWillStartClick:self index:currentIndex];
        }
    }else if (tap.state == UIGestureRecognizerStateEnded)
    {
        if ([_delegate respondsToSelector:@selector(scrollViewLoopDidEndClicked:index:)]) {
            [_delegate scrollViewLoopDidEndClicked:self index:currentIndex];
        }
    }
}

#pragma mark set left\center\right defaultImage
- (void)addDefaultImage
{
    
    _leftImageView.image   = _images[_images.count -1];
    currentIndex =0;
    _centerImageView.image = _images[currentIndex];
    _rightImageView.image  = _images[currentIndex+1];
}

- (void)addDefaultImageURL
{
    currentIndex =0;
    [_leftImageView  setImageWithURL:_imagesURL[_imagesURL.count -1]];
    [_centerImageView  setImageWithURL:_imagesURL[currentIndex]];
    [_rightImageView  setImageWithURL:_imagesURL[currentIndex+1]];
}
#pragma mark    start timer
- (void)startTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer =    [NSTimer timerWithTimeInterval:2 target:self selector:@selector(reloadImageView) userInfo:nil repeats:YES];
    NSRunLoop *runLoop =    [NSRunLoop currentRunLoop];
    [runLoop addTimer:_timer forMode:NSDefaultRunLoopMode];
}
- (void)reloadImageView
{
    
    if (isAnimation) {
        return;
    }
    _scrollView.contentOffset =CGPointMake(2*kScrollViewW, 0);
    //重新布局加载图片
    [self reloadImage:0.0 endProgress:1.0];
}
- (void)reloadImage:(CGFloat)startProgress endProgress:(CGFloat)endProgress
{
    isAnimation = YES;
    
    CGPoint offset =[_scrollView contentOffset];
    /**
     *  给中心图片添加动画，
     */
    CATransition *transition =[CATransition animation];
    transition.startProgress =startProgress;
    transition.endProgress =endProgress;
    transition.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    transition.type =@"push";
    transition.delegate = self;
    transition.duration =0.5f;
    //如果向右滑动
    if (offset.x > kScrollViewW)
    {
        currentIndex =(currentIndex+1)%imageCount;
        transition.subtype =kCATransitionFromRight;
    }else //向左滑动
    {
        currentIndex =(currentIndex-1 +imageCount)%imageCount;
        transition.subtype =kCATransitionFromLeft;
    }
    
    if (_images.count && _images) {
        _centerImageView.image = _images[currentIndex];
    }else if (_imagesURL.count && _imagesURL)
    {
        [_centerImageView  setImageWithURL:_imagesURL[currentIndex]];
    }
    
    [_centerImageView.layer addAnimation:transition forKey:@"centerAnimation"];
    
    //每次滑动过后都将偏移量置为中间的图
    _scrollView.contentOffset =CGPointMake(kScrollViewW, 0);
    _pageControl.currentPage =currentIndex;
}

#pragma  mark - delegate

#pragma mark  CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    isAnimation = NO;
    NSUInteger leftImageIndex,rightImageIndex;
    leftImageIndex =(currentIndex-1+imageCount )%imageCount;
    rightImageIndex =(currentIndex +1)%imageCount;
    if (_images.count) {
        _leftImageView.image =_images[leftImageIndex];
        _rightImageView.image =_images[rightImageIndex];
        
    }else if (_imagesURL.count)
    {
        [_leftImageView setImageWithURL:_imagesURL[leftImageIndex]];
        [_rightImageView setImageWithURL:_imagesURL[rightImageIndex]];
    }
    
}

#pragma mark - setter & getter

- (void)setImages:(NSArray *)images
{
    _images = images;
    _imagesURL  = nil ;
    //加载数据，获取图片
    imageCount = images.count;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (images.count >= 2) {
            // 添加默认的图片
            [self addDefaultImage];
            _pageControl.numberOfPages =imageCount;
        }
        if (imageCount) {
            [self startTimer];
        }
    });
    
}

- (void)setImagesURL:(NSArray *)imagesURL
{
    _imagesURL = imagesURL;
    _images = nil;
    imageCount = imagesURL.count;
    
    if (imagesURL.count >= 2) {
        // 添加默认的图片
        [self addDefaultImageURL];
        _pageControl.numberOfPages =imageCount;
    }
    if (imageCount) {
        [self startTimer];
    }
    
}
- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor
{
    if (_pageControl) {
        _pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
    }
    _pageIndicatorTintColor = pageIndicatorTintColor;
}

- (void)setCurrentPageIndicatorTintColor:(UIColor *)currentPageIndicatorTintColor
{
    if (_pageControl) {
        _pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    }
    _currentPageIndicatorTintColor = currentPageIndicatorTintColor;
}
- (UIImageView *)leftImageView
{
    
    if (!_leftImageView) {
        UIImageView * imageView = [[UIImageView alloc]init];
        imageView.contentMode =UIViewContentModeScaleAspectFit;
        _leftImageView = imageView;
    }
    
    return _leftImageView;
}

- (UIImageView *)rightImageView
{
    
    if (!_rightImageView) {
        UIImageView * rightImageView =[[UIImageView alloc]init];
        rightImageView.contentMode =UIViewContentModeScaleAspectFit;
        _rightImageView = rightImageView;
    }
    
    return _rightImageView;
}

- (UIImageView *)centerImageView
{
    
    if (!_centerImageView) {
        UIImageView *  centerImageView =[[UIImageView alloc]init];
        centerImageView.userInteractionEnabled = YES;
        centerImageView.contentMode =UIViewContentModeScaleAspectFit;
        UIPanGestureRecognizer * pan  = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapImageIndex:)];
        [centerImageView addGestureRecognizer:pan];
        [centerImageView addGestureRecognizer:tap];
        
        _centerImageView = centerImageView;
    }
    return _centerImageView;
    
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        UIScrollView * scrollView  =[[UIScrollView alloc]init];
        scrollView.bounces =NO;
        scrollView.contentSize =CGSizeMake(kScrollViewW *kCount, kScrollViewH);
        scrollView.delegate = self;
        scrollView.pagingEnabled =YES;
        scrollView.showsHorizontalScrollIndicator =NO;
        _scrollView = scrollView;
    }
    return _scrollView;
}
- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        UIPageControl * pageControl =[[UIPageControl alloc]init];
        pageControl.enabled =NO;
        pageControl.pageIndicatorTintColor =[UIColor colorWithRed:193/255.0 green:219/255.0 blue:249/255.0 alpha:1];
        pageControl.currentPageIndicatorTintColor =[UIColor colorWithRed:0 green:150/255.0 blue:1 alpha:1];
        _pageControl = pageControl;
    }
    return _pageControl;
}
@end
