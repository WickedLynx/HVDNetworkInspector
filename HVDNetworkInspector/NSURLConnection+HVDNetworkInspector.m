//
//  NSURLConnection+HVDNetworkInspector.m
//  NetworkInspectorDemo
//
//  Created by Harshad on 21/11/13.
//  Copyright (c) 2013 LBS. All rights reserved.
//

#import "NSURLConnection+HVDNetworkInspector.h"
#import "HVDNetworkInspector.h"
#import <objc/runtime.h>

@interface NSURLConnection (HVDNetworkInspector_Private_Messaging)

- (void)HVD_receivedMessage:(SEL)message withArguments:(NSArray *)arguments;

- (BOOL)HVD_connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;

- (BOOL)HVD_connectionShouldUseCredentialStorage:(NSURLConnection *)connection;

- (void)HVD_connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;

- (NSURLRequest *)HVD_connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse;

- (NSInputStream *)HVD_connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request;

- (NSCachedURLResponse *)HVD_connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse;

- (void)HVD_connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes;

- (void)HVD_connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes;

- (BOOL)HVD_delegateRespondsToSelector:(SEL)aSelector;

- (void)HVD_setDelegate:(id)delegate;

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

    if ([NSStringFromSelector(aSelector) isEqualToString:NSStringFromSelector(@selector(connectionDidFinishLoading:))]) {
        return YES;
    }

    return [_connection HVD_delegateRespondsToSelector:aSelector];
}


#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {

    [_connection HVD_receivedMessage:@selector(connection:willSendRequestForAuthenticationChallenge:) withArguments:@[connection, challenge]];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [_connection HVD_connection:connection canAuthenticateAgainstProtectionSpace:protectionSpace];
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [_connection HVD_receivedMessage:@selector(connection:didCancelAuthenticationChallenge:) withArguments:@[connection, challenge]];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [_connection HVD_receivedMessage:@selector(connection:didReceiveAuthenticationChallenge:) withArguments:@[connection, challenge]];
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    return [_connection HVD_connectionShouldUseCredentialStorage:connection];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [HVDNetworkInspector logEndDate:[NSDate date] forRequest:[_connection originalRequest]];

    [_connection HVD_receivedMessage:@selector(connection:didFailWithError:) withArguments:@[connection, error]];
}

#pragma mark - NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_connection HVD_receivedMessage:@selector(connection:didReceiveResponse:) withArguments:@[connection, response]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_connection HVD_receivedMessage:@selector(connection:didReceiveData:) withArguments:@[connection, data]];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    [_connection HVD_connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [HVDNetworkInspector logEndDate:[NSDate date] forRequest:[_connection originalRequest]];

    [_connection HVD_receivedMessage:@selector(connectionDidFinishLoading:) withArguments:@[connection]];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    return [_connection HVD_connection:connection willSendRequest:request redirectResponse:redirectResponse];
}

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request; {
    return [_connection HVD_connection:connection needNewBodyStream:request];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return [_connection HVD_connection:connection willCacheResponse:cachedResponse];
}

#pragma mark - NSURLConnectionDownloadDelegate methods

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL {
    [HVDNetworkInspector logEndDate:[NSDate date] forRequest:[_connection originalRequest]];
    [_connection HVD_receivedMessage:@selector(connectionDidFinishDownloading:destinationURL:) withArguments:@[connection, destinationURL]];
}

- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    [_connection HVD_connectionDidResumeDownloading:connection totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    [_connection HVD_connection:connection didWriteData:bytesWritten totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
}

@end

char const *CNIOriginalDelegateKey = "CNIOriginalDelegateKey";

@implementation NSURLConnection (HVDNetworkInspector)

#pragma mark - Initialisation

+ (NSData *)HVD_sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse *__autoreleasing *)response error:(NSError *__autoreleasing *)error {
    [HVDNetworkInspector logStartDate:[NSDate date] forRequest:request];

    NSData *data = [self HVD_sendSynchronousRequest:request returningResponse:response error:error];

    [HVDNetworkInspector logEndDate:[NSDate date] forRequest:request];

    return data;
}

- (id)HVD_initWithRequest:(NSURLRequest *)request delegate:(id<NSURLConnectionDelegate>)delegate {

    [self HVD_setDelegate:delegate];

    HVDNetworkInspectorDelegateReplacement *replacementDelegate = [HVDNetworkInspectorDelegateReplacement delegateForConnection:self];

    return [self HVD_initWithRequest:request delegate:replacementDelegate];
}

- (id)HVD_initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately {

    [self HVD_setDelegate:delegate];

    HVDNetworkInspectorDelegateReplacement *replacementDelegate = [HVDNetworkInspectorDelegateReplacement delegateForConnection:self];

    return [self HVD_initWithRequest:request delegate:replacementDelegate startImmediately:startImmediately];
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


#pragma mark - Common method forwarding

- (void)HVD_receivedMessage:(SEL)message withArguments:(NSArray *)arguments {

    id originalDelegate = [self HVD_delegate];

    if ([originalDelegate respondsToSelector:message]) {

        if (arguments == nil) {

            [originalDelegate performSelector:message];

        } else {

            Method method = class_getInstanceMethod([originalDelegate class], message);

            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)]];
            [invocation setSelector:message];
            [invocation setTarget:originalDelegate];

            for (int argumentIndex = 0; argumentIndex != arguments.count; ++argumentIndex) {

                [invocation setArgument:(__bridge void *)(arguments[argumentIndex]) atIndex:(argumentIndex + 2)];
            }

            [invocation invoke];
        }

    }

}

#pragma mark - NSURLConnectionDelegate forwarded methods

- (BOOL)HVD_connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {

    if ([[self HVD_delegate] respondsToSelector:@selector(connection:canAuthenticateAgainstProtectionSpace:)]) {
        return [[self HVD_delegate] connection:connection canAuthenticateAgainstProtectionSpace:protectionSpace];
    }

    return NO;
}

- (BOOL)HVD_connectionShouldUseCredentialStorage:(NSURLConnection *)connection {

    if ([[self HVD_delegate] respondsToSelector:@selector(connectionShouldUseCredentialStorage:)]) {
        return [[self HVD_delegate] connectionShouldUseCredentialStorage:connection];
    }

    return YES;
}

#pragma mark - NSURLConnectionDataDelegate forwarded methods

- (void)HVD_connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {

    if ([[self HVD_delegate] respondsToSelector:@selector(connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [[self HVD_delegate] connection:connection didSendBodyData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

- (NSURLRequest *)HVD_connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {

    if ([[self HVD_delegate] respondsToSelector:@selector(connection:willSendRequest:redirectResponse:)]) {
        return [[self HVD_delegate] connection:connection willSendRequest:request redirectResponse:redirectResponse];
    }

    return nil;
}

- (NSInputStream *)HVD_connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request {
    if ([[self HVD_delegate] respondsToSelector:@selector(connection:needNewBodyStream:)]) {
        return [[self HVD_delegate] connection:connection needNewBodyStream:request];
    }

    return nil;
}

- (NSCachedURLResponse *)HVD_connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    if ([[self HVD_delegate] respondsToSelector:@selector(connection:willCacheResponse:)]) {
        return [[self HVD_delegate] connection:connection willCacheResponse:cachedResponse];
    }

    return nil;
}

#pragma mark - NSURLConnectionDownloadDelegate forwarded methods

- (void)HVD_connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    if ([[self HVD_delegate] respondsToSelector:@selector(connectionDidResumeDownloading:totalBytesWritten:expectedTotalBytes:)]) {
        [[self HVD_delegate] connectionDidResumeDownloading:connection totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
    }
}

- (void)HVD_connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes {
    if ([[self HVD_delegate] respondsToSelector:@selector(connection:didWriteData:totalBytesWritten:expectedTotalBytes:)]) {
        [[self HVD_delegate] connection:connection didWriteData:bytesWritten totalBytesWritten:totalBytesWritten expectedTotalBytes:expectedTotalBytes];
    }
}

@end