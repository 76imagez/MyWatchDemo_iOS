//
//  ConnectViewController.m
//  MyWatchDemo
//
//  Created by maginawin on 14-8-29.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import "ConnectViewController.h"
#import "WWDAppDelegate.h"

@interface ConnectViewController ()

@property (nonatomic, assign) WWDAppDelegate* myAppDelegate;
@property (nonatomic, strong) UIColor* yellow;

- (void)scanBle;

@end

@implementation ConnectViewController

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
    
    _periphearlsTableView.delegate = self;
    _periphearlsTableView.dataSource = self;
    
    _yellow = [UIColor colorWithRed:255.0/255 green:226.0/255 blue:80.0/255 alpha:0.9f];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"myDidDiscoverPeripheral" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(myDidDiscoverPeripheral:) name:@"myDidDiscoverPeripheral" object:nil];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"myDidDisconnectPeripheral" object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [self scanBle];
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
    
    UILabel* labelName = (UILabel*)[cell viewWithTag:1];
    UILabel* labelUUID = (UILabel*)[cell viewWithTag:2];
    
    NSString* name = [NSString stringWithFormat:@"%@", [[_myAppDelegate.myPeripherals objectAtIndex:rowNo]name]];
    NSString* uuid = [NSString stringWithFormat:@"%@", [[_myAppDelegate.myPeripherals objectAtIndex:rowNo] identifier]];
    uuid = [uuid substringFromIndex:[uuid length] - 12];
    labelName.text = name;
    labelUUID.text = uuid;
    
    return cell;
}

//tableview的方法,点击行时触发
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger rowNo = indexPath.row;
    _myAppDelegate.myPeripheral = [_myAppDelegate.myPeripherals objectAtIndex:rowNo];
    [_myAppDelegate connectClick];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)reScanBle:(id)sender {
    [self scanBle];
}

- (void)scanBle{
    [_myAppDelegate.myCentralManager stopScan];
    if(_myAppDelegate.myPeripherals != nil){
        _myAppDelegate.myPeripherals = nil;
        _myAppDelegate.myPeripheral = nil;
        _myAppDelegate.myPeripherals = [NSMutableArray array];
        [_periphearlsTableView reloadData];
    }
    
    [_myAppDelegate scanClick];
}

- (void)myDidDiscoverPeripheral:(NSNotification*)myNotification{
    [_periphearlsTableView reloadData];
}
@end
