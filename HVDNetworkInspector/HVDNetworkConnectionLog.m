//
//  HVDNetworkConnectionMetric.m
//  NetworkInspectorDemo
//
//  Created by Harshad on 21/11/13.
//  Copyright (c) 2013 LBS. All rights reserved.
//

#import "HVDNetworkConnectionLog.h"

@interface HVDNetworkConnectionLog () {

}

@property (strong, nonatomic) NSURLRequest *originalRequest;


@end

@implementation HVDNetworkConnectionLog

+ (instancetype)metricForRequest:(NSURLRequest *)request {

    HVDNetworkConnectionLog *metric = [[[self class] alloc] init];

    [metric setOriginalRequest:request];

    return metric;
}


- (NSURLRequest *)request {
    return [self originalRequest];
}

- (NSTimeInterval)loadTime {
    NSDate *date = self.endDate;
    if (date == nil) {
        date = [NSDate date];
    }
    return [date timeIntervalSinceDate:self.startDate];
}

- (NSURL *)requestURL {
    return [[self originalRequest] URL];
}

- (NSData *)requestBody {

    return [[self originalRequest] HTTPBody];
}

- (NSString *)requestBodyDataAsString {

    if ([self requestBody] != nil) {
        return [[NSString alloc] initWithData:[self requestBody] encoding:NSUTF8StringEncoding];
    }

    return nil;
}

- (HVDNetworkConnectionMetricRequestType)requestType {

    if ([[[self request] HTTPMethod] caseInsensitiveCompare:@"POST"] == NSOrderedSame) {
        return HVDNetworkConnectionMetricRequestTypePOST;
    }

    return HVDNetworkConnectionMetricRequestTypeGET;
}

- (BOOL)finishedLoading {
    return (self.endDate != nil);
}
@end
