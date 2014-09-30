//
//  PedoViewController.h
//  MyWatchDemo
//
//  Created by maginawin on 14-8-21.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WWDAppDelegate.h"

@interface PedoViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *connectStateImage;//连接按钮(蓝牙图标)
@property (weak, nonatomic) IBOutlet UILabel *pedometerView;//显示计步数的label
@property (weak, nonatomic) IBOutlet UILabel *distanceView;//显示距离
@property (weak, nonatomic) IBOutlet NSTimer *timer;//计时器
@property (weak, nonatomic) IBOutlet UILabel *timerView;//计时器显示
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;




- (IBAction)startPedometer:(id)sender;
- (IBAction)pausePedometer:(id)sender;
- (IBAction)stopPedometer:(id)sender;
- (IBAction)clearPedometer:(id)sender;

@end
