//
//  WWDViewController.m
//  MyWatchDemo
//
//  Created by maginawin on 14-8-20.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import "WWDViewController.h"

@interface WWDViewController ()

@property (strong, nonatomic) UIColor* redColor;
@property (nonatomic, assign) WWDAppDelegate* myAppDelegate;

@end

@implementation WWDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _redColor = [UIColor colorWithRed:217.0/255 green:95.0/255 blue:120.0/255 alpha:1.0f];
    _myAppDelegate = (WWDAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"myDidConnectPeripheral" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myDidConnectPeripheral:) name:@"myDidConnectPeripheral" object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"myDidDisconnectPeripheral" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myDidDisconnectPeripheral:) name:@"myDidDisconnectPeripheral" object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"pedometer" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pedometer:) name:@"pedometer" object:nil];
        
}

- (void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"camera" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cameraJump:) name:@"camera" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"camera" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)myDidConnectPeripheral:(NSNotification*)myNotification{
    
    NSLog(@"收到连接通知而已");
 
    _connectStateView0.backgroundColor = [UIColor whiteColor];
    _connectStateView1.backgroundColor = [UIColor whiteColor];
    _connectStateView2.backgroundColor = [UIColor whiteColor];
    _connectStateView3.backgroundColor = [UIColor whiteColor];
    _connectStateView4.backgroundColor = [UIColor whiteColor];
    _connectStateView5.backgroundColor = [UIColor whiteColor];
}

- (void)myDidDisconnectPeripheral:(NSNotification*)myNotification{
    
    NSLog(@"收到断线通知而已");
    
//    _connectStateView0.backgroundColor = _redColor;
    _connectStateView1.backgroundColor = _redColor;
    _connectStateView2.backgroundColor = _redColor;
    _connectStateView3.backgroundColor = _redColor;
    _connectStateView4.backgroundColor = _redColor;
    _connectStateView5.backgroundColor = _redColor;
    [_connectStateView0 setBackgroundColor:_redColor];
}

- (void)pedometer:(NSNotification*)myNotification{
    
    NSLog(@"收到pedometer通知而已");
    NSString* value = [myNotification object];
    
    NSString* pedometerString = [WWDTools stringFromIndexCount:2 count:8 from:value];
    NSString* distanceString = [WWDTools stringFromIndexCount:10 count:8 from:value];
    NSString* calorieString = [WWDTools stringFromIndexCount:18 count:8 from:value];
    NSString* timeStr = [WWDTools stringFromIndexCount:26 count:6 from:value];
    
    unsigned int outVal = [WWDTools intFromHexString:pedometerString];
    NSString* pedometerValue = [NSString stringWithFormat:@"%d", outVal];
    float distanceVal = [WWDTools intFromHexString:distanceString];
    NSString* distance = [NSString stringWithFormat:@"%0.02f", (distanceVal / 100)];
    float calorieVal = [WWDTools intFromHexString:calorieString];
    NSString* calorie = [NSString stringWithFormat:@"%0.01f", (calorieVal / 10)];
    NSString* speed = [WWDTools getSpeedFromDistance:distanceString andTime:timeStr];
    NSString* actTime = [WWDTools getHHMMSSFromStringHMS:timeStr];
    if(outVal > 0){
         NSString* target = [NSString stringWithFormat:@"%0.02f", outVal / 100.00f];
        _targetRateView.text = target;
    }else{
        _targetRateView.text = @"0.00";
    }
    
    _stepsCountView.text = pedometerValue;
    _actTimeView.text = actTime;
    _distanceView.text = distance;
    _calorieView.text = calorie;
    _speedView.text = speed;

}

- (void)cameraJump:(NSNotification*)myNotification{
    [self setHidesBottomBarWhenPushed:YES];
    [self performSegueWithIdentifier:@"cameraSegue" sender:self];
    [self setHidesBottomBarWhenPushed:NO];
}


- (IBAction)clearData:(id)sender {
    
    UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"Whether to clear all pedo data of today?" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:@"confirm" otherButtonTitles:nil, nil];
    sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [sheet showInView:self.view];
}
//UIActionSheet*的Delegate事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        _stepsCountView.text = @"0";
        _targetRateView.text = @"0.00";
        _distanceView.text = @"0.00";
        _calorieView.text = @"0.0";
        _speedView.text = @"0.00";
        _actTimeView.text = @"00:00:00";
        
        [_myAppDelegate writeToPeripheral:@"F702"];
    }else{
        NSLog(@"cancel cancel!");
    }
    
}

@end
