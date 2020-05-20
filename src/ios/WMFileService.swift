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
        let options = command.argument(at: 0) as! [String: NSObject];
        let type = options["type"] as? String ?? "IMAGE";
        let multiple = options["multiple"] as? Bool ?? false;
        WMFilePicker.sharedInstance.config.useCamera = options["useCamera"] as? Bool ?? false;
        WMFilePicker.sharedInstance.config.useLibrary = options["useLibrary"] as? Bool ?? true;
        WMFilePicker.sharedInstance.config.useCloud = options["useICloud"] as? Bool ?? true;
        WMFilePicker.sharedInstance.present(vc: viewController, type: type, multiple: multiple, onCompletion:{ (urls: [URL]) in
            let paths = urls.map { url in url.absoluteString };
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: paths);
            self.commandDelegate.send(result, callbackId: command.callbackId);
        });
    }
}
