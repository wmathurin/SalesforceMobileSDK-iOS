/*
 Copyright (c) 2015-present, salesforce.com, inc. All rights reserved.
 
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
#import <SalesforceSDKCore/SalesforceSDKConstants.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SFEntityIdLength) {
    SFEntityIdLength15 = 15,
    SFEntityIdLength18 = 18,
    SFEntityIdLengthMin = SFEntityIdLength15,
    SFEntityIdLengthMax = SFEntityIdLength18
};

/**Extension to NSString object
 */
@interface NSString (SFAdditions)

/** 
 @return A hex string representation of the supplied data; or `nil` if `data` is `nil` or empty.
 @param data NSData to be represented as a base 16 string.
 */
+ (nullable NSString *)sfsdk_stringWithHexData:(nullable NSData *)data;

/** Returns an SHA 256 hash of the current string
 */
- (NSData *)sfsdk_sha256;

/** Escape XML entities
 
 @param value String value to escape. If nil is passed, this method will return nil.
 */
+ (nullable NSString *)sfsdk_escapeXMLCharacter:(nullable NSString *)value;

/** unescape XML entities
 
@param value String value to unescape. If nil is passed, this method will return nil.
 */
+ (nullable NSString *)sfsdk_unescapeXMLCharacter:(nullable NSString *)value;

/** Trim string by taking out beginning and ending space.*/
- (NSString *)sfsdk_trim;

/** Returns the string in debug build or a redacted version of it
 for production build
 */
- (NSString *)sfsdk_redacted;

/** Returns the string in debug build or a redacted version of it
 for production build. The prefix length is the number of characters
 that won't be redacted from the beginning of the string.
 
 @param prefixLength The number of characters to preserve at the beginning of the string.
 */
- (NSString *)sfsdk_redactedWithPrefix:(NSUInteger)prefixLength;

/** Return YES if string is nil or length is 0 or with white space only
 
 @param string String to check
 */
+ (BOOL)sfsdk_isEmpty:(nullable NSString *)string;

/**
 @return A string with all non-legal URL characters (per RFC 3986) escaped.
 */
- (NSString *)sfsdk_stringByURLEncoding;


/** Strips any HTML markup from the source string.
 */
- (NSString *)sfsdk_stringByStrippingHTML;

/** Returns YES if the string is empty of contains only whitespance or newline characters.
 */
- (BOOL)sfsdk_isEmptyOrWhitespaceAndNewlines;

/**
 @return The 18 character case-insensitive entity ID representing the receiver.
 Returns `nil` if the receiver is not a valid Salesforce entity ID.
 */
- (nullable NSString*)sfsdk_entityId18;

/** Returns a Boolean value that indicates if the given entity ID is equal to the
 receiver. The comparison properly handles comparing 15 character case-sensitive
 ID's against 18 character case-insensitive ID's.
 
 @param entityId The entity ID to compare with the receiver.
 @return Returns `YES` if the given entityId is semantically equal to the receiver,
 otherwise returns `NO`. Returns `NO` if either the given ID or receiver are not
 valid Salesforce entity ID's.
 */
- (BOOL)sfsdk_isEqualToEntityId:(NSString *)entityId;

@end

NS_ASSUME_NONNULL_END
