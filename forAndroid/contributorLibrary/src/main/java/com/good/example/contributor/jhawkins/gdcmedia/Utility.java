/* Copyright (c) 2015 Good Technology Corporation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package com.good.example.contributor.jhawkins.gdcmedia;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.media.AudioRecord;
import android.media.AudioTrack;

public class Utility {

    public interface Logger {
        public abstract void logMessage(String message);
    }

    public static Boolean permissionsOK(Activity activity, Logger logger)
    {
        Context context = activity;

        PackageManager packageManager = context.getPackageManager();
        String packageName = context.getPackageName();
        Boolean hasAll = true;

        if (packageManager.checkPermission(
                android.Manifest.permission.RECORD_AUDIO, packageName) !=
                PackageManager.PERMISSION_GRANTED)
        {
            logger.logMessage("No permission:RECORD_AUDIO.\n" );
            hasAll = false;
        }

        if (packageManager.checkPermission(
                android.Manifest.permission.MODIFY_AUDIO_SETTINGS, packageName) !=
                PackageManager.PERMISSION_GRANTED)
        {
            logger.logMessage("No permission:MODIFY_AUDIO_SETTINGS.\n" );
            hasAll = false;
        }

        return hasAll;
    }

    public static String errorForAudioRecord(String preamble, int returnedValue)
    {
        if (returnedValue >= 0) return null;

        StringBuilder ret = new StringBuilder(preamble);
        ret.append(" failed ");
        switch (returnedValue) {
            case AudioRecord.ERROR_BAD_VALUE:
                ret.append("because of bad value");
                break;

            case AudioRecord.ERROR_INVALID_OPERATION:
                ret.append("because of invalid operation");
                break;

            case AudioRecord.ERROR:
                ret.append("generally");
                break;

            default:
                ret.append("for unknown reason");
                break;
        }

        ret.append(" (");
        ret.append( Integer.toString(returnedValue) );
        ret.append(").");
        return ret.toString();
    }


    public static String errorForAudioTrack(String preamble, int returnedValue)
    {
        if (returnedValue >= 0) return null;

        StringBuilder ret = new StringBuilder(preamble);
        ret.append(" failed ");
        switch (returnedValue) {
            case AudioTrack.ERROR_BAD_VALUE:
                ret.append("because of bad value");
                break;

            case AudioTrack.ERROR_INVALID_OPERATION:
                ret.append("because of invalid operation");
                break;

            case AudioTrack.ERROR:
                ret.append("generally");
                break;

            default:
                ret.append("for unknown reason");
                break;
        }

        ret.append(" (");
        ret.append( Integer.toString(returnedValue) );
        ret.append(").");
        return ret.toString();
    }

}
