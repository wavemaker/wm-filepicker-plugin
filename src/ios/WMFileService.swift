//
//  SamplePlugin.swift
//  WaveLens
//
//  Created by Srinivasa Rao Boyina on 5/6/20.
//

import Foundation;

@objc(WMFileService)
public class WMFileService: CDVPlugin {
    
    @objc
    public func selectFiles(_ command: CDVInvokedUrlCommand) {
        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "GOT it");
        let options = command.argument(at: 0) as! [String: NSObject];
        let type = options["type"] as? String ?? "IMAGE";
        let multiple = options["multiple"] as? Bool ?? false;
        WMFilePicker.sharedInstance.present(vc: viewController, type: type, multiple: multiple, onCompletion:{ (urls: [URL]) in
            urls.forEach { url in
                NSLog("selected file (" + url.absoluteString + ")");
            }
        });
        self.commandDelegate.send(result, callbackId: command.callbackId);
    }
}
