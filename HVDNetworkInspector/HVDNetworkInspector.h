//
//  HVDNetworkInspector.h
//  HVDNetworkInspector
//
//  Created by Harshad on 21/11/13.
//  Copyright (c) 2013 LBS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HVDNetworkInspector : NSObject

+ (void)loadInspector;

+ (void)showReport;

+ (void)logStartDate:(NSDate *)date forRequest:(NSURLRequest *)request;

+ (void)logEndDate:(NSDate *)date forRequest:(NSURLRequest *)request;

@end
