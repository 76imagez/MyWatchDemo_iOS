//
//  WWDAppDelegate.m
//  MyWatchDemo
//
//  Created by maginawin on 14-8-20.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import "WWDAppDelegate.h"

@implementation WWDAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

AVAudioPlayer* audioPlayer;
NSUInteger palyTag = 0;


NSEntityDescription* sleepEntity;
NSEntityDescription* heartRateEntity;
NSEntityDescription* pedoEntity;
NSEntityDescription* pedoStepEntity;
NSEntityDescription* pedoDistEntity;
NSEntityDescription* pedoCalEntity;
NSEntityDescription* pedoTimeEntity;

NSRunLoop* runLoop;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    _myCentralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    _myPeripherals = [NSMutableArray array];
    
    _heartRateArray = [NSMutableArray array];
    _musicArray = [NSArray array];
    [self getMusicMessage];
    
    //给audio添加远程设备支持?
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents]; 
    
    sleepEntity = [NSEntityDescription entityForName:@"SleepMonitorHistory" inManagedObjectContext:self.managedObjectContext];
    heartRateEntity = [NSEntityDescription entityForName:@"HeartRateHistory" inManagedObjectContext:self.managedObjectContext];
    pedoEntity = [NSEntityDescription entityForName:@"PedoHistory" inManagedObjectContext:self.managedObjectContext];
    pedoStepEntity = [NSEntityDescription entityForName:@"PedoStepHistory" inManagedObjectContext:self.managedObjectContext];
    pedoDistEntity = [NSEntityDescription entityForName:@"PedoDistHistory" inManagedObjectContext:self.managedObjectContext];
    pedoCalEntity = [NSEntityDescription entityForName:@"PedoCalHistory" inManagedObjectContext:self.managedObjectContext];
    pedoTimeEntity = [NSEntityDescription entityForName:@"PedoTimeHistory" inManagedObjectContext:self.managedObjectContext];
    
    //电话监听
//    self.center = [[CTCallCenter alloc] init];
//    self.center.callEventHandler = ^(CTCall* call) {
//        if ([call.callState isEqualToString:CTCallStateDisconnected])
//        {
//            NSLog(@"Call has been disconnected");
//        }
//        else if ([call.callState isEqualToString:CTCallStateConnected])
//        {
//            NSLog(@"Call has just been connected");
//        }
//        else if([call.callState isEqualToString:CTCallStateIncoming])
//        {
//            NSLog(@"Call is incoming");
//        }
//        else if ([call.callState isEqualToString:CTCallStateDialing])
//        {
//            NSLog(@"call is dialing");
//        }
//        else
//        {
//            NSLog(@"Nothing is done");
//        }
//    };
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //    [[NSRunLoop currentRunLoop] run];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//开始查看服务, 蓝牙开启
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
//            NSLog(@"蓝牙已经开启,可以扫描设备!\n");
            break;
        case CBCentralManagerStatePoweredOff:
//            NSLog(@"蓝牙未开启,扫描不到设备!\n");
        default:
            break;
    }
}

//查到外设后的方法,peripherals
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
//    NSLog(@"已发现 peripheral: %@ rssi: %@, uuid: %@ advertisementData: %@", peripheral, RSSI, peripheral.UUID, advertisementData);
    
    [_myPeripherals addObject:peripheral];
//    NSInteger count = [_myPeripherals count];
//    NSLog(@"my periphearls count : %ld\n", (long)count);
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"myDidDiscoverPeripheral" object:nil];

}

//连接外设成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
//    NSLog(@"成功连接 peripheral: %@ with UUID: %@",peripheral, peripheral.UUID);
    [self.myPeripheral setDelegate:self];
    [self.myPeripheral discoverServices:nil];
//    NSLog(@"扫描服务...");
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"myDidConnectPeripheral" object:nil];
    
    [WWDTools avAudioPlayerStartOnceFromWAV:@"connectedAlarm2"];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(getRssiSelector:) userInfo:nil repeats:YES];
    
}

//掉线时调用
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
//    NSLog(@"periheral has disconnect");
    [_timer invalidate];
    _timer = nil;
    [_myCentralManager connectPeripheral:_myPeripheral options:nil];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"myDidDisconnectPeripheral" object:nil];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* disconnectedAlarmValue = [defaults stringForKey:@"disconnectedAlarm"];
    if ([@"OFF" isEqual:disconnectedAlarmValue]) {
        
    }else{
//        NSLog(@"%@", disconnectedAlarmValue);
        [WWDTools avAudioPlayerStartOnceFromWAV:@"disconnectedAlarm"];
    }
}

//连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
//    NSLog(@"%@", error);

}

//已发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
//    NSLog(@"发现服务!");
    int i = 0;
//    for(CBService* s in peripheral.services){
//        [self.nServices addObject:s];
//    }
    for(CBService* s in peripheral.services){
//        NSLog(@"%d :服务 UUID: %@(%@)", i, s.UUID.data, s.UUID);
        i++;
        [peripheral discoverCharacteristics:nil forService:s];
//        NSLog(@"扫描Characteristics...");
    }
}

//已发现characteristcs
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    for(CBCharacteristic* c in service.characteristics){
//        NSLog(@"特征 UUID: %@ (%@)", c.UUID.data, c.UUID);
        if([c.UUID isEqual:[CBUUID UUIDWithString:@"FFF2"]]){
            self.writeCharacteristic = c;
//            NSLog(@"找到WRITE : %@", c);
            //找到write的characteristic,将时间更新发过去
            [self writeToPeripheral:[WWDTools getNowTimeToNSStringFromWrite]];
        }else if([c.UUID isEqual:[CBUUID UUIDWithString:@"FFF1"]]){
            self.readCharacteristic = c;
            [self.myPeripheral setNotifyValue:YES forCharacteristic:c];
            //暂时取消read,没有必要
//            [self.myPeripheral readValueForCharacteristic:c];
//            NSLog(@"找到READ : %@", c);
        }
        else if([c.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]]){
            self.heartNotiCharacteristic = c;
        }
    }
}

- (void)getRssiSelector:(id)sender{
    if(!_heartNotiCharacteristic){
//        NSLog(@"writeCharacteristic is nil!");
        return;
    }
//    [self writeToPeripheral:@"0000"];
//    [_myPeripheral readValueForCharacteristic:_heartNotiCharacteristic];
    [_myPeripheral readRSSI];
//    NSLog(@"get rssi selector");
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
    
    NSNumber* rssi = [peripheral RSSI];
    //将距离报警的信号设为-94
    if([rssi intValue]< -94){
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString* disconnectedAlarmValue = [defaults stringForKey:@"antiLoseAlarm"];
        if ([@"OFF" isEqual:disconnectedAlarmValue]) {
            
        }else{
//            NSLog(@"%@", disconnectedAlarmValue);
            [WWDTools avAudioPlayerStartOnceFromWAV:@"searchiPhoneAlarm2"];
        }
        
    }
//    NSLog(@" rssi is %@", rssi);
}

//中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(error){
//        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    //Notification has started
    if(characteristic.isNotifying){
//        [peripheral readValueForCharacteristic:characteristic];
    }else{
//        NSLog(@"Notification stopped on %@. Disconnting", characteristic);
        [self.myCentralManager cancelPeripheralConnection:self.myPeripheral];
    }
}

//向peripheral中写入数据
- (void)writeToPeripheral:(NSString *)data{
    if(!_writeCharacteristic){
//        NSLog(@"writeCharacteristic is nil!");
        return;
    }
//    NSData* value = [self dataWithHexstring:data];
    NSData* value = [WWDTools dataWithHexstring:data];
    [_myPeripheral writeValue:value forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

//向peripheral中写入数据后的回调函数
- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
//    NSLog(@"write value success : %@", characteristic);
}

//扫描
- (void)scanClick{
//    NSLog(@"正在扫描外设...");
    //    [self.myCentralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
    
    [self.myCentralManager scanForPeripheralsWithServices:nil options:nil];
//    if(_myPeripheral != nil){
//        [_myCentralManager cancelPeripheralConnection:_myPeripheral];
//    }
    
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds* NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.myCentralManager stopScan];
//        NSLog(@"扫描超时,停止扫描!");
    });
}

//连接
- (void)connectClick{
    [self.myCentralManager connectPeripheral:self.myPeripheral options:nil];
}

//查找所有的音乐文件并返回NSArray
- (NSArray*)getMusicMessage{
    NSMutableArray* myPlaylist = [NSMutableArray array];
    MPMediaQuery* myPlaylistsQuery = [MPMediaQuery songsQuery];
    NSArray* playlists = [myPlaylistsQuery collections];
    for(MPMediaPlaylist* playlist in playlists){
        NSArray* array = [playlist items];
        for(MPMediaItem* song in array){
            //            MusicMessage
            MusicBean* musicBean = [[MusicBean alloc] init];
            
            musicBean.musicName = [song valueForProperty:MPMediaItemPropertyTitle]; // name
            musicBean.musicURL = [song valueForProperty:MPMediaItemPropertyAssetURL]; // URL
            musicBean.musicArtist = [song valueForProperty:MPMediaItemPropertyArtist]; // artist
            
            [myPlaylist addObject:musicBean];
        }
    }
//    NSLog(@"%d", myPlaylist.count);
    _musicArray = myPlaylist;
    return myPlaylist;
}

- (void)playMusic:(NSUInteger)rowNo{
    if(rowNo <= _musicArray.count){
        MusicBean* bean = [_musicArray objectAtIndex:rowNo];
        
        if(audioPlayer){
            
            [audioPlayer stop];
            audioPlayer = nil;
        }
        audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[bean musicURL] error:nil];
        audioPlayer.delegate = self;
        [audioPlayer play];
    }
}

- (void)playLastMusic{
    if(palyTag >= 1){
        palyTag = palyTag - 1;
    }else{
        palyTag = [_musicArray count] - 1;
    }
    [self playMusic:palyTag];
}

- (void)playNextMusic{
    if(palyTag >= ([_musicArray count] - 1)){
        palyTag = 0;
    }else{
        palyTag += 1;
    }
    [self playMusic:palyTag];
}

- (void)playMusicPauseOrStart{
    if([audioPlayer isPlaying]){
        [audioPlayer pause];
    }else{
//        [self playMusic:palyTag];
        [audioPlayer play];
        if(![audioPlayer isPlaying]){
            [self playMusic:palyTag];
        }
    }
}
//音乐播放完成后
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
//    NSLog(@"播放结束\n");
    if(palyTag < [_musicArray count] - 1){
        palyTag += 1;
    }else{
        palyTag = 0;
    }
    [self playMusic:palyTag];
}

//音乐播放被中断
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{

}

//远程控制调用的delegate方法
- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPause: //暂停||开始
            [self playMusicPauseOrStart];
            break;
        case UIEventSubtypeRemoteControlPlay:
            [self playMusicPauseOrStart];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack: //上一曲
            [self playLastMusic];
            break;
        case UIEventSubtypeRemoteControlNextTrack: //下一曲
            [self playNextMusic];
            break;
        default:
            break;
    }
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MyWatchModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MyWatch.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//获取外设发来的数据,不论是read和notify,获取数据都从这个方法中读取
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    //    [peripheral readRSSI];
    
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF1"]]){
        
        NSData* data = characteristic.value;
        
        // NSString* value = [self hexadecimalString:data];
        NSString* value = [[WWDTools hexadecimalString:data] uppercaseString];
        
//        NSLog(@"characteristic : %@, data : %@, value : %@", characteristic, data, value);
        
        //处理接收到的数据
        NSString* idString = [WWDTools stringFromIndexCount:0 count:2 from:value];
        
//        NSLog(@"idString is : %@ \n", idString);
        //计步
        if([@"F7" isEqual:idString]){
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"pedometer" object:value];
            
        }
        //心率
        else if([@"F9" isEqual:idString]){
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"heartRate" object:value];
        }
        //时间同步
        else if([@"F4" isEqual:idString]){
            [self writeToPeripheral:[WWDTools getNowTimeToNSStringFromWrite]];
        }
        //手环呼叫手机
        else if([@"F3" isEqual:idString]){
            NSString* callTag = [WWDTools stringFromIndexCount:2 count:2 from:value];
            if([@"01" isEqual:callTag]){
                //开始
                [WWDTools avAudioPlayerStartFromWAV:@"searchiPhoneAlarm2"];
            }else{
                //停止
                [WWDTools avAudioPlayerStop];
            }
        }
        //音乐
        else if([@"F6" isEqual:idString]){
            if (self.musicArray.count > 0) {
                NSString* musicControl = [WWDTools stringFromIndexCount:2 count:2 from:value];
                if([@"01" isEqual:musicControl]){
                    [self playMusicPauseOrStart];
                }else if([@"02" isEqual:musicControl]){
                    //上一曲
                    [self playLastMusic];
                }else if([@"03" isEqual:musicControl]){
                    //下一曲
                    [self playNextMusic];
                }
            }
        }
        //拍照
        else if([@"F5" isEqual:idString]){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"camera" object:nil];
            
        }
        //历史数据
        else if([@"FE" isEqual:idString]){
            NSString* tag = [WWDTools stringFromIndexCount:2 count:2 from:value];
            //睡眠监测数据
            if([@"06" isEqual:tag]){
                NSString* dateTag = [WWDTools stringFromIndexCount:4 count:2 from:value];
                //今天的睡眠监测数据
                if ([@"AA" isEqual:dateTag]) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"todaySleepMonitor" object:value];
                }
            }
            //历史睡眠质量
            else if([@"05" isEqual:tag]){
                NSFetchRequest* request = [[NSFetchRequest alloc]init];
                [request setEntity:sleepEntity];
                
                NSTimeInterval secondsPerDay = 24 * 60 * 60;
                NSString* dateTag = [WWDTools stringFromIndexCount:4 count:2 from:value];
                NSString* sleepMonitorValue = [WWDTools stringFromIndexCount:6 count:24 from:value];
                NSDate* date = [NSDate date] ;
                NSString* myDate = @"";
                //判断数据是否存在于数据库中,如果不存在,才存入数据库中
                switch ([dateTag intValue]) {
                    case 0:{
                        //前一天
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        //这一天的数据不存在
                        if(recordDateArray.count == 0){
                            
                            SleepMonitorHistory* sleepMonitorHistory = [NSEntityDescription insertNewObjectForEntityForName:@"SleepMonitorHistory" inManagedObjectContext:self.managedObjectContext];
                            sleepMonitorHistory.recordDate = myDate;
                            sleepMonitorHistory.recordValue = sleepMonitorValue;
                            if([self.managedObjectContext save:&error]){
//                                NSLog(@"保存数据成功");
                                recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
//                                NSLog(@"保存后的数据条数是:%d",recordDateArray.count);
                            }
                        }
                        //存储出错
                        else if(recordDateArray == nil) {
//                            NSLog(@"获取recordDateArray出错:%@,%@",error,[error userInfo]);
                        }
                        //这一天的数据已经存在
                        else if(recordDateArray.count > 0){
//                            NSLog(@"这一天的数据已经存在");
                            SleepMonitorHistory* sleepMonitorHistory = [recordDateArray objectAtIndex:0];
                            sleepMonitorHistory.recordDate = myDate;
                            sleepMonitorHistory.recordValue = sleepMonitorValue;
                            NSError* error = nil;
                            if([self.managedObjectContext save:&error]){
//                                NSLog(@"修改数据成功");
                                recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
//                                NSLog(@"修改后的数据条数是:%d",recordDateArray.count);
                            }
                        }
                        break;
                    }
                    case 1:{
                        //前二天
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 2]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        //这一天的数据不存在
                        if(recordDateArray.count == 0){
                            
                            SleepMonitorHistory* sleepMonitorHistory = [NSEntityDescription insertNewObjectForEntityForName:@"SleepMonitorHistory" inManagedObjectContext:self.managedObjectContext];
                            sleepMonitorHistory.recordDate = myDate;
                            sleepMonitorHistory.recordValue = sleepMonitorValue;
                            if([self.managedObjectContext save:&error]){
//                                NSLog(@"保存数据成功");
                                recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
//                                NSLog(@"保存后的数据条数是:%d",recordDateArray.count);
                            }
                        }
                        //存储出错
                        else if(recordDateArray == nil) {
//                            NSLog(@"获取recordDateArray出错:%@,%@",error,[error userInfo]);
                        }
                        //这一天的数据已经存在
                        else if(recordDateArray.count > 0){
//                            NSLog(@"这一天的数据已经存在");
                            SleepMonitorHistory* sleepMonitorHistory = [recordDateArray objectAtIndex:0];
                            sleepMonitorHistory.recordDate = myDate;
                            sleepMonitorHistory.recordValue = sleepMonitorValue;
                            NSError* error = nil;
                            if([self.managedObjectContext save:&error]){
//                                NSLog(@"修改数据成功");
                                recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
//                                NSLog(@"修改后的数据条数是:%d",recordDateArray.count);
                            }
                        }
                        break;
                    }
                    case 2:{
                        //前三天
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 3]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        //这一天的数据不存在
                        if(recordDateArray.count == 0){
                            
                            SleepMonitorHistory* sleepMonitorHistory = [NSEntityDescription insertNewObjectForEntityForName:@"SleepMonitorHistory" inManagedObjectContext:self.managedObjectContext];
                            sleepMonitorHistory.recordDate = myDate;
                            sleepMonitorHistory.recordValue = sleepMonitorValue;
                            if([self.managedObjectContext save:&error]){
//                                NSLog(@"保存数据成功");
                                recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
//                                NSLog(@"保存后的数据条数是:%d",recordDateArray.count);
                            }
                        }
                        //存储出错
                        else if(recordDateArray == nil) {
//                            NSLog(@"获取recordDateArray出错:%@,%@",error,[error userInfo]);
                        }
                        //这一天的数据已经存在
                        else if(recordDateArray.count > 0){
//                            NSLog(@"这一天的数据已经存在");
                            SleepMonitorHistory* sleepMonitorHistory = [recordDateArray objectAtIndex:0];
                            sleepMonitorHistory.recordDate = myDate;
                            sleepMonitorHistory.recordValue = sleepMonitorValue;
                            NSError* error = nil;
                            if([self.managedObjectContext save:&error]){
//                                NSLog(@"修改数据成功");
                                recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
//                                NSLog(@"修改后的数据条数是:%d",recordDateArray.count);
                            }
                        }
                        break;
                    }
                    case 3:{
                        //前四天
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 4]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        //这一天的数据不存在
                        if(recordDateArray.count == 0){
                            
                            SleepMonitorHistory* sleepMonitorHistory = [NSEntityDescription insertNewObjectForEntityForName:@"SleepMonitorHistory" inManagedObjectContext:self.managedObjectContext];
                            sleepMonitorHistory.recordDate = myDate;
                            sleepMonitorHistory.recordValue = sleepMonitorValue;
                            if([self.managedObjectContext save:&error]){
//                                NSLog(@"保存数据成功");
                                recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
//                                NSLog(@"保存后的数据条数是:%d",recordDateArray.count);
                            }
                        }
                        //存储出错
                        else if(recordDateArray == nil) {
//                            NSLog(@"获取recordDateArray出错:%@,%@",error,[error userInfo]);
                        }
                        //这一天的数据已经存在
                        else if(recordDateArray.count > 0){
//                            NSLog(@"这一天的数据已经存在");
                            SleepMonitorHistory* sleepMonitorHistory = [recordDateArray objectAtIndex:0];
                            sleepMonitorHistory.recordDate = myDate;
                            sleepMonitorHistory.recordValue = sleepMonitorValue;
                            NSError* error = nil;
                            if([self.managedObjectContext save:&error]){
//                                NSLog(@"修改数据成功");
                                recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
//                                NSLog(@"修改后的数据条数是:%d",recordDateArray.count);
                            }
                        }
                        break;
                    }
                    case 4:{
                        //前五天
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 5]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        //这一天的数据不存在
                        if(recordDateArray.count == 0){
                            
                            SleepMonitorHistory* sleepMonitorHistory = [NSEntityDescription insertNewObjectForEntityForName:@"SleepMonitorHistory" inManagedObjectContext:self.managedObjectContext];
                            sleepMonitorHistory.recordDate = myDate;
                            sleepMonitorHistory.recordValue = sleepMonitorValue;
                            if([self.managedObjectContext save:&error]){
//                                NSLog(@"保存数据成功");
                                recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
//                                NSLog(@"保存后的数据条数是:%d",recordDateArray.count);
                            }
                        }
                        //存储出错
                        else if(recordDateArray == nil) {
//                            NSLog(@"获取recordDateArray出错:%@,%@",error,[error userInfo]);
                        }
                        //这一天的数据已经存在
                        else if(recordDateArray.count > 0){
//                            NSLog(@"这一天的数据已经存在");
                            SleepMonitorHistory* sleepMonitorHistory = [recordDateArray objectAtIndex:0];
                            sleepMonitorHistory.recordDate = myDate;
                            sleepMonitorHistory.recordValue = sleepMonitorValue;
                            NSError* error = nil;
                            if([self.managedObjectContext save:&error]){
//                                NSLog(@"修改数据成功");
                                recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
//                                NSLog(@"修改后的数据条数是:%d",recordDateArray.count);
                            }
                        }
                        break;
                    }
                    case 5:{
                        //前六天
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 6]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        //这一天的数据不存在
                        if(recordDateArray.count == 0){
                            
                            SleepMonitorHistory* sleepMonitorHistory = [NSEntityDescription insertNewObjectForEntityForName:@"SleepMonitorHistory" inManagedObjectContext:self.managedObjectContext];
                            sleepMonitorHistory.recordDate = myDate;
                            sleepMonitorHistory.recordValue = sleepMonitorValue;
                            if([self.managedObjectContext save:&error]){
//                                NSLog(@"保存数据成功");
                                recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
//                                NSLog(@"保存后的数据条数是:%d",recordDateArray.count);
                            }
                        }
                        //存储出错
                        else if(recordDateArray == nil) {
//                            NSLog(@"获取recordDateArray出错:%@,%@",error,[error userInfo]);
                        }
                        //这一天的数据已经存在
                        else if(recordDateArray.count > 0){
//                            NSLog(@"这一天的数据已经存在");
                            SleepMonitorHistory* sleepMonitorHistory = [recordDateArray objectAtIndex:0];
                            sleepMonitorHistory.recordDate = myDate;
                            sleepMonitorHistory.recordValue = sleepMonitorValue;
                            NSError* error = nil;
                            if([self.managedObjectContext save:&error]){
//                                NSLog(@"修改数据成功");
                                recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
//                                NSLog(@"修改后的数据条数是:%d",recordDateArray.count);
                            }
                        }
                        break;
                    }
                    case 6:{
                        //前七天
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 7]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        //这一天的数据不存在
                        if(recordDateArray.count == 0){
                            
                            SleepMonitorHistory* sleepMonitorHistory = [NSEntityDescription insertNewObjectForEntityForName:@"SleepMonitorHistory" inManagedObjectContext:self.managedObjectContext];
                            sleepMonitorHistory.recordDate = myDate;
                            sleepMonitorHistory.recordValue = sleepMonitorValue;
                            if([self.managedObjectContext save:&error]){
//                                NSLog(@"保存数据成功");
                                recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
//                                NSLog(@"保存后的数据条数是:%d",recordDateArray.count);
                            }
                        }
                        //存储出错
                        else if(recordDateArray == nil) {
//                            NSLog(@"获取recordDateArray出错:%@,%@",error,[error userInfo]);
                        }
                        //这一天的数据已经存在
                        else if(recordDateArray.count > 0){
//                            NSLog(@"这一天的数据已经存在");
                            SleepMonitorHistory* sleepMonitorHistory = [recordDateArray objectAtIndex:0];
                            sleepMonitorHistory.recordDate = myDate;
                            sleepMonitorHistory.recordValue = sleepMonitorValue;
                            [self saveContext];
                        }
                        break;
                    }
                    default:{
                        break;
                    }
                }
            }
            //历史平均心率
            else if([@"04" isEqual:tag]){
                NSFetchRequest* request = [[NSFetchRequest alloc]init];
                [request setEntity:heartRateEntity];
                
                NSTimeInterval secondsPerDay = 24 * 60 * 60;
                NSDate* date = [NSDate date] ;
                NSString* myDate = @"";
                
                NSString* dateTag = [WWDTools stringFromIndexCount:4 count:2 from:value];
                NSString* pulseStr = [WWDTools stringFromIndexCount:6 count:6 from:value];
                switch ([dateTag intValue]) {
                    case 0:
                    {
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 1]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            HeartRateHistory* heartRateHistory = [NSEntityDescription insertNewObjectForEntityForName:@"HeartRateHistory" inManagedObjectContext:self.managedObjectContext];
                            heartRateHistory.recordDate = myDate;
                            heartRateHistory.recordValue = pulseStr;
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            HeartRateHistory* heartRateHistory = [recordDateArray objectAtIndex:0];
                            heartRateHistory.recordDate = myDate;
                            heartRateHistory.recordValue = pulseStr;
                            [self saveContext];
                        }
                        break;
                    }
                    case 1:
                    {
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 2]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            HeartRateHistory* heartRateHistory = [NSEntityDescription insertNewObjectForEntityForName:@"HeartRateHistory" inManagedObjectContext:self.managedObjectContext];
                            heartRateHistory.recordDate = myDate;
                            heartRateHistory.recordValue = pulseStr;
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            HeartRateHistory* heartRateHistory = [recordDateArray objectAtIndex:0];
                            heartRateHistory.recordDate = myDate;
                            heartRateHistory.recordValue = pulseStr;
                            [self saveContext];
                        }
                        break;
                    }
                    case 2:
                    {
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 3]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            HeartRateHistory* heartRateHistory = [NSEntityDescription insertNewObjectForEntityForName:@"HeartRateHistory" inManagedObjectContext:self.managedObjectContext];
                            heartRateHistory.recordDate = myDate;
                            heartRateHistory.recordValue = pulseStr;
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            HeartRateHistory* heartRateHistory = [recordDateArray objectAtIndex:0];
                            heartRateHistory.recordDate = myDate;
                            heartRateHistory.recordValue = pulseStr;
                            [self saveContext];
                        }
                        break;
                    }
                    case 3:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 4]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            HeartRateHistory* heartRateHistory = [NSEntityDescription insertNewObjectForEntityForName:@"HeartRateHistory" inManagedObjectContext:self.managedObjectContext];
                            heartRateHistory.recordDate = myDate;
                            heartRateHistory.recordValue = pulseStr;
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            HeartRateHistory* heartRateHistory = [recordDateArray objectAtIndex:0];
                            heartRateHistory.recordDate = myDate;
                            heartRateHistory.recordValue = pulseStr;
                            [self saveContext];
                        }
                        break;
                    }
                    case 4:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 5]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            HeartRateHistory* heartRateHistory = [NSEntityDescription insertNewObjectForEntityForName:@"HeartRateHistory" inManagedObjectContext:self.managedObjectContext];
                            heartRateHistory.recordDate = myDate;
                            heartRateHistory.recordValue = pulseStr;
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            HeartRateHistory* heartRateHistory = [recordDateArray objectAtIndex:0];
                            heartRateHistory.recordDate = myDate;
                            heartRateHistory.recordValue = pulseStr;
                            [self saveContext];
                        }
                        break;
                    }
                    case 5:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 6]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            HeartRateHistory* heartRateHistory = [NSEntityDescription insertNewObjectForEntityForName:@"HeartRateHistory" inManagedObjectContext:self.managedObjectContext];
                            heartRateHistory.recordDate = myDate;
                            heartRateHistory.recordValue = pulseStr;
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            HeartRateHistory* heartRateHistory = [recordDateArray objectAtIndex:0];
                            heartRateHistory.recordDate = myDate;
                            heartRateHistory.recordValue = pulseStr;
                            [self saveContext];
                        }
                        break;
                    }
                    case 6:
                    {
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 7]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            HeartRateHistory* heartRateHistory = [NSEntityDescription insertNewObjectForEntityForName:@"HeartRateHistory" inManagedObjectContext:self.managedObjectContext];
                            heartRateHistory.recordDate = myDate;
                            heartRateHistory.recordValue = pulseStr;
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            HeartRateHistory* heartRateHistory = [recordDateArray objectAtIndex:0];
                            heartRateHistory.recordDate = myDate;
                            heartRateHistory.recordValue = pulseStr;
                            [self saveContext];
                        }
                        break;
                    }
                    default:
                        break;
                }
//                NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
//                NSLog(@"heart history count : %d",recordDateArray.count);
            }
            //计步历史--step
            else if([@"00" isEqual:tag]){
                
                
                NSTimeInterval secondsPerDay = 24 * 60 * 60;
                NSDate* date = [NSDate date] ;
                NSString* myDate = @"";
                
                NSString* dateTag = [WWDTools stringFromIndexCount:4 count:2 from:value];
                NSInteger stepValueInt = [WWDTools intFromHexString:[WWDTools stringFromIndexCount:6 count:8 from:value]];
                NSString* stepValueStr = [NSString stringWithFormat:@"%d", stepValueInt];
                switch ([dateTag intValue]) {
                    case 0:{
                        NSFetchRequest* request = [[NSFetchRequest alloc]init];
                        [request setEntity:pedoStepEntity];
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 1]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
//                        NSLog(@"step array count : %d, %@",recordDateArray.count,myDate);
                        if (recordDateArray.count == 0) {
                            PedoStepHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoStepHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoStepHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
//                            NSLog(@"数据已经存在!");
                            [self saveContext];
                        }
                        break;
                    }
                    case 1:{
                        NSFetchRequest* request = [[NSFetchRequest alloc]init];
                        [request setEntity:pedoStepEntity];
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 2]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoStepHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoStepHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoStepHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
//                            NSLog(@"数据已经存在!");
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 2:{
                        NSFetchRequest* request = [[NSFetchRequest alloc]init];
                        [request setEntity:pedoStepEntity];
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 3]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoStepHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoStepHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoStepHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
//                            NSLog(@"数据已经存在!");
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 3:{
                        NSFetchRequest* request = [[NSFetchRequest alloc]init];
                        [request setEntity:pedoStepEntity];
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 4]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoStepHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoStepHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoStepHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
//                            NSLog(@"数据已经存在!");
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 4:{
                        NSFetchRequest* request = [[NSFetchRequest alloc]init];
                        [request setEntity:pedoStepEntity];
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 5]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoStepHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoStepHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoStepHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
//                            NSLog(@"数据已经存在!");
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 5:{
                        NSFetchRequest* request = [[NSFetchRequest alloc]init];
                        [request setEntity:pedoStepEntity];
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 6]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoStepHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoStepHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoStepHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
//                            NSLog(@"数据已经存在!");
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 6:{
                        NSFetchRequest* request = [[NSFetchRequest alloc]init];
                        [request setEntity:pedoStepEntity];
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 7]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoStepHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoStepHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoStepHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
//                            NSLog(@"数据已经存在!");
                            [self saveContext];
                        }
                        
                        break;
                    }
                    default:
                        break;
                }
            }
            //计步历史--dist(0.00)
            else if([@"01" isEqual:tag]){
                NSFetchRequest* request = [[NSFetchRequest alloc]init];
                [request setEntity:pedoDistEntity];
                
                NSTimeInterval secondsPerDay = 24 * 60 * 60;
                NSDate* date = [NSDate date] ;
                NSString* myDate = @"";
                
                NSString* dateTag = [WWDTools stringFromIndexCount:4 count:2 from:value];
                //                NSInteger stepValueInt = [WWDTools intFromHexString:[WWDTools stringFromIndexCount:6 count:8 from:value]];
                //                double stepValueDouble = stepValueInt / 100;
                NSString* stepValueStr = [WWDTools stringFromIndexCount:6 count:8 from:value];
                switch ([dateTag intValue]) {
                    case 0:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 1]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoDistHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoDistHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoDistHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }
                        break;
                    }
                    case 1:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 2]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoDistHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoDistHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoDistHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 2:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 3]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoDistHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoDistHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoDistHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 3:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 4]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoDistHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoDistHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoDistHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 4:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 5]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoDistHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoDistHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoDistHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 5:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 6]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoDistHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoDistHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoDistHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 6:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 7]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoDistHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoDistHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoDistHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }
                        
                        break;
                    }
                    default:
                        break;
                }
            }
            //计步历史--cal(0.0)
            else if([@"02" isEqual:tag]){
                NSFetchRequest* request = [[NSFetchRequest alloc]init];
                [request setEntity:pedoCalEntity];
                
                NSTimeInterval secondsPerDay = 24 * 60 * 60;
                NSDate* date = [NSDate date] ;
                NSString* myDate = @"";
                
                NSString* dateTag = [WWDTools stringFromIndexCount:4 count:2 from:value];
                NSInteger stepValueInt = [WWDTools intFromHexString:[WWDTools stringFromIndexCount:6 count:8 from:value]];
                double stepValueDouble = stepValueInt / 10;
                NSString* stepValueStr = [NSString stringWithFormat:@"%0.1f", stepValueDouble];
                switch ([dateTag intValue]) {
                    case 0:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 1]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoCalHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoCalHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoCalHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }
                        break;
                    }
                    case 1:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 2]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoCalHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoCalHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoCalHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 2:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 3]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoCalHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoCalHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoCalHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 3:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 4]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoCalHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoCalHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoCalHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 4:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 5]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoCalHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoCalHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoCalHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 5:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 6]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoCalHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoCalHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoCalHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 6:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 7]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoCalHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoCalHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoCalHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }
                        
                        break;
                    }
                    default:
                        break;
                }
            }
            //计步历史--time
            else if([@"03" isEqual:tag]){
                NSFetchRequest* request = [[NSFetchRequest alloc]init];
                [request setEntity:pedoTimeEntity];
                
                NSTimeInterval secondsPerDay = 24 * 60 * 60;
                NSDate* date = [NSDate date] ;
                NSString* myDate = @"";
                
                NSString* dateTag = [WWDTools stringFromIndexCount:4 count:2 from:value];
                
                NSString* stepValueStr = [WWDTools stringFromIndexCount:6 count:6 from:value];
//                NSLog(@"time s value is :%@",stepValueStr);
                switch ([dateTag intValue]) {
                    case 0:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 1]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoTimeHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoTimeHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoTimeHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
//                            NSLog(@"数据已经存在!");
                            [self saveContext];
                        }
                        break;
                    }
                    case 1:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 2]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoTimeHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoTimeHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoTimeHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
//                            NSLog(@"数据已经存在!");
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 2:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 3]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoTimeHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoTimeHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoTimeHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
//                            NSLog(@"数据已经存在!");
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 3:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 4]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoTimeHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoTimeHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoTimeHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
//                            NSLog(@"数据已经存在!");
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 4:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 5]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoTimeHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoTimeHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoTimeHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
//                            NSLog(@"数据已经存在!");
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 5:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 6]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoTimeHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoTimeHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoTimeHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
//                            NSLog(@"数据已经存在!");
                            [self saveContext];
                        }
                        
                        break;
                    }
                    case 6:{
                        myDate = [WWDTools stringFromIndexCount:0 count:10 from:[NSString stringWithFormat:@"%@",[date dateByAddingTimeInterval:-secondsPerDay * 7]]];
                        request.predicate = [NSPredicate predicateWithFormat:@"recordDate=%@",myDate];
                        NSError* error = nil;
                        NSArray* recordDateArray = [[self.managedObjectContext executeFetchRequest:request error:&error]mutableCopy];
                        if (recordDateArray.count == 0) {
                            PedoTimeHistory* pedoStepHistory = [NSEntityDescription insertNewObjectForEntityForName:@"PedoTimeHistory" inManagedObjectContext:self.managedObjectContext];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
                            
                            [self saveContext];
                        }else if (recordDateArray > 0){
                            PedoTimeHistory* pedoStepHistory = [recordDateArray objectAtIndex:0];
                            pedoStepHistory.recordDate = myDate;
                            pedoStepHistory.recordValue = stepValueStr;
//                            NSLog(@"数据已经存在!");
                            [self saveContext];
                        }
                        
                        break;
                    }
                    default:
                        break;
                }
            }
        }
        //设置数
        else if([@"FD" isEqual:idString]){
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            NSString* targetStr = [WWDTools stringFromIndexCount:16 count:8 from:value];
            NSInteger targetI = [WWDTools intFromHexString:targetStr];
            [defaults setInteger:targetI forKey:@"targetInteger"];
        }
    }
}

@end
