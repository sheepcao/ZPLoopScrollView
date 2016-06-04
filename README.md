# ZPLoopScrollView
使用三个UIImageView实现图片的无限循环,可手动拖拽以及点击交互

#添加到你的项目
####Cocoapods添加:
直接在Podfile中使用即可

	pod 'ZPLoopScrollView', '~> 1.0.1'
####手动添加:

1. 添加**ZPLoopScrollView.h** 和 **ZPLoopScrollView.m**到你的项目.
ZPLoopScrollView 需要ARC.

#使用

   	- (void)viewDidLoad {
		  [super viewDidLoad];
	 	// Do any additional setup after loading the view, typically from a nib.
	 	//    NSString * path = [[NSBundle mainBundle] pathForResource:@"ImageInfo.plist" ofType:nil];
		//    NSDictionary  * dic = [NSDictionary dictionaryWithContentsOfFile:path];
		//    
		//    NSMutableArray * array = [NSMutableArray array];
		//    for (NSString * str  in dic.allKeys) {
		//        UIImage * i = [UIImage imageNamed:str];
		//        [array addObject:i];
		//    }
    
    		[self.view addSubview:self.scrollView];
	    	//设置展示图片
		 	//self.scrollView.images = array;
			//设置网络图片
			self.scrollView.imagesURL = @[@"http://img4.duitang.com/uploads/item/201204/11/20120411162656_eJJiZ.jpeg",
		                                  @"http://img.ycwb.com/news/attachement/jpg/site2/20110226/90fba60155890ed3082500.jpg",
		                                  @"http://imgsrc.baidu.com/forum/pic/item/b03533fa828ba61e78ab1c894134970a314e59cb.jpg",
		                                  @"http://pic27.nipic.com/20130227/7224820_020411089000_2.jpg"];
			 //设置pageControl在self.scrollView高度的比例,默认为0.8
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
	
#效果展示
![图片循环,可点击](https://github.com/twenty-zp/Nothing/blob/master/2016-05-31%2016_54_22.gif)
