/*
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
 */

import Foundation
import Photos
import UIKit
import MobileCoreServices
import MediaPlayer
import AVFoundation
import PhotosUI


private let IMAGE = "IMAGE";
private let VIDEO = "VIDEO";
private let AUDIO = "AUDIO";
private let FILE = "FILE";

public class WMFilePickerConfig {
    public var useCamera = false;
    public var useLibrary = true;
    public var useCustomLibrary = false;
    public var useCloud = true;
}


public class WMFilePicker: NSObject,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    UIDocumentPickerDelegate,
    MPMediaPickerControllerDelegate,
    PHPickerViewControllerDelegate {
    
    public static let sharedInstance = WMFilePicker();
    
    public let config = WMFilePickerConfig()
    
    private var presentingViewController: UIViewController?;
    
    private var completionHandler: (([URL]) -> Void)?
    
    private override init() {
        
    }
    
    public func present(vc: UIViewController, type: String, multiple: Bool = false, onCompletion: @escaping (_ urls: [URL]) -> Void) {

        self.completionHandler = onCompletion;
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);
        var handler = {(a:UIAlertAction?) in };
        if (type == AUDIO) {
            handler = {(a) in
                self.showMediaLibrary(vc: vc, multiple: multiple);
            };
            alert.addAction(UIAlertAction(title: "Pick From Library", style: .default, handler: handler));
        } else if (type == IMAGE || type == VIDEO) {
            if (self.config.useCamera
                && UIImagePickerController.isSourceTypeAvailable(.camera)) {
                let title = type == IMAGE ? "Take Picture" : "Capture Video";
                handler = {(a) in
                    self.capture(vc: vc, type: type);
                };
                alert.addAction(UIAlertAction(title: title, style: .default, handler: handler));
            }
            
            if (self.config.useLibrary) {
                handler = {(a) in
                    if (self.config.useCustomLibrary) {
                        self.completionHandler?([URL(string: "use-custom-library")!]);
                        self.presentingViewController?.dismiss(animated: true, completion: nil);
                    } else {
                        self.showLibraryUI(view: vc, type: type, multiple: multiple);
                    }
                };
                alert.addAction(UIAlertAction(title: "Pick From Library", style: .default, handler: handler));
            }
        }
        if (self.config.useCloud) {
            handler = {(a) in
                self.showCloudUI(vc: vc, type: type, multiple: multiple);
            };
            alert.addAction(UIAlertAction(title: "Pick From Cloud", style: .default, handler: handler));
        }
        if (alert.actions.count == 1) {
            handler(nil);
        } else {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (a) in self.completionHandler?([URL]());
            }));
            vc.present(alert, animated: true, completion: nil);
        }
    }
    
    private func capture(vc: UIViewController, type: String) {
        let cameraPicker = UIImagePickerController()
        cameraPicker.sourceType = .camera;
        cameraPicker.showsCameraControls = true;
        cameraPicker.delegate = self;
        if(type == VIDEO) {
            cameraPicker.mediaTypes = [String(kUTTypeMovie)];
        } else {
            cameraPicker.mediaTypes = [String(kUTTypeImage)]
        }
        vc.present(cameraPicker, animated: true, completion: nil);
        self.presentingViewController = cameraPicker;
    }
    
    private func showMediaLibrary(vc: UIViewController, multiple: Bool) {
        let mediaPicker = MPMediaPickerController(mediaTypes: .music);
        mediaPicker.allowsPickingMultipleItems = multiple;
        mediaPicker.delegate = self;
        mediaPicker.showsCloudItems = false;
        vc.present(mediaPicker, animated: true, completion: nil);
        self.presentingViewController = mediaPicker;
    }
    
    private func showCloudUI(vc: UIViewController, type: String, multiple: Bool) {
        var types = [String(kUTTypeData)];
        if(type == IMAGE) {
            types = [String(kUTTypeImage)]
        } else if(type == VIDEO) {
            types = [String(kUTTypeVideo)]
        } else if(type == AUDIO) {
            types = [String(kUTTypeAudio)]
        }
        let picker = UIDocumentPickerViewController(documentTypes: types, in: .import);
        if #available(iOS 11.0, *) {
            picker.allowsMultipleSelection = multiple
        }
        picker.delegate = self;
        vc.present(picker, animated: true, completion: nil);
        self.presentingViewController = picker;
    }
    
    private func showLibraryUI(view: UIViewController, type: String, multiple: Bool) {
        var config = PHPickerConfiguration();
        if #available(iOS 14.0, *) {
            config.selectionLimit = multiple ? Int.max : 1;
        }
        if (type == IMAGE) {
            config.filter = .any(of: [.livePhotos, .images]);
        } else if (type == VIDEO) {
            config.filter = .videos
        } else {
            config.filter = .any(of: [.livePhotos, .videos, .images])
        }
        let picker = PHPickerViewController(configuration: config);
        picker.delegate = self;
        view.present(picker, animated: true, completion: nil);
        self.presentingViewController = picker;
    }
    
    //MARK: PHPickerViewControllerDelegate
     public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
         self.presentingViewController?.dismiss(animated: true, completion: nil);
         var urls = [URL]();
         let itemProviders = results.map(\.itemProvider)
             for item in itemProviders {
                 if item.canLoadObject(ofClass: UIImage.self) {
                     item.loadObject(ofClass: UIImage.self) { (image, error) in
                         DispatchQueue.main.async {
                             let url = (self.getImageUrl(image: image as! UIImage ))!;
                             urls.append(url);
                         }
                     }
                 }
             }
     }
    
    //MARK: MPMediaPickerControllerDelegate
    public func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        let noOfFilesSelected = mediaItemCollection.count;
        var noOfFilesProcessed = 0;
        var urls = [URL]();
        mediaItemCollection.items.forEach({
            mediaItem in
            let audioURL = mediaItem.value(forKeyPath: MPMediaItemPropertyAssetURL) as! URL;
            let exporter = AVAssetExportSession(asset: AVURLAsset(url: audioURL, options: nil), presetName: AVAssetExportPresetAppleM4A);
            exporter?.outputFileType = .m4a;
            let dFileManager = FileManager.default;
            let filename = String.localizedStringWithFormat("%@.m4a", mediaItem.title ?? UUID().uuidString).removingPercentEncoding;
            let cachePath = dFileManager.urls(for: .cachesDirectory, in: .userDomainMask);
            let exportUrl = cachePath[0].appendingPathComponent(filename!);
            if (dFileManager.fileExists(atPath: exportUrl.path)) {
                do {
                  try dFileManager.removeItem(atPath: exportUrl.path);
                } catch let error {
                    print("Error: \(error)");
                }
            }
            exporter?.outputURL = exportUrl;
            exporter?.exportAsynchronously(completionHandler: {
                print("exporting status of \(filename!) is \(exporter!.status.rawValue)");
                noOfFilesProcessed += 1;
                if(exporter?.status == AVAssetExportSession.Status.completed) {
                    urls.append(exportUrl);
                } else if(exporter?.status == AVAssetExportSession.Status.failed) {
                    print("\(exporter!.error.debugDescription)")
                }
                if(noOfFilesSelected == noOfFilesProcessed) {
                    self.completionHandler?(urls);
                }
            });
        });
        self.presentingViewController?.dismiss(animated: true, completion: nil);
    }
    
    
    public func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.completionHandler?([URL]());
        self.presentingViewController?.dismiss(animated: true, completion: nil);
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        if mediaType ==  "public.movie" {
            let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as! URL;
            let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask);
            let destUrl = URL(string: cachePath[0].absoluteString + videoURL.lastPathComponent);
            do {
                try FileManager.default.copyItem(at: videoURL, to: destUrl!);
            } catch let error {
                print("Error: \(error)");
            }
            self.completionHandler?([destUrl!])
        } else {
            let originalImage: UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            var imageUrl: URL? = nil
            if let data = originalImage.pngData() {
                let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask);
                imageUrl = URL(string: paths[0].absoluteString + UUID.init().uuidString + ".png")
                try? data.write(to: imageUrl!)
            }
            self.completionHandler?([imageUrl!]);
        }
        self.presentingViewController?.dismiss(animated: true, completion: nil);
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.completionHandler?([URL]());
        self.presentingViewController?.dismiss(animated: true, completion: nil);
    }
    
    // MARK: UIDocumentPickerDelegate
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.completionHandler?(urls);
        self.presentingViewController?.dismiss(animated: true, completion: nil);
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.completionHandler?([URL]());
        self.presentingViewController?.dismiss(animated: true, completion: nil);
    }
    
    // MARK: Helper functions
                                     
    public func getImageUrl(image: UIImage) -> URL? {
        var imageUrl: URL? = nil
        if let data = image.pngData() {
            let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask);
            imageUrl = URL(string: paths[0].absoluteString + UUID.init().uuidString + ".png")
            try? data.write(to: imageUrl!)
        }
        return imageUrl;
    }
}

@objc(WMFilePickerPlugin)
public class WMFilePickerPlugin: CDVPlugin {
    
    @objc
    public func selectFiles(_ command: CDVInvokedUrlCommand) {
        let options = command.argument(at: 0) as! [String: NSObject];
        let type = options["type"] as? String ?? "IMAGE";
        let multiple = options["multiple"] as? Bool ?? false;
        WMFilePicker.sharedInstance.config.useCamera = options["useCamera"] as? Bool ?? false;
        WMFilePicker.sharedInstance.config.useLibrary = options["useLibrary"] as? Bool ?? true;
        WMFilePicker.sharedInstance.config.useCustomLibrary = options["useCustomLibrary"] as? Bool ?? false;
        WMFilePicker.sharedInstance.config.useCloud = options["useICloud"] as? Bool ?? true;
        WMFilePicker.sharedInstance.present(vc: viewController, type: type, multiple: multiple, onCompletion:{ (urls: [URL]) in
            let paths = urls.map { url in url.absoluteString };
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: paths);
            self.commandDelegate.send(result, callbackId: command.callbackId);
        });
    }
}
