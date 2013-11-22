//
//  HVDNetworkInspector.m
//  HVDNetworkInspector
//
//  Created by Harshad on 21/11/13.
//  Copyright (c) 2013 LBS. All rights reserved.
//

#import "HVDNetworkInspector.h"
#import <objc/runtime.h>
#import "NSURLConnection+HVDNetworkInspector.h"
#import "HVDNetworkConnectionLog.h"
#import "HVDNetworkInspectorReportViewController.h"

static HVDNetworkInspector *SharedInspector = nil;

@interface HVDNetworkInspector () {
    NSMutableArray *_metrics;
    HVDNetworkInspectorReportViewController *_reportViewController;

}

+ (instancetype)sharedInspector;
+ (void)exchangeInstanceMethod:(SEL)newMethod withMethod:(SEL)oldMethod forClass:(Class)class;
+ (void)exchangeClassMethod:(SEL)newMethod withMethod:(SEL)oldMethod forClass:(Class)class;

- (HVDNetworkConnectionLog *)metricForRequest:(NSURLRequest *)request;
- (void)showReportView;
- (void)refreshReportView;

@end

@implementation HVDNetworkInspector

#pragma mark - Public methods

+ (void)loadInspector {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        [self exchangeInstanceMethod:@selector(HVD_start) withMethod:@selector(start) forClass:[NSURLConnection class]];

        [self exchangeInstanceMethod:@selector(HVD_initWithRequest:delegate:) withMethod:@selector(initWithRequest:delegate:) forClass:[NSURLConnection class]];

        [self exchangeInstanceMethod:@selector(HVD_initWithRequest:delegate:startImmediately:) withMethod:@selector(initWithRequest:delegate:startImmediately:) forClass:[NSURLConnection class]];

        [self exchangeClassMethod:@selector(HVD_sendSynchronousRequest:returningResponse:error:) withMethod:@selector(sendSynchronousRequest:returningResponse:error:) forClass:[NSURLConnection class]];
        
        [self exchangeClassMethod:@selector(HVD_sendAsynchronousRequest:queue:completionHandler:) withMethod:@selector(sendAsynchronousRequest:queue:completionHandler:) forClass:[NSURLConnection class]];

    });

}

+ (void)showReport {
    [[[self class] sharedInspector] showReportView];
}

+ (void)logStartDate:(NSDate *)date forRequest:(NSURLRequest *)request {
    HVDNetworkConnectionLog *metric = [[[self class] sharedInspector] metricForRequest:request];
    
    if (metric.requestType != HVDNetworkConnectionMetricRequestTypeGET) {
        [metric setFetchedData:request.HTTPBody];
    }
    [metric setState:HVDNetworkConnectionLogStateStarted];
    [metric setStartDate:date];
    
    [[[self class] sharedInspector] refreshReportView];
    
}

+ (void)logEndDate:(NSDate *)date data:(NSData *)data forRequest:(NSURLRequest *)request {
    HVDNetworkConnectionLog *metric = [[[self class] sharedInspector] metricForRequest:request];
    [metric setState:HVDNetworkConnectionLogStateCompleted];
    [metric setEndDate:date];
    [metric setFetchedData:data];
    
    [[[self class] sharedInspector] reloadReport];
}

+ (void)logResponse:(NSURLResponse *)response forRequest:(NSURLRequest *)request {
    HVDNetworkConnectionLog *log = [[[self class] sharedInspector] metricForRequest:request];
    [log setResponse:response];
    
    [[[self class] sharedInspector] reloadReport];
}

+ (void)logFailuerForRequest:(NSURLRequest *)request {
    HVDNetworkConnectionLog *log = [[[self class] sharedInspector] metricForRequest:request];
    [log setState:HVDNetworkConnectionLogStateFailed];
    [log setEndDate:[NSDate date]];
    
    [[[self class] sharedInspector] reloadReport];
}

#pragma mark - Private methods

- (instancetype)init {
    self = [super init];

    if (self != nil) {

        _metrics = [NSMutableArray new];
        _reportViewController = [[HVDNetworkInspectorReportViewController alloc] init];
    }

    return self;
}

- (HVDNetworkConnectionLog *)metricForRequest:(NSURLRequest *)request {

    HVDNetworkConnectionLog *metric = nil;
    for (HVDNetworkConnectionLog *aMetric in _metrics) {
        if ([aMetric request] == request) {
            metric = aMetric;
            break;
        }
    }

    if (metric == nil) {

        metric = [HVDNetworkConnectionLog metricForRequest:request];
        [_metrics addObject:metric];
    }

    return metric;
}

- (void)reloadReport {

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshReportView) object:nil];

    [self performSelector:@selector(refreshReportView) withObject:nil afterDelay:1.0f];
}

- (void)refreshReportView {

    dispatch_async(dispatch_get_main_queue(), ^{
        if (_reportViewController.presentingViewController != nil) {
            [_reportViewController setMetrics:_metrics];
            [_reportViewController refresh];
        }
    });

}

- (void)clearReport {
    [_metrics removeAllObjects];
    [self reloadReport];
}

- (void)showReportView {

    dispatch_async(dispatch_get_main_queue(), ^{
        if (_reportViewController.presentingViewController == nil) {

            [_reportViewController setMetrics:_metrics];
            [_reportViewController refresh];

            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_reportViewController];

            [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:navigationController animated:YES completion:^{

                [_reportViewController.navigationItem.leftBarButtonItem setTarget:self];
                [_reportViewController.navigationItem.leftBarButtonItem setAction:@selector(clearReport)];
            }];
        }
    });


}

+ (instancetype)sharedInspector {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        SharedInspector = [[[self class] alloc] init];

    });

    return SharedInspector;
}

+ (void)exchangeInstanceMethod:(SEL)newMethod withMethod:(SEL)oldMethod forClass:(Class)class {
    Method old = class_getInstanceMethod(class, oldMethod);
    Method new = class_getInstanceMethod(class, newMethod);

    if (class_addMethod(class, oldMethod, method_getImplementation(new), method_getTypeEncoding(new))) {
        class_replaceMethod(class, newMethod, method_getImplementation(old), method_getTypeEncoding(old));
    } else {
        method_exchangeImplementations(old, new);
    }

}

+ (void)exchangeClassMethod:(SEL)newMethod withMethod:(SEL)oldMethod forClass:(Class)class {

    Method old = class_getClassMethod(class, oldMethod);
    Method new = class_getClassMethod(class, newMethod);

    class = object_getClass((id)class);

    if (class_addMethod(class, oldMethod, method_getImplementation(new), method_getTypeEncoding(new))) {
        class_replaceMethod(class, newMethod, method_getImplementation(old), method_getTypeEncoding(old));
    } else {
        method_exchangeImplementations(old, new);
    }
}




@end
