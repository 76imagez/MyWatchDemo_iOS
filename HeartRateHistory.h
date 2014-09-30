//
//  HeartRateHistory.h
//  MyWatchDemo
//
//  Created by maginawin on 14-9-17.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HeartRateHistory : NSManagedObject

@property (nonatomic, retain) NSString * recordDate;
@property (nonatomic, retain) NSString * recordValue;

@end
