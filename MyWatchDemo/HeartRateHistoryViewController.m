//
//  HeartRateHistoryViewController.m
//  MyWatchDemo
//
//  Created by maginawin on 14-9-16.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import "HeartRateHistoryViewController.h"

@interface HeartRateHistoryViewController ()
@property (nonatomic, assign) WWDAppDelegate* myAppDelegate;

@end

@implementation HeartRateHistoryViewController
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
    NSEntityDescription* entity = [NSEntityDescription entityForName:@"HeartRateHistory" inManagedObjectContext:self.myAppDelegate.managedObjectContext];
    [request setEntity:entity];
    NSError* error = nil;
    NSArray* historyArray = [[self.myAppDelegate.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
    NSLog(@"history array count : %d",historyArray.count);
    if(historyArray.count > 0){
        for (int i = 0; i < historyArray.count; i++) {
            HeartRateHistory* hrh = [historyArray objectAtIndex:historyArray.count - 1 - i];
            NSInteger valueInt = [WWDTools intFromHexString:[WWDTools stringFromIndexCount:0 count:2 from:[hrh recordValue]]];
            [recordValueArray addObject:[NSString stringWithFormat:@"%d", valueInt]];
            [recordTimeArray addObject:[WWDTools stringFromIndexCount:5 count:5 from:[hrh recordDate]]];
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
    [self.heartRateChart clearPlot];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteRecord:(id)sender {
    UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"Whether to delete all record of heart rate?" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:@"confirm" otherButtonTitles:nil, nil];
    sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        NSFetchRequest* request = [[NSFetchRequest alloc]init];
        NSEntityDescription* entity = [NSEntityDescription entityForName:@"HeartRateHistory" inManagedObjectContext:self.myAppDelegate.managedObjectContext];
        [request setEntity:entity];
        NSError* error = nil;
        NSArray* historyArray = [[self.myAppDelegate.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
        if(historyArray.count > 0){
            for (int i = 0; i < historyArray.count; i++) {
                HeartRateHistory* smh = [historyArray objectAtIndex:historyArray.count - 1 - i];
                [self.myAppDelegate.managedObjectContext deleteObject:smh];
            }
            [self.myAppDelegate saveContext];
            [recordValueArray removeAllObjects];
            [recordTimeArray removeAllObjects];
            [self strokeSleepChartViewWithSpleepValue:recordValueArray andTimeFrame:recordTimeArray];
        }else{
            NSLog(@"已经没有历史记录可以删除了!");
        }
    }else{
        NSLog(@"cancel  cancel!");
    }
}

- (void)strokeSleepChartViewWithSpleepValue:(NSArray*)sleepValue andTimeFrame:(NSArray*)timeFrame{
    NSArray* plottingDataValue = sleepValue;
    self.heartRateChart.max = 250;
    self.heartRateChart.min = 0;
    
    self.heartRateChart.interval = (self.heartRateChart.max - self.heartRateChart.min) / 5;
    NSMutableArray* yAxisValues = [@[] mutableCopy];
    for(int i = 0; i < 6; i++){
        NSString* str = [NSString stringWithFormat:@"%f", self.heartRateChart.min + self.heartRateChart.interval*i];
        [yAxisValues addObject:str];
    }
    
    self.heartRateChart.xAxisValues = timeFrame;
    self.heartRateChart.yAxisValues = yAxisValues;
    self.heartRateChart.axisLeftLineWidth = 40;
    
    PNPlot* plot = [[PNPlot alloc]init];
    plot.plottingValues = plottingDataValue;
    
    plot.lineColor = [UIColor yellowColor];
    plot.lineWidth = 2;
    [self.heartRateChart addPlot:plot];
    [self.heartRateChart setNeedsDisplay];

}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
