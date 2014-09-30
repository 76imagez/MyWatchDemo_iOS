//
//  MusicPlayerViewController.h
//  MyWatchDemo
//
//  Created by maginawin on 14-9-5.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicBean.h"
#import "WWDTools.h"
#import "WWDAppDelegate.h"

@interface MusicPlayerViewController : UIViewController<AVAudioPlayerDelegate, AVAudioSessionDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *musicTable;

- (IBAction)goBack:(id)sender;
- (IBAction)scanMusic:(id)sender;
- (IBAction)playOrPauseMusic:(id)sender;
- (IBAction)playNextMusic:(id)sender;
- (IBAction)playLastMusic:(id)sender;

@end
