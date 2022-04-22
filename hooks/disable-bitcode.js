#!/usr/bin/env node

/*
* Disable bitcode for the following issue.
* https://github.com/DragonCherry/AssetsPickerViewController/issues/111
*/

var fs = require('fs');
var xcode = require('xcode');
var path = require('path');

function disableBitcode(pbxPath) {
    if (!fs.existsSync(pbxPath)) {
        return;
    }
    const xcodeProj = xcode.project(pbxPath);
    //We need to use parseSync because async causes problems when other plugins
    //are handling pbxproj file.
    xcodeProj.parseSync();
    xcodeProj.updateBuildProperty('ENABLE_BITCODE', 'NO');
    fs.writeFileSync(pbxPath, xcodeProj.writeSync());
}

function doHandle(context) {
    const projectRoot = context.opts.projectRoot;
    disableBitcode(path.join(projectRoot, 'platforms', 'ios', 'Pods/Pods.xcodeproj/project.pbxproj'));
};

module.exports = doHandle;