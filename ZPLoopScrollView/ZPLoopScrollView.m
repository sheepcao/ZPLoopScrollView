
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
#import "UIImageView+AFNetworking.h"

static  NSUInteger kShowIndexW = 40;

@interface ZPLoopScrollView ()<UIScrollViewDelegate>
{
    NSUInteger imageCount;
    NSUInteger currentIndex;
    BOOL        isAnimation ;
    CGFloat     radio;
}
@property (nonatomic,strong)UIScrollView  *scrollView;
@property (nonatomic,strong)UIPageControl *pageControl;
@property (nonatomic,strong)UIImageView  *leftImageView ;
@property (nonatomic,strong)UIImageView  *centerImageView ;
@property (nonatomic,strong)UIImageView  *rightImageView ;
@property (nonatomic,strong)UILabel      *showIndexControl;
@property (nonatomic,strong)NSTimer *timer;

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
        self.scrollViewType = ZPLoopScrollViewPageControlType;
    }
    return self;
}
- (instancetype)initWithLoopScrollViewType:(ZPLoopScrollViewType)type
{
    
    if (self == [super init]) {
        
        self.scrollViewType = type;
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
    [_scrollView addSubview:self.leftImageView];
    [_scrollView addSubview:self.centerImageView];
    [_scrollView addSubview:self.rightImageView];
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _scrollView.frame = self.bounds;
    _scrollView.contentOffset = CGPointMake(kScrollViewW, 0);
    
    _leftImageView.frame = CGRectMake(0, 0, kScrollViewW, kScrollViewH);
    
    _rightImageView.frame = CGRectMake(2*kScrollViewW, 0, kScrollViewW, kScrollViewH);
    
    _centerImageView.frame = CGRectMake(kScrollViewW, 0, kScrollViewW, kScrollViewH);
    
    if (_pageControl && _scrollViewType == ZPLoopScrollViewPageControlType)
    {
        CGSize  size =[_pageControl sizeForNumberOfPages:imageCount];
        _pageControl.bounds =CGRectMake(0, 0, size.width, size.height);
        
        if (_pageControllCenterYScale) {
            _pageControl.center =CGPointMake(kScrollViewW/2,kScrollViewH*_pageControllCenterYScale);
        }else
        {
            _pageControl.center =CGPointMake(kScrollViewW/2,kScrollViewH*0.8);
        }
        
    }else if (_showIndexControl && _scrollViewType == ZPLoopScrollViewShowIndexType)
    {
        
        _showIndexControl.frame = CGRectMake(self.bounds.size.width-10-kShowIndexW,self.bounds.size.height-kShowIndexW-10, kShowIndexW, kShowIndexW);
        _showIndexControl.layer.cornerRadius = kShowIndexW*0.5;
        _showIndexControl.layer.masksToBounds = YES;
    }
    
}
#pragma mark - Event
#pragma mark  GestureRecognizer
- (void)handlePan:(UIPanGestureRecognizer *)ges
{
    if (isAnimation) {
        return;
    }
    CGPoint currentPoint = [ges translationInView:ges.view];
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
    [_leftImageView  setImageWithURL:[NSURL URLWithString:_imagesURL[_imagesURL.count -1]]];
    [_centerImageView  setImageWithURL:[NSURL URLWithString:_imagesURL[currentIndex]]];
    [_rightImageView  setImageWithURL:[NSURL URLWithString:_imagesURL[currentIndex+1]]];
}

#pragma mark    stop timer
- (void)stopTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}
#pragma mark    start timer
- (void)startTimer
{
    if (imageCount <2) {
        return;
    }
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    NSRunLoop *runLoop =    [NSRunLoop currentRunLoop];
    [runLoop addTimer:self.timer forMode:NSDefaultRunLoopMode];
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
        [_centerImageView  setImageWithURL:[NSURL URLWithString:_imagesURL[currentIndex]]];
    }
    
    [_centerImageView.layer addAnimation:transition forKey:@"centerAnimation"];
    
    //每次滑动过后都将偏移量置为中间的图
    _scrollView.contentOffset =CGPointMake(kScrollViewW, 0);
    if (_pageControl) {
        _pageControl.currentPage =currentIndex;
    }
    if (_showIndexControl) {
        _showIndexControl.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)currentIndex+1,(unsigned long)imageCount];
    }
    
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
        
        [_leftImageView setImageWithURL:[NSURL URLWithString:_imagesURL[leftImageIndex]]];
        [_rightImageView setImageWithURL:[NSURL URLWithString:_imagesURL[rightImageIndex]]];
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
            
            if (_pageControl) {
                _pageControl.numberOfPages =imageCount;
            }
            if (_showIndexControl) {
                _showIndexControl.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)currentIndex+1,(unsigned long)imageCount];
                
            }
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
        if (_pageControl) {
            _pageControl.numberOfPages =imageCount;
        }
        if (_showIndexControl) {
            _showIndexControl.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)currentIndex+1,(unsigned long)imageCount];
            
        }
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

- (void)setScrollViewType:(ZPLoopScrollViewType)scrollViewType
{
    switch (scrollViewType) {
        case ZPLoopScrollViewPageControlType:
        {
            if (_showIndexControl) {
                [_showIndexControl removeFromSuperview];
                _showIndexControl = nil;
            }
            [self addSubview:self.pageControl];
        }
            break;
        case ZPLoopScrollViewShowIndexType:
        {
            if (_pageControl) {
                [_pageControl removeFromSuperview];
                _pageControl = nil;
            }
            [self addSubview:self.showIndexControl];
        }
            break;
        default:
            break;
    }
    _scrollViewType = scrollViewType;
    
}
- (void)setShowIndexTextBackgroundColor:(UIColor *)showIndexTextBackgroundColor
{
    if (_showIndexControl) {
        _showIndexControl.backgroundColor = showIndexTextBackgroundColor;
    }
    _showIndexTextBackgroundColor = showIndexTextBackgroundColor;
}
- (void)setShowIndexTextColor:(UIColor *)showIndexTextColor
{
    if (_showIndexControl) {
        _showIndexControl.textColor = showIndexTextColor;
    }
    _showIndexTextColor = showIndexTextColor;
}
- (void)setShowIndexTextFont:(UIFont *)showIndexTextFont
{
    if (_showIndexTextFont) {
        _showIndexControl.font = showIndexTextFont;
    }
    _showIndexTextFont = showIndexTextFont;
}

- (UIImageView *)leftImageView
{
    
    if (!_leftImageView) {
        UIImageView * imageView = [[UIImageView alloc]init];
        imageView.contentMode =UIViewContentModeScaleToFill;
        _leftImageView = imageView;
    }
    
    return _leftImageView;
}

- (UIImageView *)rightImageView
{
    
    if (!_rightImageView) {
        UIImageView * rightImageView =[[UIImageView alloc]init];
        rightImageView.contentMode =UIViewContentModeScaleToFill;
        _rightImageView = rightImageView;
    }
    
    return _rightImageView;
}

- (UIImageView *)centerImageView
{
    
    if (!_centerImageView) {
        UIImageView *  centerImageView =[[UIImageView alloc]init];
        centerImageView.userInteractionEnabled = YES;
        centerImageView.contentMode =UIViewContentModeScaleToFill;
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

- (UILabel *)showIndexControl
{
    if (!_showIndexControl) {
        _showIndexControl = [[UILabel alloc]init];
        _showIndexControl.textColor = [UIColor blackColor];
        _showIndexControl.textAlignment = NSTextAlignmentCenter;
        _showIndexControl.backgroundColor = [UIColor whiteColor];
        _showIndexControl.font = [UIFont boldSystemFontOfSize:17.0];
    }
    return _showIndexControl;
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer =    [NSTimer timerWithTimeInterval:2 target:self selector:@selector(reloadImageView) userInfo:nil repeats:YES];
    }
    return _timer;
}
@end
