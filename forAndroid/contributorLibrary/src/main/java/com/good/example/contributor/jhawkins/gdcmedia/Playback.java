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

/* With thanks to:
 * http://androidsourcecode.blogspot.co.uk/2013/07/android-audio-demo-audiotrack.html
 */

package com.good.example.contributor.jhawkins.gdcmedia;

import android.app.Activity;
import android.content.Context;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioRecord;
import android.media.AudioTrack;
import android.media.MediaRecorder;

import com.good.gd.file.FileInputStream;

import java.io.FileNotFoundException;
import java.io.IOException;

public class Playback {
    private State state = State.STOPPED;

    public Utility.Logger logger = null;

    private String path = null;
    private Activity activity = null;
    private int minBufferSize = 0;

    private AudioTrack audioTrack = null;
    private FileInputStream fileInputStream = null;

    public Playback() {
        this.logger = new Utility.Logger() {
            @Override
            public void logMessage(String message) {
                return;
            }
        };
    }

    private Boolean reopen()
    {
        Boolean ret = true;

        try {
            fileInputStream.close();
        } catch (IOException exception) {
            logger.logMessage(this.getClass().getSimpleName() +
                    " reopen() failed to close \"" + path + "\". " + exception);
            ret = false;
        }

        if (ret) {
            try {
                fileInputStream = new FileInputStream(path);
            } catch (FileNotFoundException exception) {
                logger.logMessage(this.getClass().getSimpleName() +
                        " reopen() failed to open \"" + path + "\". " + exception);
                fileInputStream = null;
                ret = false;
            }
        }

        return ret;
    }

    private void streamPlayback()
    {
        byte[] bytes = new byte[minBufferSize];
        int num = 0;

//        AudioManager audioManager = (AudioManager) activity.getSystemService(
//                Context.AUDIO_SERVICE);
//        audioManager.setMode(AudioManager);
        audioTrack.play();

        while (state == State.STARTED) {
            int readResult;
            Boolean endOfStream = false;
            try {
                readResult = fileInputStream.read(bytes);
                if (readResult == -1) {
                    endOfStream = true;
                }
            }
            catch (IOException exception) {
                this.logger.logMessage(this.getClass().getSimpleName() +
                        " failed to read from \"" + path + "\". " + exception);
                readResult = -1;
            }

            if (readResult < 0) {
                if (endOfStream) {
                    if (!reopen()) { state = State.STOPPING; }
                }
                else {
                    state = State.STOPPING;
                }
            }
            else {
                audioTrack.write(bytes, 0, readResult);
            }
        }

        if (state != State.STOPPED) {
            state = State.STOPPED;
            audioTrack.flush();
            audioTrack.stop();
        }

        if (fileInputStream != null) {
            try {
                fileInputStream.close();
            } catch (IOException exception) {
                this.logger.logMessage(this.getClass().getSimpleName() +
                        " failed to close \"" + path + "\". " + exception);
            }
        }
    }

    public void stop()
    {
        if (state == State.STOPPED) return;
        state = State.STOPPING;
    }

    public String startOrError(final String path, final Activity activity)
    {
        this.activity = activity;

        final int kSampleRate = 44100;
        final int kChannel = AudioFormat.CHANNEL_OUT_MONO;
        final int kEncoding = AudioFormat.ENCODING_PCM_16BIT;

        // Following logs a message is any permissions seem to be missing.
        Utility.permissionsOK(activity, logger);

        String errorMessage = null;

        activity.setVolumeControlStream(AudioManager.MODE_IN_COMMUNICATION);

        minBufferSize = AudioTrack.getMinBufferSize( kSampleRate, kChannel, kEncoding );
        errorMessage = Utility.errorForAudioTrack("getMinBufferSize", minBufferSize);
        if (errorMessage == null) {
            audioTrack = new AudioTrack(
                    AudioManager.STREAM_VOICE_CALL,
                    kSampleRate,
                    kChannel,
                    kEncoding,
                    minBufferSize,
                    AudioTrack.MODE_STREAM);

            if (audioTrack.getState() == AudioRecord.STATE_UNINITIALIZED) {
                errorMessage = "Failed to initialise, releasing.";
                audioTrack.release();
            }
            else {
                logger.logMessage(this.getClass().getSimpleName() +
                        " audioTrack state:" + audioTrack.getState() +
                        " recording:" + audioTrack.getPlayState() +
                        "\n");
                errorMessage = null;
            }
        }

        if (errorMessage == null) {
            try {
                fileInputStream = new FileInputStream(path);
            } catch (FileNotFoundException exception) {
                errorMessage = "FileInputStream(" + path + ") failed. " + exception;
                fileInputStream = null;
            }
        }

        if (errorMessage != null) {
            return errorMessage;
        }
        state = State.STARTED;
        this.path = path;

        (new Thread() {
            @Override
            public void run() { streamPlayback(); }
        }).start();

        return null;
    }

}
