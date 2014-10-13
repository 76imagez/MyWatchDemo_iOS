//
//  AlarmClockViewController.h
//  MyWatchDemo
//
//  Created by maginawin on 14-10-11.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WWDTools.h"
#import "WWDAppDelegate.h"

@interface AlarmClockViewController : UIViewController
- (IBAction)clockSwitchChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UISwitch *clockSwitch;
@property (weak, nonatomic) IBOutlet UITextField *clockTextSet;
@property (weak, nonatomic) WWDAppDelegate* myAppdelegate;
- (IBAction)datePickerChanged:(id)sender;

@end
