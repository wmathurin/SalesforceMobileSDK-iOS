/*
 Copyright (c) 2019-present, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <XCTest/XCTest.h>
#import <objc/runtime.h>
#import "SFSDKEncryptedURLCache.h"
#import "SFSDKNullURLCache.h"
#import "SFRestAPI.h"
#import "SFNativeRestRequestListener.h"
#import "SFNetwork.h"
#import "SalesforceSDKManager.h"
#import <SalesforceSDKCore/SFDirectoryManager.h>
#import <SalesforceSDKCore/TestSetupUtils.h>
#import "SFSDKTestCredentialsData.h"
#import "SFRestAPI+Blocks.h"

@interface SFRestAPI (Testing)

- (SFNetwork *)networkForRequest:(SFRestRequest *)request;

@end

@interface SFSDKUrlCacheTests : XCTestCase

@end

@implementation SFSDKUrlCacheTests

// TODO: Remove in 9.0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)testDeprecatedEncryptionFlag {

    // Enabled by default
    [SalesforceSDKManager sharedManager];
    XCTAssertTrue([NSURLCache.sharedURLCache isMemberOfClass:[SFSDKEncryptedURLCache class]]);
    NSString *cachePath = [[SFDirectoryManager sharedManager] globalDirectoryOfType:NSCachesDirectory components:@[@"salesforce.mobilesdk.URLCache"]];
    XCTAssertNotNil(cachePath);
    XCTAssertTrue([SalesforceSDKManager sharedManager].encryptURLCache);

    // Disable
    [SalesforceSDKManager sharedManager].encryptURLCache = NO;
    XCTAssertTrue([NSURLCache.sharedURLCache isMemberOfClass:[NSURLCache class]]);
    XCTAssertFalse([SalesforceSDKManager sharedManager].encryptURLCache);

    // Enable again
    [SalesforceSDKManager sharedManager].encryptURLCache = YES;
    XCTAssertTrue([NSURLCache.sharedURLCache isMemberOfClass:[SFSDKEncryptedURLCache class]]);
    XCTAssertTrue([SalesforceSDKManager sharedManager].encryptURLCache);
}

- (void)testSettingCacheTypes {
    // Encrypted enabled by default
    [SalesforceSDKManager sharedManager];
    XCTAssertTrue([NSURLCache.sharedURLCache isMemberOfClass:[SFSDKEncryptedURLCache class]]);
    XCTAssertTrue([SalesforceSDKManager sharedManager].encryptURLCache);
    NSString *cachePath = [[SFDirectoryManager sharedManager] globalDirectoryOfType:NSCachesDirectory components:@[@"salesforce.mobilesdk.URLCache"]];
    XCTAssertNotNil(cachePath);

    // Set back to vanilla URL cache
    [SalesforceSDKManager sharedManager].URLCacheType = kSFURLCacheTypeStandard;
    XCTAssertTrue([NSURLCache.sharedURLCache isMemberOfClass:[NSURLCache class]]);
    XCTAssertFalse([SalesforceSDKManager sharedManager].encryptURLCache);
    
    // Set to null cache
    [SalesforceSDKManager sharedManager].URLCacheType = kSFURLCacheTypeNull;
    XCTAssertTrue([NSURLCache.sharedURLCache isMemberOfClass:[SFSDKNullURLCache class]]);
    XCTAssertFalse([SalesforceSDKManager sharedManager].encryptURLCache);
    
    // Enable encrypted again
    [SalesforceSDKManager sharedManager].URLCacheType = kSFURLCacheTypeEncrypted;
    XCTAssertTrue([NSURLCache.sharedURLCache isMemberOfClass:[SFSDKEncryptedURLCache class]]);
    XCTAssertTrue([SalesforceSDKManager sharedManager].encryptURLCache);
}
#pragma clang diagnostic pop

- (void)testNilURL {
    // NSURLCache ignores requests with bad/nil URLs, make sure we don't crash
    SFSDKEncryptedURLCache *encryptedURLCache = [[SFSDKEncryptedURLCache alloc] init];
    NSString *contentString = @"This is my content";
    NSData *contentData = [contentString dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [[NSURL alloc] initWithString:@"bad string -- will create nil URL"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:url MIMEType:@"text/plain" expectedContentLength:contentData.length textEncodingName:@"NSUTF8StringEncoding"];
    NSCachedURLResponse *toStore = [[NSCachedURLResponse alloc] initWithResponse:response data:contentData userInfo:nil storagePolicy:NSURLCacheStorageAllowed];
    [encryptedURLCache storeCachedResponse:toStore forRequest:request];
    NSCachedURLResponse *cacheResult = [encryptedURLCache cachedResponseForRequest:request];
    XCTAssertNil(cacheResult);
}

- (void)testNullCacheEntry {
    SFSDKNullURLCache *nullURLCache = [[SFSDKNullURLCache alloc] init];
    NSString *contentString = @"This is my content";
    NSData *contentData = [contentString dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = contentData.length;
    NSURL *url = [[NSURL alloc] initWithString:@"https://www.salesforce.com"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:url MIMEType:@"text/plain" expectedContentLength:dataLength textEncodingName:@"NSUTF8StringEncoding"];

    // Should not store
    NSCachedURLResponse *toStore = [[NSCachedURLResponse alloc] initWithResponse:response data:contentData userInfo:nil storagePolicy:NSURLCacheStorageAllowed];
    [nullURLCache storeCachedResponse:toStore forRequest:request];
    NSCachedURLResponse *cacheResult = [nullURLCache cachedResponseForRequest:request];
    XCTAssertNil(cacheResult);
}

- (void)testEncryptedCacheEntry {
    SFSDKEncryptedURLCache *encryptedURLCache = [[SFSDKEncryptedURLCache alloc] init];
    NSString *contentString = @"This is my content";
    NSData *contentData = [contentString dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = contentData.length;
    NSURL *url = [[NSURL alloc] initWithString:@"https://www.salesforce.com"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:url MIMEType:@"text/plain" expectedContentLength:dataLength textEncodingName:@"NSUTF8StringEncoding"];

    NSCachedURLResponse *toStore = [[NSCachedURLResponse alloc] initWithResponse:response data:contentData userInfo:nil storagePolicy:NSURLCacheStorageAllowed];
    [encryptedURLCache storeCachedResponse:toStore forRequest:request];
    NSCachedURLResponse *cacheResult = [encryptedURLCache cachedResponseForRequest:request];
    XCTAssertNotNil(cacheResult);

    NSString *cacheString = [[NSString alloc] initWithData:cacheResult.data encoding:NSUTF8StringEncoding];
    XCTAssertTrue([cacheString isEqualToString:contentString]);
}

- (void)makeRequestsWithBaseURL:(NSString *)baseURL {
    NSArray<NSString *> *standardPngs = @[@"today", @"task", @"report", @"note", @"groups", @"feed", @"dashboard", @"approval"];
    for (NSString *standardPng in standardPngs) {
        NSString *path = [NSString stringWithFormat:@"/img/icon/t4v35/standard/%@_60.png", standardPng];
        SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodGET baseURL:baseURL path:path queryParams:nil];
        request.requiresAuthentication = NO;
        request.endpoint = @"";
        [self sendRequest:request];
    }

    NSArray<NSString *> *customPngs = @[@"custom62", @"custom28"];
    for (NSString *customPng in customPngs) {
        NSString *path = [NSString stringWithFormat:@"/img/icon/t4v35/custom/%@_60.png", customPng];
        SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodGET baseURL:baseURL path:path queryParams:nil];
        request.requiresAuthentication = NO;
        request.endpoint = @"";
        [self sendRequest:request];
    }

    NSArray<NSString *> *actionPngs = @[@"share_thanks", @"share_poll", @"share_post", @"share_link", @"share_file", @"question_post_action", @"new_note"];
    for (NSString *actionPng in actionPngs) {
        NSString *path = [NSString stringWithFormat:@"/img/icon/t4v35/action/%@_120.png", actionPng];
        SFRestRequest *request = [SFRestRequest requestWithMethod:SFRestMethodGET baseURL:baseURL path:path queryParams:nil];
        request.requiresAuthentication = NO;
        request.endpoint = @"";
        [self sendRequest:request];
    }
}

- (void)sendRequest:(SFRestRequest *)request {
    SFSDKTestRequestListener *listener = [[SFSDKTestRequestListener alloc] init];
    SFRestFailBlock failBlock = ^(NSError *error, NSURLResponse *rawResponse) {
        listener.lastError = error;
        listener.returnStatus = kTestRequestStatusDidFail;
    };
    SFRestDictionaryResponseBlock completeBlock = ^(NSDictionary *data, NSURLResponse *rawResponse) {
        listener.dataResponse = data;
        listener.returnStatus = kTestRequestStatusDidLoad;
    };
    [[SFRestAPI sharedGlobalInstance] sendRESTRequest:request
                                            failBlock:failBlock
                                        completeBlock:completeBlock];
    [listener waitForCompletion];
    XCTAssertEqualObjects(listener.returnStatus, kTestRequestStatusDidLoad, @"request failed");
}

@end
