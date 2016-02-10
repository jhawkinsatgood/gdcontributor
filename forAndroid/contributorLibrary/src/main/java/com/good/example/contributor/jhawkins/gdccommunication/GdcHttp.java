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

import com.good.gd.file.File;
import com.good.gd.file.FileInputStream;
import com.good.gd.net.GDHttpClient;

import com.good.gd.apache.http.HttpEntity;
import com.good.gd.apache.http.HttpResponse;
import com.good.gd.apache.http.client.methods.HttpPost;
import com.good.gd.apache.http.entity.EntityTemplate;

import java.io.IOException;
import java.net.URLConnection;

public class GdcHttp {

    public static void addContentType(HttpPost post, File path)
    {
        // Try guessing.
        String contentType = URLConnection.guessContentTypeFromName(path.toURI().toString());

        // pcm raw audio doesn't have a proper MIME type. Put a special value that is
        // recognised by the server.
        if (contentType == null) {
            if (path.toString().endsWith(".pcm")) {
                contentType = "audio/pcm";
            }
        }
        if (contentType != null) {
            post.addHeader("Content-type", contentType);
        }
    }

    public static String upload(String serverURL,
                                File path,
                                ProgressListener progressListener)
            throws IOException
    {
        HttpPost post = new HttpPost(serverURL);
        addContentType(post, path);

        FileInputStream fileInputStream = new FileInputStream(path);

        FileContentProducer producer = new FileContentProducer(
                fileInputStream, progressListener);

        HttpEntity entity = new EntityTemplate(producer);

        post.setEntity(entity);

        GDHttpClient client = new GDHttpClient();

        HttpResponse response = client.execute(post);

        String statusLine = response.getStatusLine().toString();

        client.getConnectionManager().shutdown();

        return statusLine;
    }

}
