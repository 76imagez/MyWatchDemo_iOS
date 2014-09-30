//
//  WWDRecoredManager.h
//  AVRecordTest
//
//  Created by maginawin on 14-9-9.
//  Copyright (c) 2014年 crazyit.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "FKRecordUtils.h"

@protocol WWDRecoredManagerDelegate;

@interface WWDRecoredManager : NSObject
@property(nonatomic,retain) AVCaptureSession* session;
@property(nonatomic,assign) AVCaptureVideoOrientation orientation;
@property(nonatomic,retain) AVCaptureDeviceInput* videoInput;
@property(nonatomic,retain) AVCaptureStillImageOutput* stillImageOutput;
@property(nonatomic,assign) id deviceConnectedObserver;
@property(nonatomic,assign) id deviceDisconnectedObserver;
@property(nonatomic,assign) UIBackgroundTaskIdentifier backgroundRecordingID;
@property(nonatomic,assign) id<WWDRecoredManagerDelegate>delegate;
-(BOOL) setupSession;
-(void) captureStillImage;
-(BOOL) toggleCamera;
-(NSUInteger) cameraCount;
-(void) autoFocusAtPoint:(CGPoint)point;
-(void) continuousFocusAtPoint:(CGPoint)point;

@end

@protocol WWDRecoredManagerDelegate <NSObject>

//可选的方法
@optional
-(void)recordManager:(WWDRecoredManager*) recordManager didFailWithError:(NSError*)error;
-(void)recordManagerStillImageCaptured:(WWDRecoredManager*)recordManager;
-(void)recordManagerDeviceConfigurationChanged:(WWDRecoredManager*)recordManager;

@end