/*
 DBHelper.swift
 SmartStore Swift Extensions
 
 Copyright (c) 2021-present, salesforce.com, inc. All rights reserved.
 
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

import Foundation
import GRDB

@objc(SFDBPool)
class DBPool : NSObject {
    let dbPool: DatabasePool
    
    init(dbPool:DatabasePool) {
        self.dbPool = dbPool
    }
}

@objc(SFDBHelper)
class DBHelper : NSObject {
    public func openDatabase(path:String, key:String, salt:String?) throws -> DBPool? {
        var config = Configuration()
        config.prepareDatabase { db in
            // Using sqlcipher 2.x kdf iter because 3.x default (64000) and 4.x default (256000) are too slow
            try db.execute(sql: "PRAGMA cipher_default_kdf_iter = 4000")
            
            if (key.count > 0) {
                try db.usePassphrase(key)
            }
            
            // Migrating and upgrading an existing database in place (preserving data and schema) if necessary
            try db.execute(sql: "PRAGMA cipher_migrate")
            
            if (key.count > 0) {
                if let salt = salt {
                    try db.execute(sql: "PRAGMA cipher_plaintext_header_size = 32")
                    try db.execute(sql: "PRAGMA cipher_salt = \"x'\(salt)'\"")
                    try db.execute(sql: "PRAGMA journal_mode = WAL")
                }
            }
            
            // Verify database
            try db.execute(sql: "SELECT name FROM sqlite_master LIMIT 1")
        }
        
        do {
            return DBPool(dbPool: try DatabasePool(path: path, configuration: config))
        } catch (_ : _) {
            return nil
        }
    }
}
