//
//  AlarmClockViewController.m
//  MyWatchDemo
//
//  Created by maginawin on 14-10-11.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import "AlarmClockViewController.h"

@interface AlarmClockViewController ()

@end

@implementation AlarmClockViewController
NSDateFormatter* dateFormatter;
NSUserDefaults* defaults;
BOOL clockBool;
NSString* clockValue;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    defaults = [NSUserDefaults standardUserDefaults];
    clockBool = [defaults boolForKey:@"clockBool"];
    clockValue = [defaults valueForKey:@"clockValue"];
    dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"HH:mm"];
    if (clockValue == nil) {
        clockValue = @"00:00";
    }
    NSDate* defaultDate = [dateFormatter dateFromString:clockValue];
    [_datePicker setDate:defaultDate];
    [_clockTextSet setText:clockValue];
    [_clockSwitch setOn:clockBool];
    
    _myAppdelegate = (WWDAppDelegate*)[[UIApplication sharedApplication]delegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clockSwitchChanged:(id)sender {
    BOOL b = [_clockSwitch isOn];
    [defaults setBool:b forKey:@"clockBool"];
    //利用clockValue转化成16进制****格式
    NSString* value;
    if (b) {
        //发送闹钟开
        value = [WWDTools getHHMMHexFromHHMMString:clockValue onOrOff:YES];
    }else{
        //发送闹钟关
        value = [WWDTools getHHMMHexFromHHMMString:clockValue onOrOff:NO];
    }
    [_myAppdelegate writeToPeripheral:value];
}
- (IBAction)datePickerChanged:(id)sender {
    NSDate* selected = [_datePicker date];
    NSString* destDateString = [dateFormatter stringFromDate:selected];
    [_clockTextSet setText:destDateString];
    clockValue = destDateString;
    [defaults setValue:destDateString forKey:@"clockValue"];
    NSLog(@"选择的时间是:%@",destDateString);
    
}
@end
