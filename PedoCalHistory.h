//
//  PedoCalHistory.h
//  MyWatchDemo
//
//  Created by maginawin on 14-9-18.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PedoCalHistory : NSManagedObject

@property (nonatomic, retain) NSString * recordValue;
@property (nonatomic, retain) NSString * recordDate;

@end
