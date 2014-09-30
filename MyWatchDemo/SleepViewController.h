//
//  SleepViewController.h
//  MyWatchDemo
//
//  Created by maginawin on 14-8-28.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNLineChartView.h"

@interface SleepViewController : UIViewController
@property (weak, nonatomic) IBOutlet PNLineChartView *sleepChartView;
//根据传入的sleepValue & timeFrame来绘制睡眠监测图形
- (void)strokeSleepChartViewWithSpleepValue:(NSArray*)sleepValue andTimeFrame:(NSArray*)tiemFrame;
@end
