
# wm-cordova-plugin-filepicker

Cordova plugin that exposes API to select images, videos, audio and files. This plugin supports both Android and iOS. In iOS, this plugin doesn't support selecting multiple files.

## ANDROID
IMAGE|VIDEO|AUDIO|FILE
-----|-----|-----|----
<img src="assets/android/image_sel_preview.png" width="200px">|<img src="assets/android/video_sel_preview.png" width="200px">|<img src="assets/android/audio_sel_preview.png" width="200px">|<img src="assets/android/file_sel_preview.png" width="200px">

## IOS
IMAGE|VIDEO|AUDIO|FILE
-----|-----|-----|----
<img src="assets/ios/image_sel_preview.jpg" width="200px">|<img src="assets/ios/video_sel_preview.jpg" width="200px">|<img src="assets/ios/audio_sel_preview.jpg" width="200px">|<img src="assets/ios/file_sel_preview.jpg" width="200px">

In config.xml, under ios platform add the following. Descriptions can be altered.
```
<preference name="SwiftVersion" value="4.2"/>
```
```
<edit-config target="NSAppleMusicUsageDescription" mode="merge" file="*-Info.plist">
	<string>need music library access to upload audio files</string>
</edit-config>
```
```
<edit-config target="NSPhotoLibraryAddUsageDescription" file="*-Info.plist" mode="merge">
    <string>need photo library access to save pictures there</string>
</edit-config>
```
```
<edit-config target="NSPhotoLibraryUsageDescription" file="*-Info.plist" mode="merge">
    <string>need photo library access to get pictures from there</string>
</edit-config>
```

## API

    cordova.wavemaker.filePicker.selectAudio(
	    true, //to select multiple audio files
	    function(selectedFilePaths) {
	      // code to use the selected audio file paths
	    }, function(error) {
	      // handle error
	    });
    
    cordova.wavemaker.filePicker.selectFiles(
	    true, // to select multiple files
	    function(selectedFilePaths) {
	      // code to use the selected file paths
	    }, function(error) {
	      // handle error
	    });

    cordova.wavemaker.filePicker.selectImage(
	    true, // to select multiple images
	    function(selectedFilePaths) {
	      // code to use the selected image file paths
	    }, function(error) {
	      // handle error
	    });
    
    cordova.wavemaker.filePicker.selectVideo(
	    true, // whether to select multiple Videos
	    function(selectedFilePaths) {
	      // code to use the selected file paths
	    }, function(error) {
	      // handle error
	    });

## License
Apache License - 2.0