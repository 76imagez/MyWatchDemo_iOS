//
//  ConnectViewController.h
//  MyWatchDemo
//
//  Created by maginawin on 14-8-29.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
- (IBAction)goBack:(id)sender;
- (IBAction)reScanBle:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *periphearlsTableView;

@end
