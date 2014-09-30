//
//  MusicBean.h
//  MyWatchDemo
//
//  Created by maginawin on 14-9-5.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicBean : NSObject

@property(weak, nonatomic)NSString* musicName;
@property(weak, nonatomic)NSURL* musicURL;
@property(weak, nonatomic)NSString* musicArtist;

@end
