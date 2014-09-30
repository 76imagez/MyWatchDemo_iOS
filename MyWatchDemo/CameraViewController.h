//
//  CameraViewController.h
//  AVRecordTest
//
//  Created by maginawin on 14-9-9.
//  Copyright (c) 2014年 crazyit.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "WWDRecoredManager.h"
#import "WWDAppDelegate.h"

@interface CameraViewController : UIViewController

@property (nonatomic, strong) WWDRecoredManager* recordManager;
@property (nonatomic, weak) IBOutlet UIView* videoPreviewView;
@property (nonatomic, weak) IBOutlet UIButton* cameraToggleButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* stillButton;


- (IBAction)backBtn:(id)sender;
- (IBAction)toggleCamera:(id)sender;
- (IBAction)captureStillImage:(id)sender;

- (void)capture;
@end
