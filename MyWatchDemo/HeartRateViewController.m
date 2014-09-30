//
//  HeartRateViewController.m
//  MyWatchDemo
//
//  Created by maginawin on 14-8-28.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import "HeartRateViewController.h"

@interface HeartRateViewController ()

@end

@implementation HeartRateViewController

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
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"heartRate" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(heartRate:) name:@"heartRate" object:nil];
    [_heartImageView setAnimationImages:[NSArray arrayWithObjects:[UIImage imageNamed:@"heart_rate_heart"],[UIImage imageNamed:@"heart_rate_heart_clear"], nil]];
    [_heartImageView setContentMode:UIViewContentModeScaleAspectFill];
}

- (void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"camera" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cameraJump:) name:@"camera" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"camera" object:nil];
}

- (void)cameraJump:(NSNotification*)myNotification{
    [self setHidesBottomBarWhenPushed:YES];
    [self performSegueWithIdentifier:@"cameraSegue" sender:self];
    [self setHidesBottomBarWhenPushed:NO];}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)heartRate:(NSNotification*)myNotification{
    
    NSLog(@"收到heartRate通知而已");
    
    NSString* heartRateValue = [myNotification object];
    
    NSString* heartRateCount = [WWDTools stringFromIndexCount:2 count:4 from:heartRateValue];
    NSInteger count = [WWDTools intFromHexString:heartRateCount];
    
    if(count == 0){
        if([_heartImageView isAnimating]){
            [_heartImageView stopAnimating];
        }
    }else{
        if(![_heartImageView isAnimating]){
            [_heartImageView setAnimationDuration:0.85];
            [_heartImageView startAnimating];
        }
    }
    
    NSString* heartRateMin = [WWDTools stringFromIndexCount:6 count:4 from:heartRateValue];
    NSInteger min = [WWDTools intFromHexString:heartRateMin];
    NSString* heartRateMax = [WWDTools stringFromIndexCount:10 count:4 from:heartRateValue];
    NSInteger max = [WWDTools intFromHexString:heartRateMax];
    
    _heartRateCount.text = [NSString stringWithFormat:@"%d", count];
    _minimum.text = [NSString stringWithFormat:@"%d", min];
    _maximum.text = [NSString stringWithFormat:@"%d", max];
    
    if ((_heartRateCount < _minimum || _heartRateCount > _maximum) && _heartRateCount != 0) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* disconnectedAlarmValue = [defaults stringForKey:@"heartRateAlarm"];
        if ([@"OFF" isEqual:disconnectedAlarmValue]) {
            
        }else{
            NSLog(@"%@", disconnectedAlarmValue);
            [WWDTools avAudioPlayerStartOnceFromWAV:@"heartRate"];
        }
    }    
}

@end
