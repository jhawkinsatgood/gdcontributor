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

package com.good.example.contributor.jhawkins.demo;

import android.app.Activity;
import android.util.Log;
import android.webkit.WebView;

import com.good.example.contributor.jhawkins.gdruntime.RuntimeDispatcher;
import com.good.gd.GDAndroid;
import com.good.gd.GDAppEvent;
import com.good.gd.GDAppEventType;

public class MainPageForGoodDynamics {
	private static final String TAG = MainPageForGoodDynamics.class.getSimpleName();

	// This class is a static singleton.
	private static MainPageForGoodDynamics _instance = null;
	private MainPageForGoodDynamics() {
		super();
	}
	public static MainPageForGoodDynamics getInstance() {
		if (null == _instance) {
			_instance = new MainPageForGoodDynamics();
		}
		return _instance;
	}

	private Boolean setUpDone = false;
	private WebView webView = null;
	private Activity activity = null;
    private Boolean hasAuthorized = false;
	
	public Boolean isSetUp() { return setUpDone; }

    public MainPageForGoodDynamics setWebView(WebView webView) {
        this.webView  = webView;
        didAuthorize();
        return this;
    }

    public MainPageForGoodDynamics setActivity(Activity activity) {
        this.activity  = activity;
        didAuthorize();
        return this;
    }

    private void didAuthorize()
    {
        if (this.hasAuthorized &&
            this.webView != null &&
            this.activity != null
        ) {
            MainPage mainPage = MainPage.getInstance();
            if (mainPage.getInformation() == null) {
                mainPage.setInformation(
                        GDAndroid.getVersion() + " " +
                                GDAndroid.getInstance().getApplicationId() );
            }
            mainPage.setWebView(this.webView).setActivity(this.activity).load();
        }

        // If any of the conditions are not met, do nothing.
    }

	public void setUp()
	{
    	if (!setUpDone) {
    		RuntimeDispatcher.getInstance().addEventHandler(
    			GDAppEventType.GDAppEventAuthorized,
    			new RuntimeDispatcher.EventHandler() {
						
    				@Override
    				public void onReceiveMessage(GDAppEvent event) {
    					Log.i(TAG, "setUp onReceiveMessage()");
                        MainPageForGoodDynamics.this.hasAuthorized = true;
                        MainPageForGoodDynamics.this.didAuthorize();
    				}
    			});
    	}
		setUpDone = true;
	}
	
	public void clear()
	{
		this.activity = null;
		MainPage.getInstance().setActivity(null);
	}

	public MainPage getMainPage() {
		return MainPage.getInstance();
	}
}
