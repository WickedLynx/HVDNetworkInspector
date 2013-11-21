//
//  NSURLConnection+HVDNetworkInspector.h
//  NetworkInspectorDemo
//
//  Created by Harshad on 21/11/13.
//  Copyright (c) 2013 LBS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection (HVDNetworkInspector)

+ (NSData *)HVD_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse *__autoreleasing *)response error:(NSError *__autoreleasing *)error;

- (id)HVD_initWithRequest:(NSURLRequest *)request delegate:(id <NSURLConnectionDelegate>)delegate;

- (id)HVD_initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately;

- (void)HVD_start;

@end
