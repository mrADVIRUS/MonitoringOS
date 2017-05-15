//
//  HCMonitoringHelper.m
//  MobileSystemMonitoring
//
//  Created by Sergiy Lyahovchuk on 14.05.17.
//  Copyright © 2017 HardCode. All rights reserved.
//

#import "HCMonitoringHelper.h"
#import <UIKit/UIKit.h>
#import "Macroses.h"
#import "Types.h"
#import "Utils.h"
#import "HCNotificationManager.h"

@interface HCMonitoringHelper()

@property (nonatomic,strong) NSTimer * timer;
@property (nonatomic,strong) NSString * logPath;
@property (nonatomic,strong) NSString * lastLogFilePath;

@end

@implementation HCMonitoringHelper

#pragma mark - Class methods (Public)

+ (void) startMonitoring
{
    [HCMonitoringHelper sharedHelper];
}

#pragma mark - Class methods (Private)

+ (instancetype) sharedHelper
{
    static HCMonitoringHelper * sharedMonitoringHelper;
    static dispatch_once_t sharedMonitoringHelper_once;
    dispatch_once(&sharedMonitoringHelper_once, ^{
        sharedMonitoringHelper = [[self alloc] init];
    });
    
    return sharedMonitoringHelper;
}

#pragma mark - Lifecycle

- (instancetype) init
{
    self = [super init];
    if (self) {
        NSNotificationCenter * notifCenter = [NSNotificationCenter defaultCenter];
        [notifCenter addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [notifCenter addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [notifCenter addObserver:self selector:@selector(didChangeDefaultLogFolder:) name:HCdidChangeDefaultLogFolderNotification object:nil];
        
        EMonitoringFolderType folderType = [[NSUserDefaults standardUserDefaults] integerForKey:k_typeFolder];
        [self checkFolderForLogsByType:folderType];
    }
    return self;
}

#pragma mark - Private

/*
- (void) startTimer
{
    [self stopTimer];
    
    NSTimeInterval interval = [[NSUserDefaults standardUserDefaults] doubleForKey:k_userTimeInterval];
    if (interval <= 0) {
        interval = k_defaultInterval;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                  target:self
                                                selector:@selector(onTimer:)
                                                userInfo:nil
                                                 repeats:YES];
}
*/
- (void) stopTimer
{
    if (self.timer) {
        if ([self.timer isValid])
            [self.timer invalidate];
        self.timer = nil;
    }
}

- (void) onTimer:(NSTimer*)aTimer
{
    [self monitoringOS];
}

- (void) monitoringOS
{
    NSLog(@"Monitoring...");
    //select folder be type
    
    NSString * addInfo = [NSString stringWithFormat:@"Device: %@\nOperating System: %@\nApplication: %@ %@\nConnection Type: %@\nIP : %@\nTime Zone: %@\nStorage: %@\nRAM: %@", getDeviceModel(), getDeviceOS(), getAppName(), getAppVersion(), getConnectionType(), getIP(), getTimeZone(), availableDiskSpace(), getRAMInfo()];
    
//    NSLog(@"RESULT - %@", addInfo);
    [self writeStringToFile:addInfo];
}

- (void) writeStringToFile:(NSString *)aString
{
    BOOL saveDataToNewFile = rand() % 2;
//    NSLog(@"RANDOM = '%d'", saveDataToNewFile);
    
    NSString *fileName = nil;
    
    if (saveDataToNewFile) {
        //save string to new file
        NSDate *date = [NSDate date];
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        [formater setDateFormat:@"yyyy-MM-dd-HH-mm-ss-SSSS"];
        NSString *timeString = [formater stringFromDate:date];
        fileName = [NSString stringWithFormat:@"log-%@%@", timeString, @".log"];
        self.lastLogFilePath = [fileName copy];
        
        NSLog(@"--->>> Save log to new file %@", self.lastLogFilePath);
    } else {
        //change last log file
        if (self.lastLogFilePath == nil) {
            NSDate *date = [NSDate date];
            NSDateFormatter *formater = [[NSDateFormatter alloc] init];
            [formater setDateFormat:@"yyyy-MM-dd-HH-mm-ss-SSSS"];
            NSString *timeString = [formater stringFromDate:date];
            self.lastLogFilePath = [NSString stringWithFormat:@"log-%@%@", timeString, @".log"];
        }
        
        fileName = [NSString stringWithFormat:@"%@", self.lastLogFilePath];
        NSString *fileAtPath = [self.logPath stringByAppendingPathComponent:fileName];
        
        //check if last file exists
        NSString *fileData = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
            fileData = @"";
        } else {
            fileData = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:fileAtPath] encoding:NSUTF8StringEncoding];
        }
        aString = [NSString stringWithFormat:@"%@\n\n%@", fileData, aString];
        
        NSLog(@"--->>> Save log to last file %@", self.lastLogFilePath);
    }
    
    NSString *fileAtPath = [self.logPath stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    [[aString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
    
    //send notification
    [HCNotificationManager sendLocalNotificationWithNewFile:saveDataToNewFile];
}

- (void) checkFolderForLogsByType:(EMonitoringFolderType)aFolderType
{
    switch (aFolderType) {
        case EMonitoringFolderTypeDocuments:
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            self.logPath = [paths[0] stringByAppendingPathComponent:@"logs"];
        }
            break;
        case EMonitoringFolderTypeLibrary:
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            self.logPath = [paths[0] stringByAppendingPathComponent:@"logs"];
        }
            break;
        case EMonitoringFolderTypeTemp:
        {
            NSString *tmpDirectory = NSTemporaryDirectory();
            self.logPath = [tmpDirectory stringByAppendingPathComponent:@"logs"];
        }
            break;
        default:
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            self.logPath = [paths[0] stringByAppendingPathComponent:@"logs"];
        }
            break;
    }
    
    //check if exist folder
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (([fileManager fileExistsAtPath:self.logPath isDirectory:&isDir] && isDir) == NO) {
        [fileManager createDirectoryAtPath:self.logPath
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
        NSLog(@"Folder %@ created", self.logPath);
    } else {
        NSLog(@"Folder %@ isExists", self.logPath);
    }
}

#pragma mark - NSNotifications

- (void) applicationDidEnterBackgroundNotification:(NSNotification*)aNotification
{
//    [self startTimer];
    NSLog(@"Start Monitoring MobileOS");
    [self stopTimer];
    
    __block UIBackgroundTaskIdentifier bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:bgTask];
    }];
    
    NSTimeInterval interval = [[NSUserDefaults standardUserDefaults] doubleForKey:k_userTimeInterval];
    
    self.timer = [NSTimer timerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(monitoringOS)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer
                              forMode:NSRunLoopCommonModes];
    
    
    //    [HCNotificationManager testLocalNotificationiOS10];
}

- (void) applicationWillEnterForegroundNotification:(NSNotification*)aNotification
{
    [self stopTimer];
    
    [HCNotificationManager cancelAllLocalNotification];
    NSLog(@"Stop Monitoring MobileOS");
}

- (void) didChangeDefaultLogFolder:(NSNotification*)aNotification
{
    NSDictionary * userInfo = aNotification.userInfo;
    EMonitoringFolderType folderType = [userInfo[@"folderType"] integerValue];
//    NSLog(@"%lu", (unsigned long)folderType);
    
    [self checkFolderForLogsByType:folderType];
}

@end
