//
//  WWDTools.m
//  MyWatchDemo
//
//  Created by maginawin on 14-8-25.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import "WWDTools.h"

@implementation WWDTools

AVAudioPlayer* audioPlayer;

//将传入的NSData类型转换成NSString并返回
+ (NSString*)hexadecimalString:(NSData *)data{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}

//将传入的NSString类型转换成NSData并返回
+ (NSData*)dataWithHexstring:(NSString *)hexstring{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for(idx = 0; idx + 2 <= hexstring.length; idx += 2){
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hexstring substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

//将HexString转为int
+ (unsigned int)intFromHexString:(NSString *) hexStr
{
    unsigned int hexInt = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    
    // Scan hex value
    [scanner scanHexInt:&hexInt];
    
    return hexInt;
}

//根据传入的index输出count位的String
+ (NSString*)stringFromIndexCount:(NSInteger)index count:(NSInteger)count from:(NSString*)string{
    NSRange range = NSMakeRange(index, count);
    NSString* result = [string substringWithRange:range];
    return result;
}

+ (NSString*)getDistanceDefaultFromSteps:(NSString*)steps{
    
    float distanceKm = 0.75 * 0.001 * [steps floatValue];
    NSString* distance = [NSString stringWithFormat:@"%0.02f", distanceKm];
    return distance;
}

+ (NSString*)getHHMMSSFromSeconds:(long)seconds{
    long hh = seconds / 60 / 60;
    long mm = (seconds % (60 * 60)) / 60;
    long ss = (seconds % (60 * 60)) % 60;
    NSMutableString* hhmmss = [[NSMutableString alloc]init];
    if(hh == 0){
        [hhmmss appendString:@"00:"];
    }else if(hh > 0 && hh < 10){
        [hhmmss appendString:[NSString stringWithFormat:@"0%ld:", hh]];
    }else{
        [hhmmss appendString:[NSString stringWithFormat:@"%ld:", hh]];
    }
    if(mm == 0){
        [hhmmss appendString:@"00:"];
    }else if(mm > 0 && mm < 10){
        [hhmmss appendString:[NSString stringWithFormat:@"0%ld:", mm]];
    }else{
        [hhmmss appendString:[NSString stringWithFormat:@"%ld:", mm]];
    }
    if(ss == 0){
        [hhmmss appendString:@"00"];
    }else if(ss > 0 && ss < 10){
        [hhmmss appendString:[NSString stringWithFormat:@"0%ld", ss]];
    }else{
        [hhmmss appendString:[NSString stringWithFormat:@"%ld", ss]];
    }
    return hhmmss;
}

+ (NSString*)getHHMMSSFromStringHMS:(NSString*)hmsString{
    NSMutableString* result = [[NSMutableString alloc]init];
    if(hmsString.length == 6){
        for(int i = 0; i < 3; i++){
//            NSRange range = NSMakeRange(i * 2, 2);
//            NSString* aa = [hmsString substringWithRange:range];
            NSString* timeStr = [self stringFromIndexCount:(i * 2) count:2 from:hmsString];
            int time = [self intFromHexString:timeStr];
            if(time < 10){
                [result appendFormat:@"0%d",time];
            }else{
                [result appendFormat:@"%d",time];
            }
            if(i != 2){
                [result appendString:@":"];
            }
        }
    }else{
        [result appendString:@"00:00:00"];
    }
    return result;
}

+ (NSString*)getHoursFromHHMMSS:(NSString*)hhmmss{
    NSString* result = @"0.0";
    NSInteger hour = [WWDTools intFromHexString:[WWDTools stringFromIndexCount:0 count:2 from:hhmmss]];
    NSInteger minute = [WWDTools intFromHexString:[WWDTools stringFromIndexCount:2 count:2 from:hhmmss]];
    double hourDouble = hour + (minute / 60);
    result = [NSString stringWithFormat:@"%0.1f",hourDouble];
    NSLog(@"get hours from hhmmss, hour : %d, mininute : %d, result : %@",hour, minute, result);
    return result;
}

+ (NSString*)getSpeedFromDistance:(NSString*)distanceHexString andTime:(NSString*)actTimeHexString{
    NSString* result = @"0.00";
    float distance = [self intFromHexString:distanceHexString] * 10;
    float hh = [self intFromHexString:[self stringFromIndexCount:0 count:2 from:actTimeHexString]] * 60 * 60;
    float mm = [self intFromHexString:[self stringFromIndexCount:2 count:2 from:actTimeHexString]] * 60;
    float ss = [self intFromHexString:[self stringFromIndexCount:4 count:2 from:actTimeHexString]];
    float second = hh + mm + ss;
    float speed = 0;
    if(second > 0){
        speed = distance * 3.6f / second;
    }
    result = [NSString stringWithFormat:@"%0.02f", speed];
    return result;
}

+ (NSString*)getNowTimeToNSStringFromWrite{
    NSMutableString* result = [[NSMutableString alloc]init];
    NSDate* sendDate = [NSDate date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd-HH-mm-ss"];
    NSString* moreLocationString = [dateFormatter stringFromDate:sendDate];
    
    NSString* yearStr = [self stringFromIndexCount:0 count:4 from:moreLocationString];
    NSString* monthStr = [self stringFromIndexCount:5 count:2 from:moreLocationString];
    NSString* dayStr = [self stringFromIndexCount:8 count:2 from:moreLocationString];
    NSString* hourStr = [self stringFromIndexCount:11 count:2 from:moreLocationString];
    NSString* minStr = [self stringFromIndexCount:14 count:2 from:moreLocationString];
    NSString* secStr = [self stringFromIndexCount:17 count:2 from:moreLocationString];
    
    [result appendString:@"F4"];
    
    int year = [yearStr intValue] - 1900;
    NSString* yearHex = [NSString stringWithFormat:@"%x",year];
    if([yearHex length] < 2){
        [result appendFormat:@"0%@",yearHex];
    }else{
        [result appendString:yearHex];
    }
    
    NSString* monthHex = [NSString stringWithFormat:@"%x", [monthStr intValue]];
    if([monthHex length] < 2){
        [result appendFormat:@"0%@",monthHex];
    }else{
        [result appendString:monthHex];
    }
    
    NSString* dayHex = [NSString stringWithFormat:@"%x",[dayStr intValue]];
    if([dayHex length] < 2){
        [result appendFormat:@"0%@",dayHex];
    }else{
        [result appendString:dayHex];
    }
    
    NSString* hourHex = [NSString stringWithFormat:@"%x",[hourStr intValue]];
    if([hourHex length] < 2){
        [result appendFormat:@"0%@",hourHex];
    }else{
        [result appendString:hourHex];
    }
    
    NSString* minHex = [NSString stringWithFormat:@"%x",[minStr intValue]];
    if([minHex length] < 2){
        [result appendFormat:@"0%@",minHex];
    }else{
        [result appendString:minHex];
    }
    
    NSString* secHex = [NSString stringWithFormat:@"%x", [secStr intValue]];
    if([secHex length] < 2){
        [result appendFormat:@"0%x",[secStr intValue]];
    }else{
        [result appendString:secHex];
    }
    
    return result;
}

//根据传入的wavName来播放提示音
+ (void)avAudioPlayerStartFromWAV:(NSString*)wavName{
    
    if(audioPlayer != nil){
        if([audioPlayer isPlaying]){
            [audioPlayer stop];
        }
        audioPlayer = nil;
    }
    
    NSURL* fileURL = [[NSBundle mainBundle]URLForResource:wavName withExtension:@"wav"];
    audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:nil];
    audioPlayer.numberOfLoops = -1;
    [audioPlayer play];
}

+ (void)avAudioPlayerStartOnceFromWAV:(NSString *)wavName{
    if(audioPlayer != nil){
        if([audioPlayer isPlaying]){
            [audioPlayer stop];
        }
        audioPlayer = nil;
    }
    
    NSURL* fileURL = [[NSBundle mainBundle]URLForResource:wavName withExtension:@"wav"];
    audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:nil];
    
    [audioPlayer play];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds* NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        audioPlayer = nil;
    });
}

//关闭提示音
+ (void)avAudioPlayerStop{
    if(audioPlayer != nil){
        if([audioPlayer isPlaying]){
            [audioPlayer stop];
        }
        audioPlayer = nil;
    }
}

+ (NSString*)getSleepQualityWithValue:(NSString*)sleepValue{
    NSString* sleepQuality = @"0";
    NSInteger sum = 0;
    NSInteger count = 0;
    for (int i = 0; i < sleepValue.length; i++) {
        NSString* value = [self stringFromIndexCount:i count:1 from:sleepValue];
        NSInteger intValue = [value integerValue];
        if (intValue != 0) {
            sum += intValue;
            count++;
        }
    }
    if (count > 0) {
        double temp = sum / count;
        sleepQuality = [NSString stringWithFormat:@"%f",temp];
    }
    return sleepQuality;
}

+ (NSString*)hexStringFromString:(NSString*)string{
    NSInteger intValue = [string integerValue];
    NSMutableString* result = [[NSMutableString alloc]init];
    NSString* yearHex = [NSString stringWithFormat:@"%x",intValue];
    if([yearHex length] < 2){
        [result appendFormat:@"0%@",yearHex];
    }else{
        [result appendString:yearHex];
    }
    return result;
}

+ (NSString*)getHHMMHexFromHHMMString:(NSString*)hhmmString onOrOff:(BOOL)yesOrNo{
    NSString* hh = [self hexStringFromString:[WWDTools stringFromIndexCount:0 count:2 from:hhmmString]];
    NSString* mm = [self hexStringFromString:[WWDTools stringFromIndexCount:3 count:2 from:hhmmString]];

    NSMutableString* resultStr = [NSMutableString stringWithString:@"e000"];
    if (yesOrNo) {
        [resultStr appendFormat:@"0100"];
    }else{
        [resultStr appendFormat:@"0000"];
    }
    [resultStr appendString:hh];
    [resultStr appendString:mm];
    NSString* reslut = [resultStr uppercaseString];
    return reslut;
}

@end



