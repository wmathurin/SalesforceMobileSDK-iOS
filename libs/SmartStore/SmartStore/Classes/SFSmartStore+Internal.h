/*
 Copyright (c) 2012-present, salesforce.com, inc. All rights reserved.
 
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
#import "SFSmartStore.h"
#import <SalesforceSDKCore/SFUserAccount.h>
#import "SFSmartStoreDatabaseManager.h"
@class FMDatabase;
@class FMResultSet;

typedef NS_ENUM(NSUInteger, SFSmartStoreFtsExtension) {
    SFSmartStoreFTS4 = 4,
    SFSmartStoreFTS5 = 5
};

// Buffer size when reading/writing bytes in memory
static NSUInteger kBufferSize = 4096;

// Columns of a soup fts table
static NSString *const ROWID_COL = @"rowid";
static NSString *const PATH_COL = @"path";

// Columns of the soup index map table
static NSString *const SOUP_NAME_COL = @"soupName";
static NSString *const COLUMN_TYPE_COL = @"columnType";

// Table to keep track of soup attributes
static NSString *const SOUP_ATTRS_TABLE = @"soup_attrs";

// Table to keep track of soup's index specs
static NSString *const SOUP_INDEX_MAP_TABLE = @"soup_index_map";

// Columns of long operations status table
static NSString *const TYPE_COL = @"type";
static NSString *const DETAILS_COL = @"details";
static NSString *const STATUS_COL = @"status";

// Table to keep track of status of long operations in flight
static NSString *const LONG_OPERATIONS_STATUS_TABLE = @"long_operations_status";

// Explain support
static NSString *const EXPLAIN_ROWS = @"rows";

@interface SFSmartStore ()

+ (NSString *)licenseKey;

@property (nonatomic, strong) FMDatabaseQueue *storeQueue;
@property (nonatomic, strong) SFSmartStoreDatabaseManager *dbMgr;
@property (nonatomic, assign) BOOL isGlobal;
@property (nonatomic, assign) SFSmartStoreFtsExtension ftsExtension;

/**
 Simply open the db file.
 @return YES if we were able to open the DB file.
 */
- (BOOL)openStoreDatabase;

/**
 Create soup index map table to keep track of soups' index specs (SOUP_INDEX_MAP_TABLE)
 Create soup attributes table to keep track of soups' attributes specs (e.g. external blobs storage)
 and maps arbitrary soup names to soup table names (SOUP_ATTRS_TABLE)
 @return YES if we were able to create the meta tables, NO otherwise.
 */
- (BOOL)createMetaTables;

/**
 Create long operations status table (LONG_OPERATIONS_STATUS_TABLE)
 @return YES if we were able to create the table, NO otherwise.
 */
- (BOOL) createLongOperationsStatusTable;

/**
 Register the soup
 @param soupName The name of the soup to register
 @param indexSpecs Array of one ore more IndexSpec objects as dictionaries
 @param soupTableName The name of the table to use for the soup
 @param db This method is expected to be called from [fmdbqueue inDatabase:^(){ ... }]
 */
- (void)registerSoupWithName:(NSString*)soupName withIndexSpecs:(NSArray*)indexSpecs withSoupTableName:(NSString*) soupTableName withDb:(FMDatabase*) db;


/**
 @param db This method is expected to be called from [fmdbqueue inDatabase:^(){ ... }]
 @return The soup table name from SOUP_ATTRS_TABLE, based on soup name.
 */
- (NSString *)tableNameForSoup:(NSString*)soupName withDb:(FMDatabase*) db;

/**
 @param soupName the name of the soup
 @param db This method is expected to be called from [fmdbqueue inDatabase:^(){ ... }]
 @return NSArray of SFSoupIndex for the given soup
 */
- (NSArray*)indicesForSoup:(NSString*)soupName withDb:(FMDatabase *)db;

/**
 Helper method re-index a soup.
 @param soupName The soup to re-index
 @param indexPaths Array of one ore more IndexSpec objects as dictionaries
 @param db This method is expected to be called from [fmdbqueue inDatabase:^(){ ... }]
 @return YES if the insert was successful, NO otherwise.
 */
- (BOOL) reIndexSoup:(NSString*)soupName withIndexPaths:(NSArray*)indexPaths withDb:(FMDatabase*)db;

/**
 Helper method to insert values into an arbitrary table.
 @param tableName The table to insert the data into.
 @param map A dictionary of key-value pairs to be inserted into table.
 @param db This method is expected to be called from [fmdbqueue inDatabase:^(){ ... }]
 */
- (void)insertIntoTable:(NSString *)tableName values:(NSDictionary *)map withDb:(FMDatabase*)db;

/**
 Helper method to update existing values in a table.
 @param tableName The name of the table to update.
 @param map The column name/value mapping to update.
 @param entryId The ID value used to determine what to update.
 @param idCol The name of the ID column
 @param db This method is expected to be called from [fmdbqueue inDatabase:^(){ ... }]
 */
- (void)updateTable:(NSString*)tableName values:(NSDictionary*)map entryId:(NSNumber*)entryId idCol:(NSString*)idCol withDb:(FMDatabase*)db;


/**
 Helper to query table
 @param table Table
 @param columns Column names
 @param orderBy Order by column
 @param limit Limit
 @param whereClause Where clause
 @param whereArgs  Arguments to where clause
 @param db This method is expected to be called from [fmdbqueue inDatabase:^(){ ... }]
 @return FMResultSet
 */
 - (FMResultSet *)queryTable:(NSString*)table
                 forColumns:(NSArray*)columns
                    orderBy:(NSString*)orderBy
                      limit:(NSString*)limit
                whereClause:(NSString*)whereClause
                  whereArgs:(NSArray*)whereArgs
                      withDb:(FMDatabase*)db;


/**
 @param path Path of interest
 @param soupName name of the soup
 @param db This method is expected to be called from [fmdbqueue inDatabase:^(){ ... }]
 @return The column name for the given path if indexed or nil otherwise.
 */
- (NSString *)columnNameForPath:(NSString *)path inSoup:(NSString *)soupName withDb:(FMDatabase*)db;


/**
 @param path Path of interest
 @param soupName name of the soup
 @param db This method is expected to be called from [fmdbqueue inDatabase:^(){ ... }]
 @return YES if the given path is indexed or NO otherwise.
 */
- (BOOL) hasIndexForPath:(NSString*)path inSoup:(NSString*)soupName withDb:(FMDatabase*) db;

/**
 Similar to System.currentTimeMillis: time in ms since Jan 1 1970
 Used for timestamping created and modified times.
 @return The current number of milliseconds since 1/1/1970.
 */
- (NSNumber*)currentTimeInMilliseconds;

/**
 @return The key used to encrypt the store.
 */
+ (NSString *)encKey;

/**
 @return The key used to encrypt the store for shared mode. Sqlite headers are maintained in plain text for database.
 */
+ (NSString *)salt;

/**
 FOR UNIT TESTING.  Removes all of the shared smart store objects from memory (persisted stores remain).
 */
+ (void)clearSharedStoreMemoryState;

/**
 FOR UNIT TESTING.
 @return string decoded from the specified input stream
 */
+ (NSString*) stringFromInputStream:(NSInputStream*)inputStream;

/**
 Convert smart sql to sql.
 @param smartSql The smart sql to convert.
 @return The sql.
 */
- (NSString*) convertSmartSql:(NSString*)smartSql;


/**
 Remove soup from cache
 @param soupName The name of the soup to remove
 */
- (void)removeFromCache:(NSString*) soupName;

/**
 @return unfinished long operations
 */
- (NSArray*) getLongOperations;


/**
  Execute query
  Log errors and throw exception in case of error
 */
- (FMResultSet*) executeQueryThrows:(NSString*)sql withDb:(FMDatabase*)db;

/**
 Execute query
 Log errors and throw exception in case of error
 */
- (FMResultSet*) executeQueryThrows:(NSString*)sql withArgumentsInArray:(NSArray*)arguments withDb:(FMDatabase*)db;

/**
 Execute update
 Log errors and throw exception in case of error
 */
- (void) executeUpdateThrows:(NSString*)sql withDb:(FMDatabase*)db;

/**
 Execute update
 Log errors and throw exception in case of error
 */
- (void) executeUpdateThrows:(NSString*)sql withArgumentsInArray:(NSArray*)arguments withDb:(FMDatabase*)db;

/**
 Check that the given raw JSON string represents valid JSON.
 Note: If the jsonSerializationCheckEnabled property is set to NO, this method will
 always return YES (i.e. that the result is valid).
 
 @param rawJson The raw JSON string to validate.
 @param fromMethod The method making the call (for logging purposes on failure).
 
 @return YES if the JSON string is valid JSON, NO otherwise.
 */
- (BOOL)checkRawJson:(NSString*)rawJson fromMethod:(NSString*)fromMethod;

@end
