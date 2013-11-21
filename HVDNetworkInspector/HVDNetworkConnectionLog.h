//
//  HVDNetworkConnectionMetric.h
//  NetworkInspectorDemo
//
//  Created by Harshad on 21/11/13.
//  Copyright (c) 2013 LBS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HVDNetworkConnectionMetricRequestType) {
    HVDNetworkConnectionMetricRequestTypeGET = 0,
    HVDNetworkConnectionMetricRequestTypePOST
};

@interface HVDNetworkConnectionLog : NSObject

+ (instancetype)metricForRequest:(NSURLRequest *)request;

- (NSTimeInterval)loadTime;
- (NSURLRequest *)request;
- (NSURL *)requestURL;
- (NSString *)requestBodyDataAsString;
- (NSData *)requestBody;
- (HVDNetworkConnectionMetricRequestType)requestType;
- (BOOL)finishedLoading;

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;



@end
