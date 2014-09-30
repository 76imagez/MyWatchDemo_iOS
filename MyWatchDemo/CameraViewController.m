//
//  CameraViewController.m
//  AVRecordTest
//
//  Created by maginawin on 14-9-9.
//  Copyright (c) 2014年 crazyit.org. All rights reserved.
//

#import "CameraViewController.h"

static void *AVCamFocusModeObserverContext = &AVCamFocusModeObserverContext;
@interface CameraViewController (WWDRecoerdManagerDelegate)<WWDRecoredManagerDelegate>

@end

@implementation CameraViewController
AVCaptureVideoPreviewLayer* previewLayer;
NSNotificationCenter* notiCenter;

UILabel* focusModeLabel;
// 定义一个方法，将对焦模式转换为字符串
- (NSString *)stringForFocusMode:(AVCaptureFocusMode)focusMode
{
	NSString *focusString = @"";
	switch (focusMode)
	{
		case AVCaptureFocusModeLocked:
			focusString = @"锁定";
			break;
		case AVCaptureFocusModeAutoFocus:
			focusString = @"自动对焦";
			break;
		case AVCaptureFocusModeContinuousAutoFocus:
			focusString = @"连续对焦";
			break;
	}
	return focusString;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//   
//    UIBarButtonItem* leftButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back)];
//    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(capture)];
//    [self.navigationItem setLeftBarButtonItem:leftButton];
//    [self.navigationItem setRightBarButtonItem:rightButton];
//    [self.navigationItem setTitle:@"Camera"];
//    
    notiCenter = [NSNotificationCenter defaultCenter];
    // 如果没有初始化FKRecordMangaer，初始化FKRecordMangaer
	if (self.recordManager == nil)
	{
		self.recordManager = [[WWDRecoredManager alloc] init];
		self.recordManager.delegate = self;
		// 为FKRecordMangaer安装Session
		if ([self.recordManager setupSession])
		{
			[self.videoPreviewView.layer setMasksToBounds:YES];
			// 创建摄像头的预览Layer
			previewLayer = [[AVCaptureVideoPreviewLayer alloc]
                            initWithSession:self.recordManager.session];
			// 获取当前视图控制器内view的bounds
			CGRect bounds = self.view.bounds;
			// 设置预览Layer的大小和位置
			previewLayer.frame = bounds;
			// 设置预览Layer的缩放方式
			[previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
			// 将预览Layer添加到预览UIView上
			[self.videoPreviewView.layer insertSublayer:previewLayer
                                                  below:[[self.videoPreviewView.layer sublayers] objectAtIndex:0]];
			// 以异步方式启动FKRecordManager内包装的AVCaptureSession
			dispatch_async(dispatch_get_global_queue(
                                                     DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[self.recordManager.session startRunning];
			});
//			[self updateButtonStates];
			// 创建显示对焦模式的UILable
			focusModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20
                                                                       , bounds.size.width - 20, 20)];
			// 设置UILabel的背景色
			focusModeLabel.backgroundColor = [UIColor clearColor];
			// 设置UILabel的文本颜色
			focusModeLabel.textColor = [UIColor colorWithRed:1.0 green:1.0
                                                        blue:1.0 alpha:0.50];
			// 获取对焦模式
			AVCaptureFocusMode initialFocusMode =
			self.recordManager.videoInput.device.focusMode;
			focusModeLabel.text = [NSString stringWithFormat:@"对焦: %@",
								   [self stringForFocusMode:initialFocusMode]];
			[self.videoPreviewView addSubview:focusModeLabel];
            if ([[[self.recordManager videoInput] device]
                 isFocusPointOfInterestSupported])
            {
                // 设置使用连续对焦
                [self.recordManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
            }
			// 监听对焦模式的改变
//			[self addObserver:self
//                   forKeyPath:@"recordManager.videoInput.device.focusMode"
//                      options:NSKeyValueObservingOptionNew
//                      context:AVCamFocusModeObserverContext];
////			 添加单击手势检测器，当用户单击预览UIView时，切换为自动对焦
//			UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
//                                                 initWithTarget:self action:@selector(tapToAutoFocus:)];
//			[singleTap setNumberOfTapsRequired:1];
//			[self.videoPreviewView addGestureRecognizer:singleTap];
////			 添加双击手势检测器，当用户双击预览UIView时，切换为连续对焦
//			UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]
//                                                 initWithTarget:self action:@selector(tapToContinouslyAutoFocus:)];
//			[doubleTap setNumberOfTapsRequired:2];
//			[singleTap requireGestureRecognizerToFail:doubleTap];
//			[self.videoPreviewView addGestureRecognizer:doubleTap];
            
            [self setHidesBottomBarWhenPushed:NO];
            
		}
	}
}

- (void)viewDidAppear:(BOOL)animated{
    [notiCenter removeObserver:self name:@"camera" object:nil];
    [notiCenter addObserver:self selector:@selector(cameraJump:) name:@"camera" object:nil];
//    [self addObserver:self
//           forKeyPath:@"recordManager.videoInput.device.focusMode"
//              options:NSKeyValueObservingOptionNew
//              context:AVCamFocusModeObserverContext];
//    [self removeObserver:self forKeyPath:@"recordManager.videoInput.device.focusMode"];
//    [self removeObserver:self forKeyPath:@"videoInput.device.focusMode"];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [notiCenter removeObserver:self name:@"camera" object:nil];
    
}

- (void)cameraJump:(NSNotification*)myNotification{
    [self capture];
}

- (void)viewWillDisAppear:(BOOL)animated{
    
}


// 监听对焦方式改变的方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context
{
	if (context == AVCamFocusModeObserverContext)
	{
		// 根据对焦模式更新focusModeLabel的文本
		[focusModeLabel setText:[NSString stringWithFormat:@"对焦: %@",
                                 [self stringForFocusMode:(AVCaptureFocusMode)
                                  [[change objectForKey:NSKeyValueChangeNewKey] integerValue]]]];
	}
	else
	{
		// 对于其他的改变，此处直接回调，不作任何控制
		[super observeValueForKeyPath:keyPath ofObject:object change:change
							  context:context];
	}
}

- (IBAction)backBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];    
}

- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)capture{
    // 拍摄静止照片
	[self.recordManager captureStillImage];
	// 创建一个UIView实现闪屏效果
	UIView *flashView = [[UIView alloc] initWithFrame:[
                                                       [self videoPreviewView] frame]];
	// 设置背景色为白色
	flashView.backgroundColor= [UIColor whiteColor];
	// 添加flashView
	[self.view.window addSubview:flashView];
	// 控制flashView执行在0.4秒之内变成完全透明，变为透明时删除该flashVew
	[UIView animateWithDuration:.4f
                     animations:^{
                         [flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                     }
	 ];
}

- (IBAction)toggleCamera:(id)sender
{
	// 切换前后的摄像头
	[self.recordManager toggleCamera];
	// 执行初始化对焦
	[self.recordManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}

- (IBAction)captureStillImage:(id)sender
{

	// 拍摄静止照片
	[self.recordManager captureStillImage];
	// 创建一个UIView实现闪屏效果
	UIView *flashView = [[UIView alloc] initWithFrame:[
                                                       [self videoPreviewView] frame]];
	// 设置背景色为白色
	flashView.backgroundColor= [UIColor whiteColor];
	// 添加flashView
	[self.view.window addSubview:flashView];
	// 控制flashView执行在0.4秒之内变成完全透明，变为透明时删除该flashVew
	[UIView animateWithDuration:.4f
                     animations:^{
                         [flashView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                         [flashView removeFromSuperview];
                     }
	 ];
}

// 当屏幕旋转时自动激发该方法，该方法重新调整previewLayer的大小和位置
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)
interfaceOrientation duration:(NSTimeInterval)duration
{
	// 根据屏幕方向对预览Layer进行旋转，保证预览画面总是与拍照画面一致
	switch (interfaceOrientation)
	{
		case UIInterfaceOrientationLandscapeLeft:
			previewLayer.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
			break;
		case UIInterfaceOrientationLandscapeRight:
			previewLayer.affineTransform =
            CGAffineTransformMakeRotation(M_PI * 3 / 2);
			break;
		case UIInterfaceOrientationPortrait:
			previewLayer.affineTransform = CGAffineTransformIdentity;
			break;
		default:
			break;
	}
	previewLayer.frame = self.view.bounds;;
}

// 将预览UIView上坐标系统转换为摄像头的摄像头的坐标系统。
// 在摄像头坐标系统中， {0,0}代表图片的左上角，{1,1}代表右下角
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
	CGPoint pointOfInterest = CGPointMake(.5f, .5f);
	// 获取预览Layer的大小和位置
	CGSize frameSize = [[self videoPreviewView] frame].size;
	
	if ([previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResize])
	{
		// 对X、Y坐标进行缩放，并执行反转
		pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height,
                                      1.0f - (viewCoordinates.x / frameSize.width));
	}
	else
	{
		CGRect cleanAperture;
		for (AVCaptureInputPort *port in self.recordManager.videoInput.ports)
		{
			if ([port mediaType] == AVMediaTypeVideo)
			{
				cleanAperture = CMVideoFormatDescriptionGetCleanAperture
                ([port formatDescription], YES);
				CGSize apertureSize = cleanAperture.size;
				CGPoint point = viewCoordinates;
				CGFloat apertureRatio = apertureSize.height / apertureSize.width;
				CGFloat viewRatio = frameSize.width / frameSize.height;
				CGFloat xc = .5f;
				CGFloat yc = .5f;
				if ([previewLayer.videoGravity isEqualToString:
                     AVLayerVideoGravityResizeAspect])
				{
					if (viewRatio > apertureRatio)
					{
						CGFloat y2 = frameSize.height;
						CGFloat x2 = frameSize.height * apertureRatio;
						CGFloat x1 = frameSize.width;
						CGFloat blackBar = (x1 - x2) / 2;
						if (point.x >= blackBar && point.x <= blackBar + x2)
						{
							xc = point.y / y2;
							yc = 1.f - ((point.x - blackBar) / x2);
						}
					}
					else
					{
						CGFloat y2 = frameSize.width / apertureRatio;
						CGFloat y1 = frameSize.height;
						CGFloat x2 = frameSize.width;
						CGFloat blackBar = (y1 - y2) / 2;
						if (point.y >= blackBar && point.y <= blackBar + y2)
						{
							xc = ((point.y - blackBar) / y2);
							yc = 1.f - (point.x / x2);
						}
					}
				}
				else if([previewLayer.videoGravity isEqualToString:
                         AVLayerVideoGravityResizeAspectFill])
				{
					// 对X、Y坐标进行缩放，并执行反转
					if (viewRatio > apertureRatio) {
						CGFloat y2 = apertureSize.width * (frameSize.width
                                                           / apertureSize.height);
						xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
						yc = (frameSize.width - point.x) / frameSize.width;
					}
					else
					{
						CGFloat x2 = apertureSize.height * (frameSize.height
                                                            / apertureSize.width);
						yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
						xc = point.y / frameSize.height;
					}
				}
				pointOfInterest = CGPointMake(xc, yc);
				break;
			}
		}
	}
	return pointOfInterest;
}

// 处理自动对焦的方法，该方法将会自动对焦到某个点。
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
	if ([[[self.recordManager videoInput] device]
		 isFocusPointOfInterestSupported])
	{
		// 获取用户点击的点
		CGPoint tapPoint = [gestureRecognizer
                            locationInView:[self videoPreviewView]];
		// 将用户点击的点的坐标，转化为摄像预览的控件内的坐标
		CGPoint convertedFocusPoint =
		[self convertToPointOfInterestFromViewCoordinates:tapPoint];
		// 设置使用自动对焦
		[self.recordManager autoFocusAtPoint:convertedFocusPoint];
	}
}
// 处理连续对焦的方法
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
	if ([[[self.recordManager videoInput] device]
		 isFocusPointOfInterestSupported])
	{
		// 设置使用连续对焦
		[self.recordManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

