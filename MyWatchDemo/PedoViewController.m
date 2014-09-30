//
//  PedoViewController.m
//  MyWatchDemo
//
//  Created by maginawin on 14-8-21.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import "PedoViewController.h"

@interface PedoViewController ()
- (IBAction)ScanBleDevice:(id)sender;//查找设备
@property (weak, nonatomic) IBOutlet UITableView *deviceTableView;//显示设备列表
@property (nonatomic, assign) WWDAppDelegate* myAppDelegate;

@property (nonatomic) double startTime;
@property (nonatomic) double endTime;
@property (nonatomic) double pauseTime;
@property (nonatomic) double pauseTimeDiff;
@property (nonatomic) long timeLong;

@property (strong, nonatomic) UIColor* yellowColor;
@property (strong, nonatomic) UIColor* writeColor;

@end

@implementation PedoViewController

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
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_tran"] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent];
    
    _deviceTableView.delegate = self;
    _deviceTableView.dataSource = self;
    
    _yellowColor = [UIColor colorWithRed:255.0/255 green:153.0/255 blue:0.0 alpha:1.0f];
    _writeColor = [UIColor colorWithRed:255.0/255 green:1.0f blue:1.0f alpha:1.0f];
    
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"myDidDiscoverPeripheral" object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myDidDiscoverPeripheral:) name:@"myDidDiscoverPeripheral" object:nil];
//    
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"myDidConnectPeripheral" object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myDidConnectPeripheral:) name:@"myDidConnectPeripheral" object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"myDidDisconnectPeripheral" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myDidDisconnectPeripheral:) name:@"myDidDisconnectPeripheral" object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"pedometer" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pedometer:) name:@"pedometer" object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//tableview的方法,返回section个数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//tableview的方法,返回rows(行数)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_myAppDelegate.myPeripherals count];
}

//tableview的方法,返回cell的view
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //为表格定义一个静态字符串作为标识符
    static NSString* cellId = @"cellId";
    //从IndexPath中取当前行的行号
    NSUInteger rowNo = indexPath.row;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    UILabel* labelUUID = (UILabel*)[cell viewWithTag:1];
    
    NSString* uuid = [NSString stringWithFormat:@"%@", [[_myAppDelegate.myPeripherals objectAtIndex:rowNo] identifier]];
    uuid = [uuid substringFromIndex:[uuid length] - 12];
    NSLog(@"%@", uuid);
    labelUUID.text = uuid;
    
    return cell;
}

//tableview的方法,点击行时触发
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger rowNo = indexPath.row;
    //    NSLog(@"%lu", (unsigned long)rowNo);
    _deviceTableView.hidden = YES;

    _myAppDelegate.myPeripheral = [_myAppDelegate.myPeripherals objectAtIndex:rowNo];
    [_myAppDelegate connectClick];
}

//查找设备
- (IBAction)ScanBleDevice:(id)sender {
    
    [_myAppDelegate.myCentralManager stopScan];
    
    if(_myAppDelegate.myPeripherals != nil){
        _myAppDelegate.myPeripherals = nil;
        _myAppDelegate.myPeripheral = nil;
        _myAppDelegate.myPeripherals = [NSMutableArray array];
        [_deviceTableView reloadData];
    }
    
    [_deviceTableView setHidden:NO];
    
    [_myAppDelegate scanClick];    
   
}




- (void)myDidDisconnectPeripheral:(NSNotification*)myNotification{
    
    NSLog(@"收到断线通知而已");
    
    [_connectStateImage setHidden:NO];
}

- (void)pedometer:(NSNotification*)myNotification{
    
    NSLog(@"收到pedometer通知而已");
    
    NSString* pedometerString = [myNotification object];
    
    _pedometerView.text = pedometerString;
    _distanceView.text = [WWDTools getDistanceDefaultFromSteps:pedometerString];
}

- (IBAction)startPedometer:(id)sender {

    [_myAppDelegate writeToPeripheral:@"F701"];
    
//     [_startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    if([_timer isValid]){
        [_timer setFireDate:[NSDate date]];
    }else{
        _startTime = (double)[[NSDate date]timeIntervalSince1970];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countTimer:) userInfo:nil repeats:YES];
    }
    if(_pauseTime > 0){
        _pauseTimeDiff = (double)[[NSDate date]timeIntervalSince1970] - _pauseTime;
    }else{
        _pauseTimeDiff = 0;
    }
    _pauseTime = 0;
    [_startButton setEnabled:NO];
    [_pauseButton setEnabled:YES];
    [_stopButton setEnabled:YES];
}

- (IBAction)pausePedometer:(id)sender {

        [_myAppDelegate writeToPeripheral:@"F703"];

    _pauseTime = (double)[[NSDate date]timeIntervalSince1970];
    
    if(_timer){
        if([_timer isValid]){
            [_timer setFireDate:[NSDate distantFuture]];
        }
    }
    [_startButton setEnabled:YES];
    [_pauseButton setEnabled:NO];
    [_stopButton setEnabled:YES];
}

- (IBAction)stopPedometer:(id)sender {

        [_myAppDelegate writeToPeripheral:@"F703"];

    if(_timer){
        if([_timer isValid]){
            [_timer invalidate];
        }
    }
    _pauseTime = 0;
    _timer = nil;
    [_startButton setEnabled:YES];
    [_pauseButton setEnabled:YES];
    [_stopButton setEnabled:NO];
}

- (IBAction)clearPedometer:(id)sender {

        [_myAppDelegate writeToPeripheral:@"F702"];
    _pedometerView.text = @"0";
    _distanceView.text = @"0";
    _timerView.text = @"00:00:00";
    if(_timer){
        if([_timer isValid]){
            [_timer invalidate];
        }
        _timer = nil;
    }
    _pauseTime = 0;
    [_startButton setEnabled:YES];
    [_pauseButton setEnabled:YES];
    [_stopButton setEnabled:YES];
}

- (void)countTimer:(NSTimer*)_timer{
    
    _endTime = (double)[[NSDate date]timeIntervalSince1970];
    _timeLong = (long)_endTime - _startTime - _pauseTimeDiff;
    NSString* timeString = [WWDTools getHHMMSSFromSeconds:_timeLong];
    _timerView.text = timeString;
    
}
@end
