//
//  PedoHistoryViewController.h
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

@interface PedoHistoryViewController : UIViewController<UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet MyLineChartView *pedoChart;
- (void)strokeSleepChartViewWithSpleepValue:(NSArray*)sleepValue andTimeFrame:(NSArray*)timeFrame;
- (void)strokeDistanceChartViewWithSpleepValue:(NSArray*)sleepValue andTimeFrame:(NSArray*)timeFrame;
- (void)strokeCalorieChartViewWithSpleepValue:(NSArray*)sleepValue andTimeFrame:(NSArray*)timeFrame;
- (void)strokeTimeChartViewWithSpleepValue:(NSArray*)sleepValue andTimeFrame:(NSArray*)timeFrame;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentTag;

- (IBAction)back:(id)sender;
- (IBAction)segmentChanged:(id)sender;
- (IBAction)deleteRecord:(id)sender;

- (NSArray*)getHistoryArrayWith:(NSString*)domainName;
- (void)setTimeHistory;
- (void)setStepHistory;
- (void)setDistHistory;
- (void)setCalHistory;

@end
