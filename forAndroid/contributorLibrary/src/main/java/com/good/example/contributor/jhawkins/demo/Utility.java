/* Copyright (c) 2014 Good Technology Corporation
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

package com.good.example.contributor.jhawkins.demo;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.text.DateFormat;
import java.util.Date;
import java.util.Locale;

import com.good.gd.file.FileInputStream;
import com.good.gd.file.FileOutputStream;

public class Utility {
    
    private static String basicContent = "Demonstration file created by " + 
            Utility.class.getSimpleName() + ".";

    public static String simpleDate()
    {
        return DateFormat.getDateTimeInstance().format(new Date());
    }
    
    public static String createFileOrError(String filename, String content)
    {
        // To force failure, uncomment the next line
//        filename = "/NO DIRECTORY/" + filename;
        String message = null;
        FileOutputStream fileOutputStream = null;
        try {
            fileOutputStream = new FileOutputStream(filename);
        } catch (FileNotFoundException e) {
            message = "FileOutputStream(" + filename + ") failed. " + e;
            fileOutputStream = null;
        }
        if (filename != null && content == null) {
            if (filename.endsWith(".txt")) {
                content = basicContent + "\n" + simpleDate();
            }
            else if (filename.endsWith(".html") || filename.endsWith(".htm")) {
                content = "<html><head></head><body><p>" + 
                        basicContent + "</p><p>"+ simpleDate() +
                        "</p></body></html>";
            }
            else {
                int extension = filename.lastIndexOf('.');
                message = "Could not deduce content from " +
                        (extension < 0 ? "filename" : "extension") + " \"" + 
                        (extension < 0 ?
                                filename :
                                filename.substring(extension)) +
                        "\"";
            }
        }
        if (fileOutputStream != null && content != null) {
            try {
                fileOutputStream.write(content.getBytes());
                fileOutputStream.close();
            } catch (IOException e) {
                message = "Failed to write to file \"" + filename + "\". " + e;
            }
        }
        return message;
    }

    public static String createFilesOrError(String ... filenames)
    {
        StringBuilder ret = new StringBuilder();
        Boolean allOK = true;
        for(String filename: filenames) {
            String error = createFileOrError(filename, null);
            if (error != null) {
                ret.append(error + "\n");
                allOK = false;
            }
        }
        if (allOK) return null;
        return ret.toString();
    }

    public static String byteDump(String filepath)
    {
        StringBuilder str = new StringBuilder("");
        int bytes_read = 0;
        try {
            FileInputStream receivedStream = new FileInputStream(filepath);
            int readi;
            while ( (readi = receivedStream.read()) >= 0  && bytes_read < 80 ) {
                if (readi >= (int)' ' && readi <= (int)'~') {
                    str.append((char)readi);
                }
                else {
                    str.append("\\x").append(
                            String.format((Locale)null, "%02X", readi));
                }
                bytes_read++;
            }
            receivedStream.close();
        } catch (FileNotFoundException e) {
            return "File not found \"" + filepath + "\". " + e + "\n";
        } catch (IOException e) {
            return "Could not read \"" + filepath + "\". " + e + "\n";
        }
        return "Read " + bytes_read + " bytes OK \"" + str.toString() + "\".";
    }
    
}
