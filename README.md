
# wm-filepicker-plugin

Cordova plugin that exposes API to select images, videos, audio and files. This plugin supports both Android and iOS. In iOS, this plugin doesn't support selecting multiple files.

## ANDROID
![image selector preview](assets/android/image_sel_preview.png)
![video selector preview](assets/android/video_sel_preview.png)
![audio selector preview](assets/android/audio_sel_preview.png)
![file selector preview](assets/android/file_sel_preview.png)

## IOS
![image selector preview](assets/ios/image_sel_preview.png)
![video selector preview](assets/ios/video_sel_preview.png)
![audio selector preview](assets/ios/audio_sel_preview.png)
![file selector preview](assets/ios/file_sel_preview.png)

In config.xml, under ios platform add the swift version.
```
<preference name="SwiftVersion" value="4.2"/>
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