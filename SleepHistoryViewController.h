//
//  SleepHistoryViewController.h
//  MyWatchDemo
//
//  Created by maginawin on 14-9-16.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WWDTools.h"
#import "MyLineChartView.h"
#import "PNPlot.h"
#import "WWDAppDelegate.h"

@interface SleepHistoryViewController : UIViewController<UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet MyLineChartView *sleepChart;
- (IBAction)deleteRecord:(id)sender;
- (IBAction)back:(id)sender;
- (void)strokeSleepChartViewWithSpleepValue:(NSArray*)sleepValue andTimeFrame:(NSArray*)timeFrame;
@end
