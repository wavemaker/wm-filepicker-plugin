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
import android.database.Cursor;
import android.net.Uri;
import android.provider.OpenableColumns;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

public class FileUtils {

    /** TAG for log messages. */
    static final String TAG = "FileUtils";

    /**
     * Get the value of the data column for this Uri. This is useful for
     * MediaStore Uris, and other file-based ContentProviders.
     *
     * @param context The context.
     * @param uri The Uri to query.
     * @return The value of the _data column, which is typically a file path.
     * @author paulburke
     */
    private static String getDataColumn(Context context, Uri uri) {

        Cursor cursor = null;
        final String column = "_data";
        final String[] projection = {
                column
        };

        try {
            cursor = context.getContentResolver().query(uri, projection, null, null,
                    null);
            if (cursor != null && cursor.moveToFirst()) {
                final int column_index = cursor.getColumnIndexOrThrow(column);
                return cursor.getString(column_index);
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }
        return null;
    }

    /**
     * Get a file path from a Uri. This will get the the path for Storage Access
     * Framework Documents, as well as the _data field for the MediaStore and
     * other file-based ContentProviders.<br>
     * <br>
     * Callers should check whether the path is local before assuming it
     * represents a local file.
     *
     * @param context The context.
     * @param uri The Uri to query.
     * @author paulburke
     */
    public static String getPath(final Context context, final Uri uri) {
        String path = null;
        if ("content".equalsIgnoreCase(uri.getScheme())) {
            path = getDataColumn(context, uri);
        }
        if (path == null && "file".equalsIgnoreCase(uri.getScheme())) {
            path = uri.getPath();
        }
        if (path == null) {
            File file = createFile(context, uri);
            if (file != null) {
                path = file.getAbsolutePath();
            }
        }
        return path == null || path.startsWith("file://") ? path: "file://" + path;
    }

    private static String getName(Context context, Uri uri) {
        Cursor cursor = context.getContentResolver().query(uri, null, null, null, null, null);
        String displayName = null;
        if (cursor != null && cursor.moveToFirst()) {
            displayName = cursor.getString(cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME));
        }
        if(cursor != null) {
            cursor.close();
        }
        return displayName != null ? displayName : uri.getLastPathSegment();
    }

    private static File createFile(Context context, Uri uri) {
        try {
            String name = getName(context, uri);
            File file = new File(context.getExternalCacheDir(), name);
            if (file.exists()) {
                int ext = name.lastIndexOf('.');
                String prefix = name, suffix = "";
                if(ext > 0) {
                    prefix = name.substring(0, ext);
                    suffix = name.substring(ext);
                }
                name = prefix + "_" + System.currentTimeMillis() + suffix;
                file = new File(context.getExternalCacheDir(), name);
            }
            InputStream inputStream = context.getContentResolver().openInputStream(uri);
            try (FileOutputStream outputStream = new FileOutputStream(file)) {
                int read;
                byte[] bytes = new byte[1024];
                while ((read = inputStream.read(bytes)) != -1) {
                    outputStream.write(bytes, 0, read);
                }
                outputStream.flush();
            }
            return file;
        } catch (Exception e) {
            Log.e(TAG, "Exception occured", e);
        }
        return  null;
    }
}
