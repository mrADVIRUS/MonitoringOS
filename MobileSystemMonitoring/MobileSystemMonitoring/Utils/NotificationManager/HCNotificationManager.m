//
//  HCNotificationManager.m
//  MobileSystemMonitoring
//
//  Created by Sergiy Lyahovchuk on 15.05.17.
//  Copyright © 2017 HardCode. All rights reserved.
//

#import "HCNotificationManager.h"
#import "Macroses.h"
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@implementation HCNotificationManager

#pragma mark - Class methods (Public)

+ (void) sendLocalNotificationWithNewFile:(BOOL)aStatus
{
    [self sendNotificationByStatusFile:aStatus];
}

+ (void) cancelAllLocalNotification
{
    if (SYSTEM_VERSION_LESS_THAN(@"10.0"))
    {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    } else {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center removeAllPendingNotificationRequests];
    }
}

+ (void) testLocalNotificationiOS10
{
    [self sendNotificationForIOS10ByFileStatus:YES];
}

#pragma mark - Class methods (Private)

+ (void) sendNotificationByStatusFile:(BOOL)aStatus
{
    if (SYSTEM_VERSION_LESS_THAN(@"10.0"))
    {
        [self sendNotificationForIOS9ByFileStatus:aStatus];
    } else {
        [self sendNotificationForIOS10ByFileStatus:aStatus];
    }
}

+ (void) sendNotificationForIOS9ByFileStatus:(BOOL)aFileStatus
{
    NSString *msg = [NSString stringWithFormat:aFileStatus ? @"Created new log file!" : @"The last log file was - modified!"];
    CGFloat timeInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:k_userTimeInterval];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    localNotification.alertBody = msg;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

+ (void) sendNotificationForIOS10ByFileStatus:(BOOL)aFileStatus
{
    NSString *msg = [NSString stringWithFormat:aFileStatus ? @"Created new log file!" : @"The last log file was - modified!"];
    CGFloat timeInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:k_userTimeInterval];
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"Notification!";
    content.body = msg;
//    content.title = [NSString localizedUserNotificationStringForKey:@"Elon said:" arguments:nil];
//    content.body = [NSString localizedUserNotificationStringForKey:@"Hello Tom！Get up, let's play with Jerry!"
//                                                         arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
    
    //var1
//    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    [calendar setTimeZone:[NSTimeZone localTimeZone]];
//    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitTimeZone fromDate:[[NSDate date] dateByAddingTimeInterval:timeInterval]];
//    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
    
    
    
    
    //var2
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timeInterval repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Test"
                                                                          content:content trigger:trigger];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Local Notification succeeded");
        }
        else {
            NSLog(@"Local Notification failed");
        }
    }];
    
}
@end
