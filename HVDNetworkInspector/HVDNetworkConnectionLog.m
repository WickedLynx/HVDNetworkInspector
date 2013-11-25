//
//  HVDNetworkConnectionMetric.m
//
//  Created by Harshad on 21/11/13.
//  Copyright (c) 2013 LBS. All rights reserved.
//

#import "HVDNetworkConnectionLog.h"

long long const NetworkConnectinLogMaxDataLength = 500000;

@interface HVDNetworkConnectionLog () {
    long long _receivedDataLength;
    NSString *_receivedDataDescription;
    long long _sentDataLength;
    NSString *_sentDataDescription;
    NSDictionary *_sentHeaders;
}

@property (strong, nonatomic) NSURLRequest *originalRequest;


@end

@implementation HVDNetworkConnectionLog

+ (instancetype)metricForRequest:(NSURLRequest *)request {

    HVDNetworkConnectionLog *metric = [[[self class] alloc] init];

    [metric setOriginalRequest:request];

    metric->_sentDataLength = request.HTTPBody.length;

    if (request.HTTPBody.length > 0) {

        if (request.HTTPBody.length < NetworkConnectinLogMaxDataLength) {
            NSString *sentDataDescription = [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding];
            metric->_sentDataDescription = sentDataDescription;
        } else {
            metric->_sentDataDescription = @"Data too large";
        }

    }

    metric->_sentHeaders = [request allHTTPHeaderFields];

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
    _receivedDataLength = [data length];
    if ([data length] > NetworkConnectinLogMaxDataLength) {
        _receivedDataDescription = @"----Data too large----";
    } else {
        _receivedDataDescription = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
}

- (long long)fetchedDataLength {
    return _receivedDataLength;
}

- (long long)sentDataLength {
    return _sentDataLength;
}

- (NSString *)fetchedDataAsUTF8String {
    return _receivedDataDescription;
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
    
    NSString *report = [NSString stringWithFormat:@"\n%@\n\n", self.request.URL.absoluteString];
    
    report = [report stringByAppendingFormat:@"==========================================\n\n"];

    if (self.error != nil) {

        report = [report stringByAppendingFormat:@"Error:\n\n"];

        for (NSString *key in self.error.userInfo.allKeys) {
            report = [report stringByAppendingFormat:@"%@: %@\n\n", key, [self.error.userInfo valueForKey:key]];
        }

        report = [report stringByAppendingFormat:@"==========================================\n\n"];

    }
    
    report = [report stringByAppendingFormat:@"HTTP method: %@\n\n", self.request.HTTPMethod];
    
    report = [report stringByAppendingFormat:@"Total Time: %f seconds\n\nReceived bytes: %lld\n\n", [self loadTime], _receivedDataLength];

    report = [report stringByAppendingFormat:@"Sent bytes: %lld\n\n", _sentDataLength];
    
    report = [report stringByAppendingFormat:@"==========================================\n\n"];

    report = [report stringByAppendingFormat:@"Request headers:\n\n"];

    for (NSString *headerField in [_sentHeaders allKeys]) {
        report = [report stringByAppendingFormat:@"%@: %@\n\n", headerField, [_sentHeaders valueForKey:headerField]];
    }

    report = [report stringByAppendingFormat:@"==========================================\n\n"];

    report = [report stringByAppendingFormat:@"Sent Data: \n\n%@\n\n", _sentDataDescription];

    report = [report stringByAppendingFormat:@"==========================================\n\n"];

    NSString *responseDescription = @"";
    if ([self.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)self.response;
        responseDescription = [responseDescription stringByAppendingFormat:@"Status code: %ld\n\n", (long)response.statusCode];
        for (id header in [response.allHeaderFields allKeys]) {
            responseDescription = [responseDescription stringByAppendingFormat:@"%@: %@\n\n", header, [response.allHeaderFields valueForKey:header]];
        }
    }
    report = [report stringByAppendingFormat:@"Received response:\n\n%@", responseDescription];
    
    report = [report stringByAppendingFormat:@"==========================================\n\n"];
    
    report = [report stringByAppendingFormat:@"Received Data:\n\n%@\n\n", [self fetchedDataAsUTF8String]];
    
    report = [report stringByAppendingFormat:@"==========================================\n\n"];
    
    return report;
}
@end
