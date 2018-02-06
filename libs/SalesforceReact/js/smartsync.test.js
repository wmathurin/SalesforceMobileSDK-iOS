/*
 * Copyright (c) 2018-present, salesforce.com, inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided
 * that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the
 * following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and
 * the following disclaimer in the documentation and/or other materials provided with the distribution.
 *
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to endorse or
 * promote products derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

import { assert } from 'chai';
import { registerTest, testDone } from './react.force.test';
import { promiser }  from './react.force.util';
import { net, smartstore, smartsync } from 'react-native-force';

// Promised based bridge functions for more readable tests
netCreate = promiser(net.create);
netRetrieve = promiser(net.retrieve);
netUpdate = promiser(net.update);
netDel = promiser(net.del);
netQuery = promiser(net.query);

registerSoup = promiser(smartstore.registerSoup);
upsertSoupEntries = promiser(smartstore.upsertSoupEntries);
retrieveSoupEntries = promiser(smartstore.retrieveSoupEntries);
runSmartQuery = promiser(smartstore.runSmartQuery);

getSyncStatus = promiser(smartsync.getSyncStatus);
deleteSync = promiser(smartsync.deleteSync);
syncDown = promiser(smartsync.syncDown);
syncUp = promiser(smartsync.syncUp);
cleanResyncGhosts = promiser(smartsync.cleanResyncGhosts);


const storeConfig = {isGlobalStore:false};
const soupName = 'contacts';
const indexSpecs = [{ 'path': 'Id', 'type': 'string'}, { 'path': 'FirstName', 'type': 'string'}, { 'path': 'LastName', 'type': 'string'}, { 'path': '__local__', 'type': 'string'}];

testSyncUp = () => {
    const uniq = Math.floor(Math.random() * 1000000);
    const firstName = 'First' + uniq;    
    var contactSmartStoreId;
    var contactId;


    // Create a record locally in db - do a sync up - read from db to get server id - check on server - delete from server (cleanup)

    registerSoup(storeConfig, soupName, indexSpecs)
        .then((result) => {
            return upsertSoupEntries(storeConfig, soupName,
                                     [{Id: 'local_1', FirstName: firstName, LastName: 'Last' + uniq, __local__: true, __locally_created__: true, attributes: {type: 'contact'}}]);
        })
        .then((result) => {
            contactSmartStoreId = result[0]._soupEntryId;
            return syncUp(storeConfig,
                          {'createFieldlist':['FirstName', 'LastName']},
                          soupName,
                          {'fieldlist':['Id', 'FirstName', 'LastName'], 'mergeMode':'LEAVE_IF_CHANGED'}
                         );
        })
        .then((result) => {
            assert.equal(result.totalSize, 1, 'Total size should be 1');
            assert.equal(result.status, 'DONE', 'Status should be done');
            return retrieveSoupEntries(storeConfig, soupName, [contactSmartStoreId]);
        })
        .then((result) => {
            assert.equal(result[0].__local__, false, 'Local record should be clean');
            assert.equal(result[0].__locally_created__, false, 'Local record should be clean');
            contactId = result[0].Id;
            return netQuery("SELECT FirstName FROM Contact WHERE Id IN ('" + contactId + "')");
        })
        .then((result) => {
            assert.equal(result.records[0].FirstName, firstName);

            // Cleanup
            return netDel('contact', contactId);
        })
        .then((result) => {
            testDone();
        });
};

testSyncDown = () => {
    const uniq = Math.floor(Math.random() * 1000000);
    const firstName = 'First' + uniq;
    var contactId;

    // Create a record remotely - do a sync down - check in db - delete from server (cleanup)

    registerSoup(storeConfig, soupName, indexSpecs)
        .then((result) => {
            return netCreate('contact', {FirstName: firstName, LastName: 'Last' + uniq});
        })
        .then((result) => {
            contactId = result.id;
            return syncDown(storeConfig,
                            {'type':'soql', 'query':"SELECT Id, FirstName, LastName FROM Contact WHERE Id IN ('" + contactId + "')"},
                            soupName,
                            {'mergeMode':'OVERWRITE'}
                           );
        })
        .then((result) => {
            assert.equal(result.totalSize, 1, 'Total size should be 1');
            assert.equal(result.status, 'DONE', 'Status should be done');
            return runSmartQuery(storeConfig, {queryType:'smart', smartSql:'select {' + soupName + ':FirstName} from {' + soupName + '} where {' + soupName + ':Id} = "' + contactId + '"', pageSize:32});
        })
        .then((result) => {
            assert.deepEqual([[firstName]], result.currentPageOrderedEntries);

            // Cleanup
            return netDel('contact', contactId);
        })
        .then((result) => {
            testDone();
        });
};

registerTest(testSyncUp);
registerTest(testSyncDown);
