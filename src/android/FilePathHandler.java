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
package com.wavemaker.cordova.plugin;

import android.content.Context;
import android.util.Log;
import android.webkit.MimeTypeMap;
import android.webkit.WebResourceResponse;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.webkit.WebViewAssetLoader;

import java.io.FileInputStream;

public class FilePathHandler implements WebViewAssetLoader.PathHandler{

    private static final String ASSET_PREFIX = "_app_file_";
    private Context context;

    FilePathHandler(Context context) {
        this.context = context;
    }

    @Nullable
    @Override
    public WebResourceResponse handle(@NonNull String path) {
        if (path.startsWith(ASSET_PREFIX)) {
            try {
                String filePath = path.substring(path.indexOf(ASSET_PREFIX) + ASSET_PREFIX.length());
                String extension = MimeTypeMap.getFileExtensionFromUrl(path);
                FileInputStream is = new FileInputStream(filePath);
                String mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
                return new WebResourceResponse(mimeType, null, is);
            } catch (Exception e) {
                Log.e("FilePathHandler", "", e);
            }
        }
        return null;
    }
}
