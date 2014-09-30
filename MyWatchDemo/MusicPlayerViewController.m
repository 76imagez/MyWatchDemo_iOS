//
//  MusicPlayerViewController.m
//  MyWatchDemo
//
//  Created by maginawin on 14-9-5.
//  Copyright (c) 2014年 mycj.wwd. All rights reserved.
//

#import "MusicPlayerViewController.h"

@interface MusicPlayerViewController ()
@property AVAudioPlayer* myPlayer;
@property (nonatomic, assign) WWDAppDelegate* myAppDelegate;
@end

@implementation MusicPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _myAppDelegate = (WWDAppDelegate*)[[UIApplication sharedApplication]delegate];
    [_myAppDelegate getMusicMessage];
    _musicTable.dataSource = self;
    _musicTable.delegate = self;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_myAppDelegate musicArray].count;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    NSUInteger rowNo = indexPath.row;
    
    UILabel* name = (UILabel*)[cell viewWithTag:1];
    UILabel* artist = (UILabel*)[cell viewWithTag:2];
    MusicBean* bean = [[_myAppDelegate musicArray] objectAtIndex:rowNo];
    name.text = bean.musicName;
    artist.text = bean.musicArtist;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger rowNo = indexPath.row;
    [_myAppDelegate playMusic:rowNo];
}


- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)scanMusic:(id)sender {
    [_myAppDelegate getMusicMessage];
    [_musicTable reloadData];
}

- (IBAction)playOrPauseMusic:(id)sender {
    [_myAppDelegate playMusicPauseOrStart];
}

- (IBAction)playNextMusic:(id)sender {
    [_myAppDelegate playNextMusic];
}

- (IBAction)playLastMusic:(id)sender {
    [_myAppDelegate playLastMusic];
}
@end
