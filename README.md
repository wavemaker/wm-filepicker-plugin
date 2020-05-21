
# wm-filepicker-plugin

Cordova plugin that exposes API to select images, videos, audio and files. This plugin supports both Android and iOS. In iOS, this plugin doesn't support selecting multiple files.


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