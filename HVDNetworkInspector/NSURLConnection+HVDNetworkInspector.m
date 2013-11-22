//
//  NSURLConnection+HVDNetworkInspector.m
//
//  Created by Harshad on 21/11/13.
//  Copyright (c) 2013 LBS. All rights reserved.
//

#import "NSURLConnection+HVDNetworkInspector.h"
#import "HVDNetworkInspector.h"
#import <objc/runtime.h>

@interface HVDNetworkInspector (Private_Logging)

+ (void)logStartDate:(NSDate *)date forRequest:(NSURLRequest *)request;

+ (void)logEndDate:(NSDate *)date data:(NSData *)data forRequest:(NSURLRequest *)request;

+ (void)logFailuerForRequest:(NSURLRequest *)request;

+ (void)logResponse:(NSURLResponse *)response forRequest:(NSURLRequest *)request;


@end



@interface HVDNetworkInspectorDelegateReplacement : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLConnectionDownloadDelegate>

+ (instancetype)delegateForConnection:(NSURLConnection *)connection;

@end

@implementation HVDNetworkInspectorDelegateReplacement {
    __weak NSURLConnection *_connection;
}

+ (instancetype)delegateForConnection:(NSURLConnection *)connection {

    HVDNetworkInspectorDelegateReplacement *delegate = [[[self class] alloc] init];

    delegate->_connection = connection;

    return delegate;
}

- (BOOL)respondsToSelector:(SEL)aSelector {

    return [_connection HVD_respondsToSelector:aSelector];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_connection HVD_conformsToProtocol:aProtocol];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation setTarget:_connection];
    [anInvocation invoke];
}


@end



char const *CNIOriginalDelegateKey = "CNIOriginalDelegateKey";
char const *CNIDownloadedDataKey = "CNIDownloadedDataKey";

@implementation NSURLConnection (HVDNetworkInspector)

#pragma mark - Initialisation

+ (NSData *)HVD_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse *__autoreleasing *)response error:(NSError *__autoreleasing *)error {
    [HVDNetworkInspector logStartDate:[NSDate date] forRequest:request];

    NSData *data = [self HVD_sendSynchronousRequest:request returningResponse:response error:error];
    
    [HVDNetworkInspector logResponse:*response forRequest:request];
    
    if (error != nil) {
        [HVDNetworkInspector logEndDate:[NSDate date] data:data forRequest:request];
    } else {
        [HVDNetworkInspector logFailuerForRequest:request];
    }


    return data;
}

+ (void)HVD_sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))handler {
    
    [HVDNetworkInspector logStartDate:[NSDate date] forRequest:request];
    
    [self HVD_sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [HVDNetworkInspector logResponse:response forRequest:request];
        
        if (error == nil) {
            [HVDNetworkInspector logEndDate:[NSDate date] data:data forRequest:request];
        } else {
            [HVDNetworkInspector logFailuerForRequest:request];
        }

        
        [queue addOperationWithBlock:^{
            
            handler(response, data, error);
            
        }];
    }];
}

- (id)HVD_initWithRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDelegate>)delegate {

    [self HVD_setDelegate:delegate];

    return [self HVD_initWithRequest:request delegate:[HVDNetworkInspectorDelegateReplacement delegateForConnection:self]];
}

- (id)HVD_initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately {

    [self HVD_setDelegate:delegate];

    return [self HVD_initWithRequest:request delegate:[HVDNetworkInspectorDelegateReplacement delegateForConnection:self] startImmediately:startImmediately];
    
}

#pragma mark Protocol checks

- (BOOL)HVD_conformsToProtocol:(Protocol *)aProtocol {

    Protocol *connectionDelegate = @protocol(NSURLConnectionDelegate);
    Protocol *connectionDataDelegate = @protocol(NSURLConnectionDataDelegate);

    if (protocol_isEqual(aProtocol, connectionDelegate)
        || protocol_isEqual(aProtocol, connectionDataDelegate)) {

        return YES;
    }

    return [[self HVD_delegate] conformsToProtocol:aProtocol];
}

- (BOOL)HVD_respondsToSelector:(SEL)aSelector {

    SEL didFailWithError = @selector(connection:didFailWithError:);
    SEL didReceiveResponse = @selector(connection:didReceiveResponse:);
    SEL didReceiveData = @selector(connection:didReceiveData:);
    SEL didFinishLoading = @selector(connectionDidFinishLoading:);

    if (sel_isEqual(aSelector, didFailWithError)
        || sel_isEqual(aSelector, didReceiveResponse)
        || sel_isEqual(aSelector, didReceiveData)
        || sel_isEqual(aSelector, didFinishLoading)) {

        return YES;
    }

    return [self HVD_delegateRespondsToSelector:aSelector];
}


#pragma mark - Delegate management

- (id)HVD_delegate {
    return objc_getAssociatedObject(self, CNIOriginalDelegateKey);
}

- (void)HVD_setDelegate:(id)delegate {
    objc_setAssociatedObject(self, CNIOriginalDelegateKey, delegate, OBJC_ASSOCIATION_ASSIGN);
}


- (BOOL)HVD_delegateRespondsToSelector:(SEL)aSelector {
    return [[self HVD_delegate] respondsToSelector:aSelector];
}

#pragma mark - Loading

- (void)HVD_start {
    [HVDNetworkInspector logStartDate:[NSDate date] forRequest:[self originalRequest]];

    [self HVD_start];
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([self HVD_delegateRespondsToSelector:@selector(connection:willSendRequestForAuthenticationChallenge:)]) {
        [[self HVD_delegate] connection:connection willSendRequestForAuthenticationChallenge:challenge];
    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    if ([self HVD_delegateRespondsToSelector:@selector(connection:canAuthenticateAgainstProtectionSpace:)]) {
        return [[self HVD_delegate] connection:connection canAuthenticateAgainstProtectionSpace:protectionSpace];
    }
    
    return NO;
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([self HVD_delegateRespondsToSelector:@selector(connection:didCancelAuthenticationChallenge:)]) {
        [[self HVD_delegate] connection:connection didCancelAuthenticationChallenge:challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([self HVD_delegateRespondsToSelector:@selector(connection:didReceiveAuthenticationChallenge:)]) {
        [[self HVD_delegate] connection:connection didReceiveAuthenticationChallenge:challenge];
    }
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    if ([self HVD_delegateRespondsToSelector:@selector(connectionShouldUseCredentialStorage:)]) {
        [[self HVD_delegate] connectionShouldUseCredentialStorage:connection];
    }
    
    return YES;
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [HVDNetworkInspector logFailuerForRequest:self.originalRequest];
    
    objc_setAssociatedObject(self, CNIDownloadedDataKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ([self HVD_delegateRespondsToSelector:@selector(connection:didFailWithError:)]) {
        [[self HVD_delegate] connection:connection didFailWithError:error];
    }
}


#pragma mark - NSURLConnectionDataDelegate methods


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [HVDNetworkInspector logResponse:response forRequest:[self originalRequest]];
    objc_setAssociatedObject(self, CNIDownloadedDataKey, [NSMutableData new], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ([self HVD_delegateRespondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [[self HVD_delegate] connection:connection didReceiveResponse:response];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSMutableData *currentData = objc_getAssociatedObject(self, CNIDownloadedDataKey);
    [currentData appendData:data];
    if ([self HVD_delegateRespondsToSelector:@selector(connection:didReceiveData:)]) {
        [[self HVD_delegate] connection:connection didReceiveData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if ([self HVD_delegateRespondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [[self HVD_delegate] connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [HVDNetworkInspector logEndDate:[NSDate date] data:(objc_getAssociatedObject(self, CNIDownloadedDataKey)) forRequest:[self originalRequest]];
    
    objc_setAssociatedObject(self, CNIDownloadedDataKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ([self HVD_delegateRespondsToSelector:@selector(connectionDidFinishLoading:)]) {
        [[self HVD_delegate] connectionDidFinishLoading:connection];
    }
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    if ([self HVD_delegateRespondsToSelector:@selector(connection:willSendRequest:redirectResponse:)]) {
        return [[self HVD_delegate] connection:connection willSendRequest:request redirectResponse:redirectResponse];
    }
    
    return nil;
}

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request; {
    if ([self HVD_delegateRespondsToSelector:@selector(connection:needNewBodyStream:)]) {
        return [[self HVD_delegate] connection:connection needNewBodyStream:request];
    }
    
    return nil;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    if ([self HVD_delegateRespondsToSelector:@selector(connection:willCacheResponse:)]) {
        return [[self HVD_delegate] connection:connection willCacheResponse:cachedResponse];
    }
    
    return nil;
}

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    if ([self HVD_delegateRespondsToSelector:@selector(connection:didWriteData:totalBytesWritten:expectedTotalBytes:)]) {
        [[self HVD_delegate] connection:connection didWriteData:bytesWritten totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
    }
}

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    if ([self HVD_delegateRespondsToSelector:@selector(connectionDidResumeDownloading:totalBytesWritten:expectedTotalBytes:)]) {
        [[self HVD_delegate] connectionDidResumeDownloading:connection totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
    }
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    [HVDNetworkInspector logEndDate:[NSDate date] data:(objc_getAssociatedObject(self, CNIDownloadedDataKey)) forRequest:[self originalRequest]];
    objc_setAssociatedObject(self, CNIDownloadedDataKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ([self HVD_delegateRespondsToSelector:@selector(connectionDidFinishDownloading:destinationURL:)]) {
        [[self HVD_delegate] connectionDidFinishDownloading:connection destinationURL:destinationURL];
    }
}

@end