//
//  SleepHistoryViewController.m
//  MyWatchDemo
//
//  Created by maginawin on 14-9-16.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import "SleepHistoryViewController.h"

@interface SleepHistoryViewController ()
@property (nonatomic, assign) WWDAppDelegate* myAppDelegate;

@end

@implementation SleepHistoryViewController
NSMutableArray* recordTimeArray;
NSMutableArray* recordValueArray;


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
    recordTimeArray = [NSMutableArray array];
    recordValueArray = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated{
    [recordTimeArray removeAllObjects];
    [recordValueArray removeAllObjects];
    NSFetchRequest* request = [[NSFetchRequest alloc]init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"SleepMonitorHistory" inManagedObjectContext:self.myAppDelegate.managedObjectContext];
    [request setEntity:entity];
    NSError* error = nil;
    NSArray* historyArray = [[self.myAppDelegate.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
    NSLog(@"history array count : %d",historyArray.count);
    if(historyArray.count > 0){
        for (int i = 0; i < historyArray.count; i++) {
            SleepMonitorHistory* smh = [historyArray objectAtIndex:historyArray.count - 1 - i];
            [recordValueArray addObject:[WWDTools getSleepQualityWithValue:[smh recordValue]]];
            [recordTimeArray addObject:[WWDTools stringFromIndexCount:5 count:5 from:[smh recordDate]]];
        }
        [self strokeSleepChartViewWithSpleepValue:recordValueArray andTimeFrame:recordTimeArray];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
}

- (void)viewDidDisappear:(BOOL)animated{
    NSLog(@"view did disapper");
    [self.sleepChart clearPlot];
    [self.sleepChart setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.    
}

- (void)strokeSleepChartViewWithSpleepValue:(NSArray *)sleepValue andTimeFrame:(NSArray *)timeFrame{
    NSArray* plottingDataValue = sleepValue;
    self.sleepChart.max = 5;
    self.sleepChart.min = 0;
    
    self.sleepChart.interval = (self.sleepChart.max - self.sleepChart.min) / 5;
    NSMutableArray* yAxisValues = [@[] mutableCopy];
    for(int i = 0; i < 6; i++){
        NSString* str = [NSString stringWithFormat:@"%.1f", self.sleepChart.min + self.sleepChart.interval*i];
        [yAxisValues addObject:str];
    }
    
    self.sleepChart.xAxisValues = timeFrame;
    self.sleepChart.yAxisValues = yAxisValues;
    self.sleepChart.axisLeftLineWidth = 28;
    
    PNPlot* plot = [[PNPlot alloc]init];
    plot.plottingValues = plottingDataValue;
    
    plot.lineColor = [UIColor yellowColor];
    plot.lineWidth = 2;
    [self.sleepChart addPlot:plot];
    [self.sleepChart setNeedsDisplay];
}

//确认删除所有历史记录
- (IBAction)deleteRecord:(id)sender {
    UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"Whether to delete all record of sleep monitor?" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:@"confirm" otherButtonTitles:nil, nil];
    sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [sheet showInView:self.view];
}

//UIActionSheet*的Delegate事件
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSFetchRequest* request = [[NSFetchRequest alloc]init];
        NSEntityDescription* entity = [NSEntityDescription entityForName:@"SleepMonitorHistory" inManagedObjectContext:self.myAppDelegate.managedObjectContext];
        [request setEntity:entity];
        NSError* error = nil;
        NSArray* historyArray = [[self.myAppDelegate.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
        if(historyArray.count > 0){
            for (int i = 0; i < historyArray.count; i++) {
                SleepMonitorHistory* smh = [historyArray objectAtIndex:historyArray.count - 1 - i];
                [self.myAppDelegate.managedObjectContext deleteObject:smh];
            }
            if(![self.myAppDelegate.managedObjectContext save:&error]){
                NSLog(@"删除历史记录失败!");
            }
            [recordValueArray removeAllObjects];
            [recordTimeArray removeAllObjects];
            [self strokeSleepChartViewWithSpleepValue:recordValueArray andTimeFrame:recordTimeArray];
        }else{
            NSLog(@"已经没有历史记录可以删除了!");
        }
    }else{
        NSLog(@"cancel cancel!");
    }
    
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
