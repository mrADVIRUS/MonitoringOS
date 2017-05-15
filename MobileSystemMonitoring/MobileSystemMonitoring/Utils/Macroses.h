//
//  Macroses.h
//  MobileSystemMonitoring
//
//  Created by Sergiy Lyahovchuk on 14.05.17.
//  Copyright © 2017 HardCode. All rights reserved.
//

#ifndef HC_Macroses_h
#define HC_Macroses_h

#define DISP_MAIN_THREAD                dispatch_get_main_queue()
#define DISP_BGND_THREAD                dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define WEAKSELF_DECLARATION            __weak __typeof(self)weakSelf = self;
#define STRONGSELF_DECLARATION          __strong __typeof(weakSelf)strongSelf = weakSelf;

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define k_defaultInterval       5.0
#define k_userTimeInterval      @"userTimeInterval"
#define k_appFirstTime          @"appFirstTime"
#define k_typeFolder            @"typeFolder"

extern NSString * const HCdidChangeDefaultLogFolderNotification;

#endif /* Macroses_h */
