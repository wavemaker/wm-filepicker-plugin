/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
*/

var exec = require('cordova/exec');

///channel.createSticky('onCordovaInfoReady');
// Tell cordova channel to wait on the CordovaInfoReady event
//channel.waitForInitialization('onCordovaInfoReady');

/**
 * This represents the mobile device, and provides properties for inspecting the model, version, UUID of the
 * phone, etc.
 * @constructor
 */
function FilePicker () {

}

/**
 * Get device info
 *
 * @param {Function} successCallback The function to call when the heading data is available
 * @param {Function} errorCallback The function to call when there is an error getting the heading data. (OPTIONAL)
 */
FilePicker.prototype.select = function (options, successCallback, errorCallback) {
    var DEFAULT_OPTIONS = {
        'multiple': false,
        "type": "FILE"
    };
    options = options || {};
    for (key in DEFAULT_OPTIONS) {
        if (options[key] === undefined) {
            options[key] = DEFAULT_OPTIONS[key];
        }
    }
    exec(successCallback, errorCallback, 'FilePicker', 'selectFiles', [options]);
};

FilePicker.prototype.selectImage = function(multiple, successCallback, errorCallback, onLibraryChoosen) {
    var options = {
        "multiple": multiple,
        "type": "IMAGE",
        "useCustomLibrary": !!onLibraryChoosen
    };
    this.select(options, function(paths) {
        if (paths.length > 0 && paths[0] === 'use-custom-library') {
            onLibraryChoosen();
        } else {
            successCallback(paths);
        }
    }, errorCallback);
};

FilePicker.prototype.selectVideo = function(multiple, successCallback, errorCallback, onLibraryChoosen) {
    var options = {
        "multiple": multiple,
        "type": "VIDEO",
        "useCustomLibrary": !!onLibraryChoosen
    };
    this.select(options, function(paths) {
        if (paths.length > 0 && paths[0] === 'use-custom-library') {
            onLibraryChoosen();
        } else {
            successCallback(paths);
        }
    }, errorCallback);
};


FilePicker.prototype.selectAudio = function(multiple, successCallback, errorCallback) {
    var options = {
        "multiple": multiple,
        "type": "AUDIO"
    };
    this.select(options, successCallback, errorCallback);
};

FilePicker.prototype.selectFiles = function(multiple, successCallback, errorCallback) {
    var options = {
        "multiple": multiple,
        "type": "FILE"
    };
    this.select(options, successCallback, errorCallback);
};

module.exports = new FilePicker();
