//
//  ViewController.m
//  ZPLoopScrollViewDemo
//
//  Created by zp on 16/5/31.
//  Copyright © 2016年 iLogiEMAC. All rights reserved.
//

#import "ViewController.h"
#import "ZPLoopScrollView.h"
@interface ViewController ()<ZPLoopScrollViewDelegate>
@property (nonatomic,strong)ZPLoopScrollView * scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString * path = [[NSBundle mainBundle] pathForResource:@"ImageInfo.plist" ofType:nil];
    NSDictionary  * dic = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSMutableArray * array = [NSMutableArray array];
    for (NSString * str  in dic.allKeys) {
        UIImage * i = [UIImage imageNamed:str];
        [array addObject:i];
    }
    
    [self.view addSubview:self.scrollView];
    self.scrollView.images = array;
    
    self.scrollView.pageControllCenterYScale = 0.5;
}
#pragma mark - delegate
- (void)scrollViewLoopDidEndClicked:(ZPLoopScrollView *)scrollViewLoop index:(NSUInteger)index
{
    
}
#pragma mark - setter & getter
- (ZPLoopScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[ZPLoopScrollView alloc]initWithFrame:self.view.bounds];
        _scrollView.delegate = self;
    }
    return _scrollView;
}

@end
