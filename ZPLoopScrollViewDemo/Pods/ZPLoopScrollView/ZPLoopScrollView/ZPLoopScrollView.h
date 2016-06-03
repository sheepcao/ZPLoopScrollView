//
//  ZPScrollViewLoop.h
//  RunLoopScrollView
//
//  Created by zp on 16/5/31.
//  Copyright © 2016年 iLogiE MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ZPLoopScrollViewDelegate;
@interface ZPLoopScrollView : UIView

/**
 *  show image arrays
 */
@property (nonatomic,strong)NSArray * images;

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

@end


@protocol ZPLoopScrollViewDelegate <NSObject>

@optional
- (void)scrollViewLoopWillStartClick:(ZPLoopScrollView *)scrollViewLoop index:(NSUInteger)index;
- (void)scrollViewLoopDidEndClicked:(ZPLoopScrollView *)scrollViewLoop index:(NSUInteger)index;

@end