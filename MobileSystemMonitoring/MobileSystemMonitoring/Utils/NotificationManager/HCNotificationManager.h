//
//  HCNotificationManager.h
//  MobileSystemMonitoring
//
//  Created by Sergiy Lyahovchuk on 15.05.17.
//  Copyright © 2017 HardCode. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCNotificationManager : NSObject

+ (void) sendLocalNotificationWithNewFile:(BOOL)aStatus;
+ (void) cancelAllLocalNotification;
+ (void) testLocalNotificationiOS10;
@end
