//
//  WWDTools.h
//  MyWatchDemo
//
//  Created by maginawin on 14-8-25.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface WWDTools : NSObject<AVAudioPlayerDelegate>

//将传入的NSData类型转换成NSString并返回
+ (NSString*)hexadecimalString:(NSData *)data;

//将传入的NSString类型转换成NSData并返回
+ (NSData*)dataWithHexstring:(NSString *)hexstring;

//将HexString转为int
+ (unsigned int)intFromHexString:(NSString *) hexStr;

//将传入的十进制string转换为十六进制的字符串
+ (NSString*)hexStringFromString:(NSString*)string;

//根据传入的index输出count位的String
+ (NSString*)stringFromIndexCount:(NSInteger)index count:(NSInteger)count from:(NSString*)string;

//计算距离(默认步长70cm),返回值是km为单位
+ (NSString*)getDistanceDefaultFromSteps:(NSString*)steps;

//计算时间,根据传入的秒数计算出hh:mm:ss格式的NSString返回
+ (NSString*)getHHMMSSFromSeconds:(long)seconds;

//计算时间,根据传入的16进制数hhmmss格式返回HH:MM:SS格式的字符串
+ (NSString*)getHHMMSSFromStringHMS:(NSString*)hmsString;

//计算时间,根据传入的HHMMSS返回NSString的小时数,保留1位小数
+ (NSString*)getHoursFromHHMMSS:(NSString*)hhmmss;

//根据传入的距离和时间算出速度(距离和时间都为HexString)
+ (NSString*)getSpeedFromDistance:(NSString*)distanceHexString andTime:(NSString*)actTimeHexString;

//取得当前的时间,并转换为可以发送给下位机的NSString*返回
+ (NSString*)getNowTimeToNSStringFromWrite;

//根据传入的wavName来播放提示音(循环)
+ (void)avAudioPlayerStartFromWAV:(NSString*)wavName;

//根据传入的wavName来播放提示音(一次)
+ (void)avAudioPlayerStartOnceFromWAV:(NSString *)wavName;

//关闭提示音
+ (void)avAudioPlayerStop;

//根据传入的字符串,算出睡眠质量(0是未监测到不算在内)
+ (NSString*)getSleepQualityWithValue:(NSString*)sleepValue;

//根据传入的00:00格式的时间,返回0x **** 格式的字符串
+ (NSString*)getHHMMHexFromHHMMString:(NSString*)hhmmString onOrOff:(BOOL)yesOrNo;
@end
