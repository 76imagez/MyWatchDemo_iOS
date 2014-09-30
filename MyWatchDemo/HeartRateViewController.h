//
//  HeartRateViewController.h
//  MyWatchDemo
//
//  Created by maginawin on 14-8-28.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WWDTools.h"

@interface HeartRateViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *heartRateCount;
@property (weak, nonatomic) IBOutlet UILabel *minimum;
@property (weak, nonatomic) IBOutlet UILabel *maximum;
@property (weak, nonatomic) IBOutlet UIImageView *heartImageView;

@end
