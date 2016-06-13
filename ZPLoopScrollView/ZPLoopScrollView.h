//
//  ZPScrollViewLoop.h
//  RunLoopScrollView
//
//  Created by zp on 16/5/31.
//  Copyright © 2016年 iLogiE MAC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,ZPLoopScrollViewType)
{
    ZPLoopScrollViewPageControlType = 0,
    ZPLoopScrollViewShowIndexType,
};

@protocol ZPLoopScrollViewDelegate;
@interface ZPLoopScrollView : UIView

/**
 *  show image arrays
 */
@property (nonatomic,strong)NSArray<UIImage *> * images;
/**
 *  image's URL
 */
@property (nonatomic,strong)NSArray<NSString *> *imagesURL;
@property (nonatomic,assign)id<ZPLoopScrollViewDelegate> delegate;
/**
 *   The tint color to be used for the page indicator.
 */
@property (nonatomic,strong)UIColor * pageIndicatorTintColor;
/**
 *   The tint color to be used for the current page indicator.
 */
@property (nonatomic,strong)UIColor * currentPageIndicatorTintColor;

//Default 0.8
@property (nonatomic,assign)CGFloat pageControllCenterYScale;

//showIndexLabel text Color
@property (nonatomic,strong)UIColor * showIndexTextColor;

//showIndexLabel text Font
@property (nonatomic,strong)UIFont  * showIndexTextFont;

//showIndexLabel backgroundColor
@property (nonatomic,strong)UIColor * showIndexTextBackgroundColor;

//展示scrollView中的pageControl 各个类型
@property (nonatomic,assign)ZPLoopScrollViewType scrollViewType;

//获取定时器
@property (nonatomic,strong,readonly)NSTimer *timer;


- (instancetype)initWithLoopScrollViewType:(ZPLoopScrollViewType)type;

//startTimer set images or imagesURL later ,setter 开启定时器
- (void)startTimer;
//stopTimer 停止定时器
- (void)stopTimer;

@end


@protocol ZPLoopScrollViewDelegate <NSObject>

@optional
- (void)scrollViewLoopWillStartClick:(ZPLoopScrollView *)scrollViewLoop index:(NSUInteger)index;
- (void)scrollViewLoopDidEndClicked:(ZPLoopScrollView *)scrollViewLoop index:(NSUInteger)index;

@end