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

#import <Foundation/Foundation.h>
#import "SFKeyStoreKey.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Object to encrypt/decrypt key store using secure enclave
 */
@interface SFSecureKeyStoreKey : SFKeyStoreKey

/**
 @return YES if secure enclave is available
 */
+ (BOOL) isSecureEnclaveAvailable;

/**
 Create a new SFSecureKeyStoreKey
 NB: it is not saved to the key chain until [key saveKey] is called
 */
+ (instancetype) createKey;

/**
 Create a new SFSecureKeyStoreKey with given label
 NB: it is not saved to the key chain until [key saveKey] is called
 @param label the key label
 */
+ (instancetype) createKey:(NSString*)label;

/**
 Retrieve key with given label from keychain
 @param label the key label
 @return nil if not found
 */
+ (nullable instancetype) retrieveKey:(NSString*)label;

/**
 Delete key with given label from keychain
 @param label the key label
 */
+ (void) deleteKey:(NSString*)label;

/**
 Save to keychain
 */
- (OSStatus) saveKey;

@end

NS_ASSUME_NONNULL_END