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
import android.media.MediaRecorder;

import com.good.gd.file.File;
import com.good.gd.file.FileOutputStream;

import java.io.FileNotFoundException;
import java.io.IOException;

public class Recording {
    private State state = State.STOPPED;

    public Utility.Logger logger = null;

    private File path = null;
    private Activity activity = null;
    private int minBufferSize = 0;

    private AudioRecord audioRecord = null;
    private FileOutputStream fileOutputStream = null;

    public Recording() {
        this.logger = new Utility.Logger() {
            @Override
            public void logMessage(String message) {
                return;
            }
        };
    }

    private void streamRecording()
    {
        byte[] bytes = new byte[minBufferSize];
        int num = 0;

        AudioManager audioManager = (AudioManager) activity.getSystemService(
                Context.AUDIO_SERVICE);
        audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
        audioRecord.startRecording();

        while (state == State.STARTED) {
            num = audioRecord.read(bytes, 0, minBufferSize);
            try {
                fileOutputStream.write(bytes, 0, num);
            }
            catch (IOException ioException) {
                this.logger.logMessage(this.getClass().getSimpleName() +
                        " failed to write to \"" + path + "\". " + ioException.toString());
                state = State.STOPPING;
            }
        }
        state = State.STOPPED;
        audioRecord.stop();
        audioRecord.release();
        audioRecord = null;

        try {
            fileOutputStream.close();
        } catch (IOException ioException) {
            this.logger.logMessage(this.getClass().getSimpleName() +
                    " failed to close \"" + path + "\". " + ioException.toString());
        }
    }

    public void stop()
    {
        if (state == State.STOPPED) return;
        state = State.STOPPING;
    }

    public String startOrError(final File path, final Activity activity)
    {
        if (audioRecord != null) return "Already recording.";

        this.activity = activity;

        final int kSampleRate = 44100;
        final int kChannel = AudioFormat.CHANNEL_IN_MONO;
        final int kEncoding = AudioFormat.ENCODING_PCM_16BIT;

        // Following logs a message is any permissions seem to be missing.
        Utility.permissionsOK(activity, logger);

        String errorMessage = null;

//        activity.setVolumeControlStream(AudioManager.MODE_IN_COMMUNICATION);

        minBufferSize = AudioRecord.getMinBufferSize( kSampleRate, kChannel, kEncoding );
        errorMessage = Utility.errorForAudioRecord("getMinBufferSize", minBufferSize);
        if (errorMessage == null) {
            int[] audioSources = {
                    MediaRecorder.AudioSource.CAMCORDER,
                    MediaRecorder.AudioSource.MIC,
                    MediaRecorder.AudioSource.VOICE_COMMUNICATION
            };
            for (int audioSource : audioSources){
                audioRecord = new AudioRecord(
                        audioSource,
                        kSampleRate,
                        kChannel,
                        kEncoding,
                        minBufferSize);

                if (audioRecord.getState() == AudioRecord.STATE_UNINITIALIZED) {
                    errorMessage = "Failed to initialise, releasing.";
                    audioRecord.release();
                }
                else {
                    logger.logMessage(this.getClass().getSimpleName() +
                            " audioRecord state:" + audioRecord.getState() +
                            " recording:" + audioRecord.getRecordingState() +
                            " audioSource:" + audioRecord.getAudioSource() +
                            "\n");
                    errorMessage = null;
                    break;
                }
            }
        }

        if (errorMessage == null) {
            try {
                fileOutputStream = new FileOutputStream(path);
            } catch (FileNotFoundException e) {
                errorMessage = "FileOutputStream(" + path + ") failed. " + e;
                fileOutputStream = null;
            }
        }

        if (errorMessage != null) {
            return errorMessage;
        }
        state = State.STARTED;
        this.path = path;

        (new Thread() {
            @Override
            public void run() { streamRecording(); }
        }).start();

        return null;
    }
}

