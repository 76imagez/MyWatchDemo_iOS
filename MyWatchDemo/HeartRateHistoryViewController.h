//
//  HeartRateHistoryViewController.h
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

@interface HeartRateHistoryViewController : UIViewController<UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet MyLineChartView *heartRateChart;
- (void)strokeSleepChartViewWithSpleepValue:(NSArray*)sleepValue andTimeFrame:(NSArray*)timeFrame;

- (IBAction)deleteRecord:(id)sender;
- (IBAction)back:(id)sender;

@end
