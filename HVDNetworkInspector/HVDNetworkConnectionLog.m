//
//  HVDNetworkConnectionMetric.m
//
//  Created by Harshad on 21/11/13.
//  Copyright (c) 2013 LBS. All rights reserved.
//

#import "HVDNetworkConnectionLog.h"

long long const NetworkConnectinLogMaxDataLength = 500000;

@interface HVDNetworkConnectionLog () {
    long long _dataLength;
    NSString *_dataDescription;
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

- (void)setFetchedData:(NSData *)data {
    _dataLength = [data length];
    if ([data length] > NetworkConnectinLogMaxDataLength) {
        _dataDescription = @"----Data too large----";
    } else {
        _dataDescription = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
}

- (long long)fetchedDataLength {
    return _dataLength;
}

- (NSString *)fetchedDataAsUTF8String {
    return _dataDescription;
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

- (NSString *)formattedReport {
    
    NSString *report = [NSString stringWithFormat:@"%@\n\n", self.request.URL.absoluteString];
    
    report = [report stringByAppendingFormat:@"============================================\n\n"];
    
    report = [report stringByAppendingFormat:@"HTTP method: %@\n", self.request.HTTPMethod];
    
    report = [report stringByAppendingFormat:@"Total Time: %f\t\tBytes:%lld\n\n", [self loadTime], _dataLength];
    
    report = [report stringByAppendingFormat:@"============================================\n\n"];

    NSString *responseDescription = @"";
    if ([self.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)self.response;
        responseDescription = [responseDescription stringByAppendingFormat:@"Status code: %d\n", response.statusCode];
        for (id header in [response.allHeaderFields allKeys]) {
            responseDescription = [responseDescription stringByAppendingFormat:@"%@ = %@\n", header, [response.allHeaderFields valueForKey:header]];
        }
    }
    report = [report stringByAppendingFormat:@"Received response:\n%@\n\n", responseDescription];
    
    report = [report stringByAppendingFormat:@"============================================\n\n"];
    
    report = [report stringByAppendingFormat:@"Data:\n%@\n\n", [self fetchedDataAsUTF8String]];
    
    report = [report stringByAppendingFormat:@"============================================\n\n"];
    
    return report;
}
@end
