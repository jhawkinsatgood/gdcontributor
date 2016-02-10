/* Copyright (c) 2016 Good Technology Corporation
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

package com.good.example.contributor.jhawkins.gdccommunication;

import com.good.gd.apache.http.entity.ContentProducer;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class FileContentProducer implements ContentProducer {
    private InputStream inputStream = null;
    private long result = 0;

    private ProgressListener progressListener = null;

    /*
     * Lifted from the Apache HttpClient sample application code in the GD SDK for Android.
     *
     * This class reads from the source stream into the HTTP entity's out stream.
     * This is required when we need to feed file content into POST or PUT entities.
     * Also, this class updates progress listener with how many bytes have been transfered. Updates happened at steps, specified
     * in the progressStep parameter.
     */
    public FileContentProducer(InputStream inputStream,
                               final ProgressListener progressListener
    ) {
        super();
        this.inputStream = inputStream;
        this.progressListener = progressListener;
    }

    public void writeTo(OutputStream outputStream) throws IOException
    {
        InputStream inputBuffer = null;
        OutputStream outputBuffer = null;
        long count = 0;

        inputBuffer = new BufferedInputStream(this.inputStream);
        outputBuffer = new BufferedOutputStream(outputStream);

        if (progressListener != null) progressListener.started();

        for(;;) {
            int data = inputBuffer.read();
            if (data == -1) {
                break;
            }
            count++;
            outputBuffer.write(data);
            if (
                    progressListener != null &&
                            progressListener.getProgressStep() > 0 &&
                            count % progressListener.getProgressStep() == 0

                    ) {
                progressListener.transferred(count);
            }
        }

        if (inputBuffer != null) {
            inputBuffer.close();
        }
        if (outputBuffer != null) {
            outputBuffer.close();
        }

        result = count;
    }

    public long getResult() {
        return result;
    }
}
