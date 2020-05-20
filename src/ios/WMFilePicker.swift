//
//  WMFilePicker.swift
//  FilePicker
//
//  Created by Srinivasa Rao Boyina on 5/4/20.
//  Copyright © 2020 Srinivasa Rao Boyina. All rights reserved.
//

import Foundation
import Photos
import UIKit
import MobileCoreServices
import AssetsPickerViewController

private let IMAGE = "IMAGE";
private let VIDEO = "VIDEO";
private let AUDIO = "AUDIO";
private let FILE = "FILE";

public class WMFilePickerConfig {
    public var useCamera = false;
    public var useLibrary = true;
    public var useCloud = true;
}


public class WMFilePicker: NSObject,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    UIDocumentPickerDelegate,
    AssetsPickerViewControllerDelegate {
    
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
        if (type == IMAGE || type == VIDEO || type == AUDIO) {
            if (self.config.useCamera
                && (type == IMAGE || type == VIDEO)
                && UIImagePickerController.isSourceTypeAvailable(.camera)) {
                let title = type == IMAGE ? "Take Picture" : "Capture Video";
                handler = {(a) in
                    self.capture(vc: vc, type: type);
                };
                alert.addAction(UIAlertAction(title: title, style: .default, handler: handler));
            }
            if (self.config.useLibrary) {
                handler = {(a) in
                    self.showLibraryUI(view: vc, type: type, multiple: multiple);
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
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
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
    }
    
    private func showLibraryUI(view: UIViewController, type: String, multiple: Bool) {
        let picker = AssetsPickerViewController();
        picker.pickerDelegate = self;
        let options = PHFetchOptions();
        options.includeHiddenAssets = true;
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: true),
            NSSortDescriptor(key: "modificationDate", ascending: true)
        ];
        if (type == IMAGE) {
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue);
        } else if (type == VIDEO) {
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue);
        } else if (type == AUDIO) {
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.audio.rawValue);
        } else {
            options.predicate = NSPredicate(format: "1 == 1", true);
        }
        picker.pickerConfig.assetFetchOptions = [
            .smartAlbum: options,
            .album: options
        ];
        picker.pickerConfig.assetsMaximumSelectionCount = multiple ? Int.max : 1;
        view.present(picker, animated: true, completion: nil)
    }
    
    //MARK: UIImagePickerControllerDelegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        if mediaType ==  kUTTypeMovie {
            let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as! URL
            self.completionHandler?([videoURL])
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
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.completionHandler?([url]);
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
      self.completionHandler?([URL]())
    }
    
    
    //MARK: AssetsPickerViewControllerDelegate
    
    public func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        getURLs(assets);
    }
    
    private func getURLs(_ assets: [PHAsset], i: Int = 0, urls: [URL] = []) {
        var _urls = [URL](urls);
        if( i >= assets.count) {
            self.completionHandler?(urls);
            return;
        }
        self.getURL(asset: assets[i], completionHandler: { (url: URL?) in
            _urls.append(url!);
            self.getURLs(assets, i: i + 1, urls: _urls);
        });
    }
    
    private func getURL(asset: PHAsset, completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if asset.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            asset.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if asset.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        } else if asset.mediaType == .audio {
            let options: PHVideoRequestOptions = PHVideoRequestOptions();
            options.version = .original;
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}
