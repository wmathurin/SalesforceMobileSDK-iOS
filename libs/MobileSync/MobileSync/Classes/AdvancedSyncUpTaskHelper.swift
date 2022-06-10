//
//  AdvancedSyncUpTaskHelper.swift
//  MobileSync
//
//  Created by Wolfgang Mathurin on 6/7/22.
//  Copyright (c) 2022-present, salesforce.com, inc. All rights reserved.
// 
//  Redistribution and use of this software in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//  * Redistributions of source code must retain the above copyright notice, this list of conditions
//  and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, this list of
//  conditions and the following disclaimer in the documentation and/or other materials provided
//  with the distribution.
//  * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
//  endorse or promote products derived from this software without specific prior written
//  permission of salesforce.com, inc.
// 
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
//  WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import Foundation

typealias OnSyncUpUpdateCallback = (SyncState, UInt) -> ()
typealias OnSyncUpFailCallback = (SyncState, String, Error) -> ()

@objc(SFAdvancedSyncUpTaskHelper)
class AdvancedSyncUpTaskHelper:NSObject {
    
    @objc
    static func syncUp(syncManager:SyncManager,
                       sync:SyncState,
                       dirtyRecordIds:Array<NSNumber>,
                       onUpdate: OnSyncUpUpdateCallback,
                       onFail: OnSyncUpFailCallback
    ) {
        
//        final String soupName = sync.getSoupName();
//        final SyncUpTarget target = (SyncUpTarget) sync.getTarget();
//        final SyncOptions options = sync.getOptions();

        let totalSize = dirtyRecordIds.count
        let maxBatchSize = (sync.target as! AdvancedSyncUpTarget).maxBatchSize
        var batch = Array<Dictionary<AnyHashable, Any>>()
        
        onUpdate(sync, 0)
        let dirtyRecords = sync.target.getFromLocalStore(syncManager,
                                                         soupName: sync.soupName,
                                                         storeIds: dirtyRecordIds)
        
        // Figuring out what records need to be synced up based on merge mode and last mod date on server
        let recordIdToShouldSyncUp = shouldSyncUpRecords(syncManager: syncManager,
                                                         target: sync.target,
                                                         records: dirtyRecords,
                                                         options:sync.options)
        
        let group = DispatchGroup()
        
        // Syncing up records
        for i in 0...totalSize {
//            checkIfStopRequested();
            let record = dirtyRecords[i]
            if let recordId = record[SmartStore.soupEntryId] as? String {

                if (recordIdToShouldSyncUp[recordId] == true) {
                    batch.append(record)
                }
               
                // Process batch if max batch size reached or at the end of dirtyRecordIds
                if (batch.count == maxBatchSize || i == totalSize - 1) {
                    group.enter()
                    (sync.target as! AdvancedSyncUpTarget).syncUpRecords(syncManager, records: batch, fieldlist: options.fieldlist, mergeMode: options.mergeMode, syncSoupName: sync.soupName) { <#[AnyHashable : Any]?#> in
                        
                    } fail: { <#Error#> in
                        <#code#>
                    }

                }
                
    //            if (batch.size() == maxBatchSize || i == totalSize - 1) {
    //                ((AdvancedSyncUpTarget) target).syncUpRecords(syncManager, batch, options.getFieldlist(), options.getMergeMode(), sync.getSoupName());
    //                batch.clear();
    //            }
    //
    //            // Updating status
    //            int progress = (i + 1) * 100 / totalSize;
    //            if (progress < 100) {
    //                updateSync(sync, SyncState.Status.RUNNING, progress, callback);
    //            }
            }
        }
    }
    
    @objc
    static func shouldSyncUpRecords(syncManager:SyncManager,
                                    target:SyncTarget,
                                    records:Array<Dictionary<AnyHashable, Any>>,
                                    options:SyncOptions
    ) -> Dictionary<String, Bool> {
        
        var recordIdToShouldSyncUp = Dictionary<String, Bool>()
        
        if (options.mergeMode == .overwrite) {
            for record in records {
                if let recordId = record[SmartStore.soupEntryId] as? String {
                    recordIdToShouldSyncUp[recordId] = true
                }
            }
        } else {
//            recordIdToShouldSyncUp = target.areNewerThanServer(syncManager, records);
        }
        return recordIdToShouldSyncUp
    }
}
