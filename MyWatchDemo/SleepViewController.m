//
//  SleepViewController.m
//  MyWatchDemo
//
//  Created by maginawin on 14-8-28.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import "SleepViewController.h"
#import "WWDAppDelegate.h"
#import "PNLineChartView.h"
#import "PNPlot.h"

@interface SleepViewController ()

@property (nonatomic, assign) WWDAppDelegate* myAppDelegate;

@end

@implementation SleepViewController


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
    _myAppDelegate = (WWDAppDelegate*)[[UIApplication sharedApplication]delegate];

    [self strokeSleepChartViewWithSpleepValue:nil andTimeFrame:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    
}

- (void)viewWillDisappear:(BOOL)animated{

}

- (void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"camera" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cameraJump:) name:@"camera" object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"todaySleepMonitor" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(todaySleepMonitor:) name:@"todaySleepMonitor" object:nil];
    
    //发送请求今天的睡眠数据的请求
    [_myAppDelegate writeToPeripheral:@"FEAA"];
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"camera" object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"todaySleepMonitor" object:nil];
    
    [self.sleepChartView clearPlot];
    [self.sleepChartView setNeedsDisplay];
}

//收到今天的睡眠监测数据后的回调方法
- (void)todaySleepMonitor:(NSNotification*)myNotification{
    NSString* value = [myNotification object];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    //前一天的数据
    NSString* startTime = [defaults stringForKey:@"sleepMonitorStartTime"];
    //默认前一天从22点开始
    NSInteger  start = 22;
    NSMutableArray* startTimeArray = [NSMutableArray array];
    NSMutableArray* startValueArray = [NSMutableArray array];
    if(startTime != nil){
        start = [[WWDTools stringFromIndexCount:0 count:2 from:startTime] integerValue];
        //从数据库中取出前一天的数据
        NSTimeInterval secondsPerDay = 24 * 60 * 60;
        NSDate* date = [NSDate date] ;
        NSString* myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay]]];
        NSFetchRequest* request = [[NSFetchRequest alloc]init];
        NSEntityDescription* entity = [NSEntityDescription entityForName:@"SleepMonitorHistory" inManagedObjectContext:self.myAppDelegate.managedObjectContext];
        [request setEntity:entity];
        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
        NSError* error = nil;
        NSArray* historyArray = [[self.myAppDelegate.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
        NSLog(@"当前的昨天的记录是 : %d条",[historyArray count]);
        if (historyArray.count > 0) {
            SleepMonitorHistory* historyData = [historyArray objectAtIndex:0];
            NSString* historyValue = [historyData recordValue];
            for (int i = (int)start; i < 24; i++) {
                [startTimeArray addObject:[NSString stringWithFormat:@"%d",i]];
                [startValueArray addObject:[WWDTools stringFromIndexCount:i count:1 from:historyValue]];
            }
        }else{
            for(int i = 0; i < 24 - start; i++){
                [startTimeArray addObject:[NSString stringWithFormat:@"%d",(start + i)]];
                //请求数据库中的数,现用随机数替代
                [startValueArray addObject:[NSString stringWithFormat:@"%d",arc4random()%6]];
            }
        }
    }else {
        for(int i = (int)start; i < 24; i++){
            [startTimeArray addObject:[NSString stringWithFormat:@"%d",i]];
            //请求数据库中的数,现用随机数替代
            NSTimeInterval secondsPerDay = 24 * 60 * 60;
            NSDate* date = [NSDate date];
            NSString* myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay]]];
            NSFetchRequest* request = [[NSFetchRequest alloc]init];
            NSEntityDescription* entity = [NSEntityDescription entityForName:@"SleepMonitorHistory" inManagedObjectContext:self.myAppDelegate.managedObjectContext];
            [request setEntity:entity];
            request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
            NSError* error = nil;
            NSArray* historyArray = [[self.myAppDelegate.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
            NSLog(@"当前的昨天的记录是: %d条",[historyArray count]);
            if (historyArray.count > 0) {
                SleepMonitorHistory* historyData = [historyArray objectAtIndex:0];
                NSString* historyValue = [historyData recordValue];
                for (int i = (int)start; i < 24; i++) {
                    [startTimeArray addObject:[NSString stringWithFormat:@"%d",i]];
                    [startValueArray addObject:[WWDTools stringFromIndexCount:i count:1 from:historyValue]];
                }
            }else{
                for(int i = 0; i < 24 - start; i++){
                    [startTimeArray addObject:[NSString stringWithFormat:@"%d",(start + i)]];
                    //请求数据库中的数,现用随机数替代
                    [startValueArray addObject:[NSString stringWithFormat:@"%d",arc4random()%6]];
                }
            }
        }
    }
    
    //今天的数据
    NSString* endTime = [defaults stringForKey:@"sleepMonitorEndTime"];
    //默认今天从8点结束
    NSInteger end = 8;
    if(endTime != nil){
        end = [[WWDTools stringFromIndexCount:0 count:2 from:endTime] integerValue];
    }
    NSMutableArray* endTimeArray = [NSMutableArray array];
    NSMutableArray* endValueArray = [NSMutableArray array];
    NSString* endSleepMonitor = [WWDTools stringFromIndexCount:6 count:24 from:value];
    for (int i = 0; i <= end; i++) {
         [endTimeArray addObject:[NSString stringWithFormat:@"%d",i]];
         [endValueArray addObject:[WWDTools stringFromIndexCount:i count:1 from:endSleepMonitor]];
    }
    
    [startTimeArray addObjectsFromArray:endTimeArray];
    [startValueArray addObjectsFromArray:endValueArray];
    
    [self.sleepChartView clearPlot];
    [self strokeSleepChartViewWithSpleepValue:startValueArray andTimeFrame:startTimeArray];
    
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

- (void)strokeSleepChartViewWithSpleepValue:(NSArray *)sleepValue andTimeFrame:(NSArray *)timeFrame{
    NSArray* plottingDataValue = sleepValue;
    self.sleepChartView.max = 5;
    self.sleepChartView.min = 0;
    
    self.sleepChartView.interval = (self.sleepChartView.max - self.sleepChartView.min) / 5;
    NSMutableArray* yAxisValues = [@[] mutableCopy];
    for(int i = 0; i < 6; i++){
        NSString* str = [NSString stringWithFormat:@"%.1f", self.sleepChartView.min + self.sleepChartView.interval*i];
        [yAxisValues addObject:str];
    }
    
    self.sleepChartView.xAxisValues = timeFrame;
    self.sleepChartView.yAxisValues = yAxisValues;
    self.sleepChartView.axisLeftLineWidth = 28;
    
    PNPlot* plot = [[PNPlot alloc]init];
    plot.plottingValues = plottingDataValue;
    
    plot.lineColor = [UIColor yellowColor];
    plot.lineWidth = 2;
    [self.sleepChartView addPlot:plot];
    [self.sleepChartView setNeedsDisplay];
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
