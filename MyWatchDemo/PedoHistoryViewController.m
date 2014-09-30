//
//  PedoHistoryViewController.m
//  MyWatchDemo
//
//  Created by maginawin on 14-9-16.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import "PedoHistoryViewController.h"

@interface PedoHistoryViewController ()
@property (nonatomic, assign) WWDAppDelegate* myAppDelegate;

@end

@implementation PedoHistoryViewController
NSMutableArray* recordTimeArray;
NSMutableArray* recordValueArray;
NSMutableArray* recordTagArray;
NSMutableArray* recordTimeArrayDist;
NSMutableArray* recordValueArrayDist;
NSMutableArray* recordTimeArrayCal;
NSMutableArray* recordValueArrayCal;
NSMutableArray* recordTimeArrayTime;
NSMutableArray* recordValueArrayTime;

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
    recordTagArray = [NSMutableArray array];
    
    recordTimeArrayDist = [NSMutableArray array];
    recordValueArrayDist = [NSMutableArray array];
    
    recordTimeArrayCal = [NSMutableArray array];
    recordValueArrayCal = [NSMutableArray array];
    
    recordTimeArrayTime = [NSMutableArray array];
    recordValueArrayTime = [NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated{
    [recordTimeArray removeAllObjects];
    [recordValueArray removeAllObjects];
    [recordTagArray removeAllObjects];
    [recordTimeArrayDist removeAllObjects];
    [recordValueArrayDist removeAllObjects];
    [recordValueArrayCal removeAllObjects];
    [recordTimeArrayCal removeAllObjects];
    [recordValueArrayTime removeAllObjects];
    [recordTimeArrayTime removeAllObjects];
    
    
    [self setStepHistory];
    [self setDistHistory];
    [self setCalHistory];
    [self setTimeHistory];
    [self.segmentTag setSelectedSegmentIndex:0];
    [self strokeSleepChartViewWithSpleepValue:recordValueArray andTimeFrame:recordTimeArray];
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
}

- (void)viewDidDisappear:(BOOL)animated{
    NSLog(@"view did disapper");
    [self.pedoChart clearPlot];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)segmentChanged:(id)sender {
    switch ([sender selectedSegmentIndex]) {
        //steps
        case 0:
        {
            [self.pedoChart clearPlot];
            [self setStepHistory];
            NSLog(@"recordvalue array : %d",recordValueArray.count);
            [self strokeSleepChartViewWithSpleepValue:recordValueArray andTimeFrame:recordTimeArray];
            break;
        }
        //distance
        case 1:
        {
            NSLog(@"选了distance %d",recordValueArrayDist.count);
            [self.pedoChart clearPlot];
            [self setDistHistory];
            [self strokeDistanceChartViewWithSpleepValue:recordValueArrayDist andTimeFrame:recordTimeArrayDist];
            break;
        }
        //calorie
        case 2:
        {
            NSLog(@"选了cal %d",recordValueArrayCal.count);
            [self.pedoChart clearPlot];
            [self setCalHistory];
            [self strokeCalorieChartViewWithSpleepValue:recordValueArrayCal andTimeFrame:recordTimeArrayCal];
            break;
        }
        //time
        case 3:
        {
            NSLog(@"选了time %d",recordValueArrayTime.count);
            [self.pedoChart clearPlot];
            [self setTimeHistory];
            [self strokeTimeChartViewWithSpleepValue:recordValueArrayTime andTimeFrame:recordTimeArrayTime];
            break;
        }
        default:
            break;
    }
}

- (IBAction)deleteRecord:(id)sender {
    UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"Whether to delete all record of pedometer?" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:@"confirm" otherButtonTitles:nil, nil];
    sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSFetchRequest* request = [[NSFetchRequest alloc]init];
        NSEntityDescription* entity = [NSEntityDescription entityForName:@"PedoStepHistory" inManagedObjectContext:self.myAppDelegate.managedObjectContext];
        [request setEntity:entity];
        NSError* error = nil;
        NSArray* historyArray = [[self.myAppDelegate.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
        if(historyArray.count > 0){
            for (int i = 0; i < historyArray.count; i++) {
                PedoHistory* ph = [historyArray objectAtIndex:historyArray.count - 1 - i];
                [self.myAppDelegate.managedObjectContext deleteObject:ph];
                NSLog(@"删除step成功:%d",i);
            }
            [self.myAppDelegate saveContext];
        }else{
            NSLog(@"已经没有历史记录可以删除了!");
        }
        entity = [NSEntityDescription entityForName:@"PedoDistHistory" inManagedObjectContext:self.myAppDelegate.managedObjectContext];
        [request setEntity:entity];
        historyArray = [[self.myAppDelegate.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
        if(historyArray.count > 0){
            for (int i = 0; i < historyArray.count; i++) {
                PedoHistory* ph = [historyArray objectAtIndex:historyArray.count - 1 - i];
                [self.myAppDelegate.managedObjectContext deleteObject:ph];
                NSLog(@"删除dist成功:%d",i);
            }
            [self.myAppDelegate saveContext];
        }else{
            NSLog(@"已经没有历史记录可以删除了!");
        }
        entity = [NSEntityDescription entityForName:@"PedoCalHistory" inManagedObjectContext:self.myAppDelegate.managedObjectContext];
        [request setEntity:entity];
        historyArray = [[self.myAppDelegate.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
        if(historyArray.count > 0){
            for (int i = 0; i < historyArray.count; i++) {
                PedoHistory* ph = [historyArray objectAtIndex:historyArray.count - 1 - i];
                [self.myAppDelegate.managedObjectContext deleteObject:ph];
                NSLog(@"删除cal成功:%d",i);
            }
            [self.myAppDelegate saveContext];
        }else{
            NSLog(@"已经没有历史记录可以删除了!");
        }
        entity = [NSEntityDescription entityForName:@"PedoTimeHistory" inManagedObjectContext:self.myAppDelegate.managedObjectContext];
        [request setEntity:entity];
        historyArray = [[self.myAppDelegate.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
        if(historyArray.count > 0){
            for (int i = 0; i < historyArray.count; i++) {
                PedoHistory* ph = [historyArray objectAtIndex:historyArray.count - 1 - i];
                [self.myAppDelegate.managedObjectContext deleteObject:ph];
                NSLog(@"删除time成功:%d",i);
            }
            [self.myAppDelegate saveContext];
        }else{
            NSLog(@"已经没有历史记录可以删除了!");
        }
        
        [recordValueArray removeAllObjects];
        [recordTimeArray removeAllObjects];
        [recordTimeArrayDist removeAllObjects];
        [recordValueArrayDist removeAllObjects];
        [recordValueArrayCal removeAllObjects];
        [recordTimeArrayCal removeAllObjects];
        [recordValueArrayTime removeAllObjects];
        [recordTimeArrayTime removeAllObjects];
        [self strokeSleepChartViewWithSpleepValue:recordValueArray andTimeFrame:recordTimeArray];
        [self strokeDistanceChartViewWithSpleepValue:recordValueArrayDist andTimeFrame:recordTimeArrayDist];
        [self strokeCalorieChartViewWithSpleepValue:recordValueArrayCal andTimeFrame:recordTimeArrayCal];
        [self strokeTimeChartViewWithSpleepValue:recordValueArrayTime andTimeFrame:recordTimeArrayTime];
    }else{
        NSLog(@"cancel  cancel!");
    }
}

- (void)setTimeHistory{
    [recordValueArrayTime removeAllObjects];
    [recordTimeArrayTime removeAllObjects];
    NSArray* historyArray = [self getHistoryArrayWith:@"PedoTimeHistory"];
    if(historyArray.count > 0){
        for (int i = 0; i < historyArray.count; i++) {
            PedoTimeHistory* pth = [historyArray objectAtIndex:i];
            NSString* value = [pth recordValue];
            NSString* timeStr = [WWDTools getHoursFromHHMMSS:value];
            [recordValueArrayTime addObject:timeStr];
            [recordTimeArrayTime addObject:[WWDTools stringFromIndexCount:5 count:5 from:[pth recordDate]]];
            NSLog(@"time value : %@,%@",timeStr,[WWDTools stringFromIndexCount:5 count:5 from:[pth recordDate]]);
        }
    }
}
- (void)setStepHistory{
    [recordValueArray removeAllObjects];
    [recordTimeArray removeAllObjects];
    NSArray* historyArray = [self getHistoryArrayWith:@"PedoStepHistory"];
    if(historyArray.count > 0){
        for (int i = 0; i < historyArray.count; i++) {
            PedoStepHistory* pth = [historyArray objectAtIndex:i];
            NSString* value = [pth recordValue];
            [recordValueArray addObject:value];
            [recordTimeArray addObject:[WWDTools stringFromIndexCount:5 count:5 from:[pth recordDate]]];
            NSLog(@"setp value : %@,%@", value,[WWDTools stringFromIndexCount:5 count:5 from:[pth recordDate]]);
        }
    }
}
- (void)setDistHistory{
    [recordTimeArrayDist removeAllObjects];
    [recordValueArrayDist removeAllObjects];
    NSArray* historyArray = [self getHistoryArrayWith:@"PedoDistHistory"];
    if(historyArray.count > 0){
        for (int i = 0; i < historyArray.count; i++) {
            PedoDistHistory* pth = [historyArray objectAtIndex:i];
            NSString* value = [pth recordValue];
            NSInteger valueInt = [WWDTools intFromHexString:value];
            double distValueDouble = valueInt / 100;
            NSString* distValue = [NSString stringWithFormat:@"%.2f",distValueDouble];
            [recordValueArrayDist addObject:distValue];
            [recordTimeArrayDist addObject:[WWDTools stringFromIndexCount:5 count:5 from:[pth recordDate]]];
            NSLog(@"dist value : %@,%@", distValue,[WWDTools stringFromIndexCount:5 count:5 from:[pth recordDate]]);
        }
    }
}
- (void)setCalHistory{
    [recordValueArrayCal removeAllObjects];
    [recordTimeArrayCal removeAllObjects];
    NSArray* historyArray = [self getHistoryArrayWith:@"PedoCalHistory"];
    if(historyArray.count > 0){
        for (int i = 0; i < historyArray.count; i++) {
            PedoCalHistory* pch = [historyArray objectAtIndex:i];
            NSString* value = [pch recordValue];
            [recordValueArrayCal addObject:value];
            [recordTimeArrayCal addObject:[WWDTools stringFromIndexCount:5 count:5 from:[pch recordDate]]];
            NSLog(@"cal value : %@,%@",value,[WWDTools stringFromIndexCount:5 count:5 from:[pch recordDate]]);
        }
    }
}

- (NSArray*)getHistoryArrayWith:(NSString*)domainName{
    NSArray* historyArray = [NSArray array];
    NSFetchRequest* request = [[NSFetchRequest alloc]init];
    NSEntityDescription* entity = [NSEntityDescription entityForName:[NSString stringWithFormat:@"%@",domainName] inManagedObjectContext:self.myAppDelegate.managedObjectContext];
    [request setEntity:entity];
    //    request.predicate = [NSPredicate predicateWithFormat:@"order by recordDate"];
    NSError* error = nil;
    NSArray* historyArray0 = [[self.myAppDelegate.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
    NSLog(@"history array count : %d",historyArray0.count);
    if (historyArray0 > 0) {
        NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"recordDate" ascending:YES];
        NSArray* sortDescriptors = [NSArray arrayWithObjects:firstDescriptor, nil];
        historyArray = [historyArray0 sortedArrayUsingDescriptors:sortDescriptors];
    }
    return historyArray;
}

- (void)strokeSleepChartViewWithSpleepValue:(NSArray*)sleepValue andTimeFrame:(NSArray*)timeFrame{
    NSArray* plottingDataValue = sleepValue;
    self.pedoChart.max = 20000;
    self.pedoChart.min = 0;
    
    self.pedoChart.interval = (self.pedoChart.max - self.pedoChart.min) / 5;
    NSMutableArray* yAxisValues = [@[] mutableCopy];
    for(int i = 0; i < 6; i++){
        NSString* str = [NSString stringWithFormat:@"%f", self.pedoChart.min + self.pedoChart.interval*i];
        [yAxisValues addObject:str];
    }
    
    self.pedoChart.xAxisValues = timeFrame;
    self.pedoChart.yAxisValues = yAxisValues;
    self.pedoChart.axisLeftLineWidth = 50;
    
    PNPlot* plot = [[PNPlot alloc]init];
    plot.plottingValues = plottingDataValue;
    
    plot.lineColor = [UIColor yellowColor];
    plot.lineWidth = 2;
    [self.pedoChart addPlot:plot];
    [self.pedoChart setNeedsDisplay];
    
}

- (void)strokeDistanceChartViewWithSpleepValue:(NSArray*)sleepValue andTimeFrame:(NSArray*)timeFrame{
    NSArray* plottingDataValue = sleepValue;
    self.pedoChart.max = 20;
    self.pedoChart.min = 0;
    
    self.pedoChart.interval = (self.pedoChart.max - self.pedoChart.min) / 5;
    NSMutableArray* yAxisValues = [@[] mutableCopy];
    for(int i = 0; i < 6; i++){
        NSString* str = [NSString stringWithFormat:@"%f", self.pedoChart.min + self.pedoChart.interval*i];
        [yAxisValues addObject:str];
    }
    
    self.pedoChart.xAxisValues = timeFrame;
    self.pedoChart.yAxisValues = yAxisValues;
    self.pedoChart.axisLeftLineWidth = 32;
    
    PNPlot* plot = [[PNPlot alloc]init];
    plot.plottingValues = plottingDataValue;
    
    plot.lineColor = [UIColor yellowColor];
    plot.lineWidth = 2;
    [self.pedoChart addPlot:plot];
    [self.pedoChart setNeedsDisplay];
    
}

- (void)strokeCalorieChartViewWithSpleepValue:(NSArray*)sleepValue andTimeFrame:(NSArray*)timeFrame{
    NSArray* plottingDataValue = sleepValue;
    self.pedoChart.max = 2500;
    self.pedoChart.min = 0;
    
    self.pedoChart.interval = (self.pedoChart.max - self.pedoChart.min) / 5;
    NSMutableArray* yAxisValues = [@[] mutableCopy];
    for(int i = 0; i < 6; i++){
        NSString* str = [NSString stringWithFormat:@"%f", self.pedoChart.min + self.pedoChart.interval*i];
        [yAxisValues addObject:str];
    }
    
    self.pedoChart.xAxisValues = timeFrame;
    self.pedoChart.yAxisValues = yAxisValues;
    self.pedoChart.axisLeftLineWidth = 42;
    
    PNPlot* plot = [[PNPlot alloc]init];
    plot.plottingValues = plottingDataValue;
    
    plot.lineColor = [UIColor yellowColor];
    plot.lineWidth = 2;
    [self.pedoChart addPlot:plot];
    [self.pedoChart setNeedsDisplay];
    
}

- (void)strokeTimeChartViewWithSpleepValue:(NSArray*)sleepValue andTimeFrame:(NSArray*)timeFrame{
    NSArray* plottingDataValue = sleepValue;
    self.pedoChart.max = 8;
    self.pedoChart.min = 0;
    
    self.pedoChart.interval = (self.pedoChart.max - self.pedoChart.min) / 4;
    NSMutableArray* yAxisValues = [@[] mutableCopy];
    for(int i = 0; i < 6; i++){
        NSString* str = [NSString stringWithFormat:@"%f", self.pedoChart.min + self.pedoChart.interval*i];
        [yAxisValues addObject:str];
    }
    
    self.pedoChart.xAxisValues = timeFrame;
    self.pedoChart.yAxisValues = yAxisValues;
    self.pedoChart.axisLeftLineWidth = 32;
    
    PNPlot* plot = [[PNPlot alloc]init];
    plot.plottingValues = plottingDataValue;
    
    plot.lineColor = [UIColor yellowColor];
    plot.lineWidth = 2;
    [self.pedoChart addPlot:plot];
    [self.pedoChart setNeedsDisplay];
    
}

@end
