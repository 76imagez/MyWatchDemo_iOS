//
//  MoreTableTableViewController.h
//  MyWatchDemo
//
//  Created by maginawin on 14-9-3.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WWDAppDelegate.h"

@interface MoreTableTableViewController : UITableViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *disconnectedAlarm;
@property (weak, nonatomic) IBOutlet UISwitch *antiLoseAlarm;
@property (weak, nonatomic) IBOutlet UISwitch *heartRateAlarm;
- (IBAction)searchMyWatchSwitch:(id)sender;
- (IBAction)synRecordBtn:(id)sender;
- (IBAction)synTimeBtn:(id)sender;
- (IBAction)closeAllAlertBtn:(id)sender;

- (IBAction)disconnectedAlarm:(id)sender;
- (IBAction)antiLoseAlarm:(id)sender;
- (IBAction)heartRateAlarm:(id)sender;

@end
