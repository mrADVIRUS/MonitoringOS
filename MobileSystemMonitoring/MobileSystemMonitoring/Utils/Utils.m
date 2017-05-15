//
//  Utils.m
//  MobileSystemMonitoring
//
//  Created by Sergiy Lyahovchuk on 14.05.17.
//  Copyright © 2017 HardCode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <mach/mach.h>
#import <mach/mach_host.h>

//#import "Reachability.h"

NSNumber *availableDiskSpace(void) {
    NSError *error = nil;
    NSString *path = NSHomeDirectory();
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:path error:&error];
    if (error) {
        NSLog(@"Error getting attributes of file system for path: %@ %@", path, error);
    }
    else if (attributes) {
//        NSLog(@"Attributes for file system at path: %@\n%@", path, attributes);
        NSNumber *freeSpace = attributes[NSFileSystemFreeSize];
        if (freeSpace) {
            return freeSpace;
        }
    }
    
    NSLog(@"Error when getting free space, returning maximum space");
    return @(NSUIntegerMax);
}

NSString * getDeviceModel()
{
    UIDevice * device = [UIDevice currentDevice];
    return device.model;
}

NSString * getDeviceOS()
{
    UIDevice * device = [UIDevice currentDevice];
    return [NSString stringWithFormat:@"%@ %@", device.systemName, device.systemVersion];
}

NSString * getAppName()
{
    NSDictionary * bundleInfo = [[NSBundle mainBundle] infoDictionary];
    return bundleInfo[@"CFBundleDisplayName"];
}

NSString * getAppVersion()
{
    NSDictionary * bundleInfo = [[NSBundle mainBundle] infoDictionary];
    return [NSString stringWithFormat:@"v.%@", bundleInfo[@"CFBundleVersion"]];
}

NSString * getConnectionType()
{
    /*
    Reachability * reachability = [Reachability reachabilityForInternetConnection];
    if ([reachability isReachable]) {
        NetworkStatus status = [reachability currentReachabilityStatus];
        
        if(status == NotReachable)
        {
            return @"No internet";
        }
        else if (status == ReachableViaWiFi)
        {
            return @"WiFi";
        }
        else if (status == ReachableViaWWAN)
        {
            return @"3G";
        }
    }
    
    return @"Fail to detect internet connection!";
     */
    return @"Unknown";
}

NSString * getIP()
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

NSString * getTimeZone()
{
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    return [NSString stringWithFormat:@"%@ %@", [timeZone name], [timeZone abbreviation]];
}

NSString * getRAMInfo()
{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        NSLog(@"Failed to fetch vm statistics");
    }
    
    /* Stats in bytes */
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    natural_t mem_total = mem_used + mem_free;
    //    DLog(@"used: %u free: %u total: %u", mem_used, mem_free, mem_total);
    return [NSString stringWithFormat:@"used: %u free: %u total: %u", mem_used, mem_free, mem_total];
}
