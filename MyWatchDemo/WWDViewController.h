//
//  WWDViewController.h
//  MyWatchDemo
//
//  Created by maginawin on 14-8-20.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WWDTools.h"
#import "WWDAppDelegate.h"

@interface WWDViewController : UIViewController<UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIView *connectStateView0;
@property (weak, nonatomic) IBOutlet UIView *connectStateView1;
@property (weak, nonatomic) IBOutlet UIView *connectStateView2;
@property (weak, nonatomic) IBOutlet UIView *connectStateView3;
@property (weak, nonatomic) IBOutlet UIView *connectStateView4;
@property (weak, nonatomic) IBOutlet UIView *connectStateView5;
@property (weak, nonatomic) IBOutlet UILabel *stepsCountView;
@property (weak, nonatomic) IBOutlet UILabel *targetRateView;
@property (weak, nonatomic) IBOutlet UILabel *distanceView;
@property (weak, nonatomic) IBOutlet UILabel *calorieView;
@property (weak, nonatomic) IBOutlet UILabel *speedView;
@property (weak, nonatomic) IBOutlet UILabel *actTimeView;
- (IBAction)clearData:(id)sender;

@end
