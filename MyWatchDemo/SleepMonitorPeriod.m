//
//  SleepMonitorPeriod.m
//  MyWatchDemo
//
//  Created by maginawin on 14-9-15.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import "SleepMonitorPeriod.h"

@implementation SleepMonitorPeriod
NSArray* timeItem;
NSUserDefaults* defaults;

- (void)refreshField{
    NSString* startTime = [defaults stringForKey:@"sleepMonitorStartTime"];
    NSString* endTime = [defaults stringForKey:@"sleepMonitorEndTime"];
    if(startTime != nil){
        _startTimeLabel.text = startTime;
        [_startTimePicker selectRow:[startTime integerValue] inComponent:0 animated:NO];
    }else{
        _startTimeLabel.text = @"22:00";
        [_startTimePicker selectRow:22 inComponent:0 animated:NO];
    }
    if(endTime != nil){
        _endTimeLabel.text = endTime;
        [_startTimePicker selectRow:[endTime integerValue] inComponent:1 animated:NO];
    }else{
        _endTimeLabel.text = @"8:00";
        [_startTimePicker selectRow:8 inComponent:1 animated:NO];
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    timeItem = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",nil];
    self.startTimePicker.dataSource = self;
    self.startTimePicker.delegate = self;
    defaults = [NSUserDefaults standardUserDefaults];
    [self refreshField];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return timeItem.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [timeItem objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if(component == 0){
        NSString* value = [NSString stringWithFormat:@"%@:00",[timeItem objectAtIndex:row]];
//        self.startTimeLabel.text = value;
        [defaults setValue:value forKey:@"sleepMonitorStartTime"];
    }else if(component == 1){
        NSString* value = [NSString stringWithFormat:@"%@:00",[timeItem objectAtIndex:row]];
//        _endTimeLabel.text = value;
        [defaults setValue:value forKey:@"sleepMonitorEndTime"];
    }
    [self refreshField];
}

@end
