//
//  WWDAppDelegate.h
//  MyWatchDemo
//
//  Created by maginawin on 14-8-20.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "MusicBean.h"
#import "CameraViewController.h"
#import "WWDTools.h"
#import "SleepMonitorHistory.h"
#import "HeartRateHistory.h"
#import "PedoHistory.h"
#import "PedoStepHistory.h"
#import "PedoDistHistory.h"
#import "PedoCalHistory.h"
#import "PedoTimeHistory.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>



@interface WWDAppDelegate : UIResponder <UIApplicationDelegate, CBCentralManagerDelegate, CBPeripheralDelegate, AVAudioPlayerDelegate>

@property (strong, nonatomic) UIWindow *window;

// 定义Core Data的3个核心API的属性
@property (readonly, strong, nonatomic) NSManagedObjectContext*
managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator*
persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//蓝牙的属性及方法
@property (strong, nonatomic) CBCentralManager* myCentralManager;
@property (strong, nonatomic) NSMutableArray* myPeripherals;
@property (strong, nonatomic) CBPeripheral* myPeripheral;
@property (strong, nonatomic) NSMutableArray* nServices;
@property (strong, nonatomic) NSMutableArray* nDevices;
@property (strong, nonatomic) NSMutableArray* nCharacteristics;
@property (strong, nonatomic) CBCharacteristic* writeCharacteristic;
@property (strong, nonatomic) CBCharacteristic* readCharacteristic;
@property (strong, nonatomic) CBCharacteristic* heartNotiCharacteristic;

@property (weak, nonatomic) UIViewController* currentView;
@property (weak, nonatomic) UIViewController* camera;


@property (weak, nonatomic) NSMutableArray* heartRateArray;

@property (strong, nonatomic) NSArray* musicArray;

@property (strong, nonatomic) NSTimer* timer;

//电话监听
@property (strong, nonatomic) CTCallCenter* center;

- (void)scanClick;
- (void)connectClick;
- (void)writeToPeripheral:(NSString *)data;

//取得本地所有音乐,赋值给appDelegate中的array并返回其array
- (NSArray*)getMusicMessage;
//播放音乐列表中的第rowNo+1首歌
- (void)playMusic:(NSUInteger)rowNo;
//上一首
- (void)playLastMusic;
//下一首
- (void)playNextMusic;
//暂停||继续
- (void)playMusicPauseOrStart;

@end
