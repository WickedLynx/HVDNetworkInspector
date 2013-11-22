//
//  NSURLConnection+HVDNetworkInspector.h
//
//  Created by Harshad on 21/11/13.
//  Copyright (c) 2013 LBS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection (HVDNetworkInspector) <NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLConnectionDownloadDelegate>

#pragma mark - Protocol checks

- (BOOL)HVD_conformsToProtocol:(Protocol *)aProtocol;

- (BOOL)HVD_respondsToSelector:(SEL)aSelector;

#pragma mark - Initialisation

+ (NSData *)HVD_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse *__autoreleasing *)response error:(NSError *__autoreleasing *)error;

+ (void)HVD_sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler;

- (id)HVD_initWithRequest:(NSURLRequest *)request delegate:(id <NSURLConnectionDelegate>)delegate;

- (id)HVD_initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately;

#pragma mark - Loading

- (void)HVD_start;

@end
