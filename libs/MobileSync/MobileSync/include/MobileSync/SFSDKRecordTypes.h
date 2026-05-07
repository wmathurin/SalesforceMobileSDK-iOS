/*
 Copyright (c) 2022-present, salesforce.com, inc. All rights reserved.

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
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

// ObjC interface stubs for Swift-defined types used by ObjC code.
// For non-SPM builds, MobileSync-Swift.h provides the real declarations.
// For SPM builds, these stubs allow MobileSyncObjC to compile; the Swift
// implementations in MobileSyncSwift satisfy the interfaces at runtime.

#ifdef SWIFT_PACKAGE

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SFMobileSyncSyncManager;

NS_SWIFT_NAME(RecordResponse)
@interface SFSDKRecordResponse : NSObject
@property (nonatomic, readonly) BOOL success;
@property (nonatomic, readonly, nullable) NSString *objectId;
@property (nonatomic, readonly) BOOL recordDoesNotExist;
@property (nonatomic, readonly) BOOL relatedRecordDoesNotExist;
@property (nonatomic, readonly, nullable) NSDictionary *errorJson;
@end

NS_SWIFT_NAME(RecordRequest)
@interface SFSDKRecordRequest : NSObject
@property (nonatomic, nullable) NSString *referenceId;
+ (SFSDKRecordRequest *)requestForCreateWithObjectType:(NSString *)objectType fields:(NSDictionary *)fields NS_SWIFT_NAME(requestForCreate(objectType:fields:));
+ (SFSDKRecordRequest *)requestForUpdateWithObjectType:(NSString *)objectType objectId:(NSString *)objectId fields:(NSDictionary *)fields NS_SWIFT_NAME(requestForUpdate(objectType:objectId:fields:));
+ (SFSDKRecordRequest *)requestForUpsertWithObjectType:(NSString *)objectType externalIdFieldName:(NSString *)externalIdFieldName externalId:(NSString *)externalId fields:(NSDictionary *)fields NS_SWIFT_NAME(requestForUpsert(objectType:externalIdFieldName:externalId:fields:));
+ (SFSDKRecordRequest *)requestForDeleteWithObjectType:(NSString *)objectType objectId:(NSString *)objectId NS_SWIFT_NAME(requestForDelete(objectType:objectId:));
@end

typedef void (^SFSendCompositeRequestCompleteBlock)(NSDictionary<NSString*, SFSDKRecordResponse*> *refIdToResponses);

NS_SWIFT_NAME(CompositeRequestHelper)
@interface SFCompositeRequestHelper : NSObject
+ (void)sendAsCompositeBatchRequest:(SFMobileSyncSyncManager *)syncManager allOrNone:(BOOL)allOrNone recordRequests:(NSArray<SFSDKRecordRequest *> *)recordRequests onComplete:(SFSendCompositeRequestCompleteBlock)onComplete onFail:(void (^)(NSError *))onFail;
+ (void)sendAsCollectionRequests:(SFMobileSyncSyncManager *)syncManager allOrNone:(BOOL)allOrNone recordRequests:(NSArray<SFSDKRecordRequest *> *)recordRequests onComplete:(SFSendCompositeRequestCompleteBlock)onComplete onFail:(void (^)(NSError *))onFail;
+ (NSDictionary<NSString *, NSString *> *)parseIdsFromResponses:(NSDictionary<NSString *, SFSDKRecordResponse *> *)refIdToRecordResponse;
+ (NSDictionary *)updateReferences:(NSDictionary *)record fieldWithRefId:(NSString *)fieldWithRefId refIdToServerId:(NSDictionary<NSString *, NSString *> *)refIdToServerId;
@end

NS_ASSUME_NONNULL_END

#endif // SWIFT_PACKAGE
