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

    });

}

+ (void)showReport {
    [[[self class] sharedInspector] showReportView];
}

+ (void)logStartDate:(NSDate *)date forRequest:(NSURLRequest *)request {
    HVDNetworkConnectionLog *metric = [[[self class] sharedInspector] metricForRequest:request];
    [metric setStartDate:date];
}

+ (void)logEndDate:(NSDate *)date forRequest:(NSURLRequest *)request {
    HVDNetworkConnectionLog *metric = [[[self class] sharedInspector] metricForRequest:request];
    [metric setEndDate:date];
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
        if ([[aMetric request] isEqual:request]) {
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

- (void)showReportView {
    [_reportViewController setMetrics:_metrics];
    [_reportViewController refresh];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_reportViewController];

    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:navigationController animated:YES completion:NULL];
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
