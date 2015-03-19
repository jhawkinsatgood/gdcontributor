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

package com.good.example.contributor.jhawkins.appkineticsworkflow;

import android.os.Bundle;
import android.webkit.WebView;
import android.app.Activity;
import android.graphics.Color;

import com.good.gd.GDAndroid;

import com.good.example.contributor.jhawkins.demo.DemoConsumeOpenHTTPURL;
import com.good.example.contributor.jhawkins.demo.DemoConsumeSendEmail;
import com.good.example.contributor.jhawkins.demo.DemoConsumeTransferFile;
import com.good.example.contributor.jhawkins.demo.DemoProvideTransferFile;
import com.good.example.contributor.jhawkins.demo.MainPageForGoodDynamics;

/** Entry point activity which will start authorization with Good Dynamics
 * and once done launch the application UI.
 */
public class MainActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);
        WebView webView = (WebView) findViewById(R.id.webView);

        MainPageForGoodDynamics mainPageForGD = MainPageForGoodDynamics.getInstance();

        if (!mainPageForGD.isSetUp()) {
            // Set up the UI, but don't load any demos yet, because GD demos won't load
            // before authorization is complete.
            mainPageForGD.getMainPage().setBackgroundColour("DarkSeaGreen")
                    .setTitle( getResources().getString(R.string.app_name) )
                    .addDemoClasses(
                            DemoConsumeSendEmail.class,
                            DemoConsumeTransferFile.class,
                            DemoConsumeOpenHTTPURL.class,
                            DemoProvideTransferFile.class);
        }

        // The next line will attach a GD authorization listener that:
        // -   Sets the WebView and Activity properties of MainPage.
        // -   Causes the demos to be loaded, if they haven't loaded already.
        // -   Sets the information line to display some GD-specific values.
        // Those things only happen when the application authorizes.
        mainPageForGD.setUp(webView, this);

        GDAndroid.getInstance().configureUI(
                getResources().getDrawable(R.drawable.workflowlogo_xcf),
                getResources().getDrawable(R.drawable.workflowlogo_xcf),
                Color.BLACK );

        GDAndroid.getInstance().activityInit(this);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // If this Activity instance gets destroyed, clear the references to it
        // so that they don't get held from garbage collection.
        MainPageForGoodDynamics.getInstance().clear();
    }
}
