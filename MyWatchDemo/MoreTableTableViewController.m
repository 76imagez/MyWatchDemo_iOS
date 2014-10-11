//
//  MoreTableTableViewController.m
//  MyWatchDemo
//
//  Created by maginawin on 14-9-3.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import "MoreTableTableViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CameraViewController.h"

@interface MoreTableTableViewController ()

@property (nonatomic, assign) WWDAppDelegate* myAppDelegate;

@end

@implementation MoreTableTableViewController
UIImagePickerController* picker;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _myAppDelegate = (WWDAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* disconnectedAlarmValue = [defaults stringForKey:@"disconnectedAlarm"];
    NSString* antiLoseAlarmValue = [defaults stringForKey:@"antiLoseAlarm"];
    NSString* heartRateAlarmValue = [defaults stringForKey:@"heartRateAlarm"];
    
    if([@"OFF" isEqual:disconnectedAlarmValue]){
        [_disconnectedAlarm setOn:NO];
    }else if([@"ON" isEqual:disconnectedAlarmValue]){
        [_disconnectedAlarm setOn:YES];
    }else{
        [_disconnectedAlarm setOn:YES];
    }
    
    if([@"OFF" isEqual:antiLoseAlarmValue]){
        [_antiLoseAlarm setOn:NO];
    }else if([@"ON" isEqual:antiLoseAlarmValue]){
        [_antiLoseAlarm setOn:YES];
    }else{
        [_antiLoseAlarm setOn:YES];
    }
    
    if([@"OFF" isEqual:heartRateAlarmValue]){
        [_heartRateAlarm setOn:NO];
    }else if([@"ON" isEqual:heartRateAlarmValue]){
        [_heartRateAlarm setOn:YES];
    }else{
        [_heartRateAlarm setOn:YES];
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"camera" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cameraJump:) name:@"camera" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"camera" object:nil];
}

- (void)cameraJump:(NSNotification*)myNotification{
    [self setHidesBottomBarWhenPushed:YES];
    [self performSegueWithIdentifier:@"cameraSegue" sender:self];
    [self setHidesBottomBarWhenPushed:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    if(section == 0){
        return 7;
    }else if(section == 1){
        return 4;
    }else{
        return 8;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    self.hidesBottomBarWhenPushed = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger rowNO = indexPath.row;
    NSUInteger rowSection = indexPath.section;
    if (rowSection == 0) {
        if (rowNO == 1) {
            [self setHidesBottomBarWhenPushed:YES];
            [self performSegueWithIdentifier:@"cameraSegue" sender:nil];
            [self setHidesBottomBarWhenPushed:NO];
        }
        //syn time
        else if(rowNO == 4){
            [_myAppDelegate writeToPeripheral:[WWDTools getNowTimeToNSStringFromWrite]];
        }
        //syn records
        else if(rowNO == 5){
            [self.myAppDelegate writeToPeripheral:@"FE00"];
        }
        //close all alarm
        else if(rowNO == 3){
            
        }
        //close my watch
        else if(rowNO ==6){
            UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure to close My Watch?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Confirm" otherButtonTitles:nil, nil];
            sheet.actionSheetStyle = UIActionSheetStyleAutomatic;
            [sheet showInView:self.view];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self.myAppDelegate writeToPeripheral:@"E101"];
    }
}

// 当得到照片或者视频后，调用该方法
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker setShowsCameraControls:NO];
	NSLog(@"成功：%@", info);
	UIImage *theImage = nil;
	// 获取原始的照片
	theImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	UIImageWriteToSavedPhotosAlbum(theImage, nil,nil, nil);
	// 隐藏UIImagePickerController
//	[picker dismissViewControllerAnimated:YES completion:nil];
   
}
// 当用户取消时，调用该方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	NSLog(@"用户取消的拍摄！");
	// 隐藏UIImagePickerController
//	[picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)searchMyWatchSwitch:(id)sender {
    if([sender isOn]){
        [_myAppDelegate writeToPeripheral:@"F301"];
    }else{
        [_myAppDelegate writeToPeripheral:@"F3A1"];
    }
}

- (IBAction)synRecordBtn:(id)sender {
    [self.myAppDelegate writeToPeripheral:@"FE00"];
}

- (IBAction)synTimeBtn:(id)sender {
    NSLog(@"synchronization time btn has pressed.");
    [_myAppDelegate writeToPeripheral:[WWDTools getNowTimeToNSStringFromWrite]];
}

- (IBAction)closeAllAlertBtn:(id)sender {
    [WWDTools avAudioPlayerStop];
}

- (IBAction)disconnectedAlarm:(id)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if([sender isOn]){
        [defaults setValue:@"ON" forKey:@"disconnectedAlarm"];
    }else{
        [defaults setValue:@"OFF" forKey:@"disconnectedAlarm"];
    }
    [defaults synchronize];
}

- (IBAction)antiLoseAlarm:(id)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if([sender isOn]){
        [defaults setValue:@"ON" forKey:@"antiLoseAlarm"];
    }else{
        [defaults setValue:@"OFF" forKey:@"antiLoseAlarm"];
    }
    [defaults synchronize];
}

- (IBAction)heartRateAlarm:(id)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if([sender isOn]){
        [defaults setValue:@"ON" forKey:@"heartRateAlarm"];
    }else{
        [defaults setValue:@"OFF" forKey:@"heartRateAlarm"];
    }
    [defaults synchronize];
}
@end
