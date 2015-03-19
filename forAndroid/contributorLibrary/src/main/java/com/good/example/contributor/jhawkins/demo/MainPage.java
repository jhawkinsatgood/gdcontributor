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

import java.util.ArrayList;
import java.util.concurrent.Semaphore;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.text.TextUtils;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;

import com.good.example.contributor.jhawkins.demoframework.Component;
import com.good.example.contributor.jhawkins.demoframework.UserInterface;

public class MainPage implements UserInterface {
    // MainPage is a singleton class
    private static MainPage _instance = null;
    private MainPage() {}
    public static MainPage getInstance() {
        if (null == _instance) {
            _instance = new MainPage();
            _instance.pageHTMLSemaphore = new Semaphore(1);
        }
        return _instance;
    }

    // Properties
    private WebView webView = null;
    private Activity activity = null;
    private String backgroundColour = "LightYellow";
    private String title = "Main Page";
    private String information = null;
    private String results = null;
    private String editData = null;
    private String[] pickList = null;
    private int pickFor = -1;
    private Boolean hasLoaded = false;

    private Component save = null;
    
    private ArrayList<Component> demos = null;

    // HTML in the page, access to which is controlled by a semaphore.
    // These are private but still accessible to inner classes of this class.
    private String pageHTML = null;
    private Semaphore pageHTMLSemaphore = null;

    // Constant values
    private final String jsInterfaceName = "mainPage";

    public void demoLog( String newResults )
    {
        if (newResults == null) {
            results = null;
        }
        else {
            results = new StringBuilder(results == null ? "" : results)
            .append(newResults).toString();
        }
        reloadHTML();
    }
    
    public void demoEdit(String content, Component saver)
    {
        save = saver;
        this.showEditData(content);
    }
    
    public MainPage addDemoClasses(Class<?> ... components)
    {
        if (demos == null) demos = new ArrayList<Component>(components.length);
        for(Class<?> component : components) {
            Component componenti;
            try {
                componenti = (Component)component.newInstance();
                demos.add( componenti.setUserInterface(this) );
            } catch (InstantiationException e) {
                throw new Error("Failed to instantiate: " + e.getMessage());
            } catch (IllegalAccessException e) {
                throw new Error("Failed to access legally: " + e.getMessage());
            }
        }
        return this;
    }
    
    public MainPage setWebView(WebView webView)
    {
    	if (this.webView != webView) {
    		this.webView = webView;
    		reloadHTML();
    	}
        return this;
    }
    
    public MainPage setActivity(Activity activity)
    {
    	if (this.activity != activity) {
    		this.activity = activity;
    		reloadHTML();
    	}
    	return this;
    }
    
    public MainPage setBackgroundColour( String backgroundColour )
    {
        this.backgroundColour = backgroundColour;
        reloadHTML();
        return this;
    }
    
    public MainPage setTitle( String title )
    {
        this.title = title;
        reloadHTML();
        return this;
    }

    public String getInformation() {
    	return this.information;
    }
    public MainPage setInformation(String information) {
        this.information = information;
        reloadHTML();
        return this;
    }

    public MainPage load()
    {
        if (demos != null && !hasLoaded) for(Component demo: demos) {
        	demo.demoLoad();
        }
        hasLoaded = true;
        reloadHTML();
        return this;
    }
    
    public Boolean loaded()
    {
        return hasLoaded;
    }
    
    public MainPage showEditData( String editData )
    {
        this.editData = editData;
        reloadHTML();
        return this;
    }
    
    private String handleCommand( String command, String parameter )
    {
        if (command.equals("CLEAR")) {
            demoLog(null);
        }
        else if (command.equals("execute")) {
            int parameter_int = Integer.valueOf(parameter);
            Component demoi = demos.get(parameter_int);
            pickList = demoi.demoExecuteOrPickList();
            if (pickList == null) {
                // Demo returned nil to indicate no need for a pick.
                reloadHTML();
            }
            else if (pickList.length < 1) {
            	// Empty pick list.
            	pickList = null;
            	demoLog("No providers.");
            	// demoLog triggers reloadHTML.
            }
            else if (pickList.length == 1) {
            	// One item, pick it automatically.
            	pickList = null;
            	demoi.demoPickAndExecute(0);
            	reloadHTML();
            }
            else {
            	// Actual pick list.
            	pickFor = parameter_int;
            	demoLog("Providers: " + pickList.length);
            	// demoLog triggers reloadHTML.
            }
        }
        else if (command.equals("save")) {
            if (save == null) {
                demoLog("save command when save is null.\n");
            }
            else {
                if (save.demoSave(parameter)) {
                    // Save OK; delete from here.
                    showEditData(null);
                }
                else {
                    // Save failed; keep the content here
                    showEditData(parameter);
                }
            }
        }
        else if (command.equals("discard")) {
            if (save == null) {
                demoLog("discard command when save is null.\n");
            }
            else {
                save.demoSave(null);
                showEditData(null);
            }
        }
        else if (command.equals("pick")) {
            Component demoi = demos.get(pickFor);
            pickList = null;
            pickFor = -1;
            demoi.demoPickAndExecute(Integer.valueOf(parameter));
            reloadHTML();
        }
        else if (command.equals("switch")) {
            int parameter_int = Integer.valueOf(parameter);
            Component demoi = demos.get(parameter_int);
            demoi.demoSwitch();
            reloadHTML();
        }
        else {
            demoLog("handleCommand(" + command + ",");
            if (parameter == null) {
            	demoLog("null");
            }
            else {
            	demoLog( "\"" + parameter + "\"" );
            }
			demoLog( ")\n" );
        }
        return "handleCommand(" + command + ")";
    }
    
    // HandleCommand class enables the JS Interface to start a new thread in
    // which to process commands from the user interface.
    // This means that the JavaBridge thread terminates quicker.
    private class HandleCommand implements Runnable {
    	private String command = null;
    	private String parameter = null;
    	private MainPage mainPage = null;

    	public HandleCommand(
    			String command, String parameter, MainPage mainPage) {
    		this.command = command;
    		this.parameter = parameter;
    		this.mainPage = mainPage;
    	}
    	
    	@Override
    	public void run() { 
    		mainPage.handleCommand(this.command, this.parameter);
    	}
    }

    // JSObject class
    // This is embedded in the web page.
    class MainPageJSInterface {
        private MainPage mainPage = null;

        // Constructor
        public MainPageJSInterface(MainPage myPage) {
            mainPage = myPage;
        }

        // Interface method called from the JS layer.
        @JavascriptInterface
        public void command(String command, String parameter) {
        	// Spawn a thread to process the command.
        	new Thread(new HandleCommand(
        			command, parameter, this.mainPage)).start();
        }
    }
    
    static final String HTMLnlSources[] = {      "\r\n",   "\n"     };
    static final String HTMLnlDestinations[] = { "<br />", "<br />" };
    static String HTMLreplace(String str, Boolean newlines)
    {
        String ret = TextUtils.htmlEncode(str);
        // It seems that TextUtils.replace only replaces the first occurrence of
        // each string in the map. So we replace in a loop until nothing 
        // changes.
        if (newlines) for(;;) {
            String retnl = TextUtils.replace(ret, 
                    HTMLnlSources, HTMLnlDestinations).toString();
            if (retnl.equals(ret)) break;
            ret = retnl;
        }
        return ret;
    }

    private String _commandHTML( String command, String label, String value ) {
        return "<span class=\"command\" onclick=\"" + jsInterfaceName + 
                ".command('" + command + "'," + value +
                ");\">" + label + "</span>";
    }
    private String commandHTML( String command, String label, String value ) {
        return _commandHTML(
                command, label, 
                "document.getElementById('" + value + "').value" );
    }
    private String commandHTML( String command, String label, int value ) {
        return _commandHTML(command, label, "" + value);
    }
    private String commandHTML( String command, String label) {
        return _commandHTML(command, label, "null");
    }
    
    // Class for scheduling the WebView load on the UI thread.
    @SuppressLint("SetJavaScriptEnabled")
    private class RunReloadHTML implements Runnable {
    	MainPage mainPage = null;
    	
    	public RunReloadHTML(MainPage mainPage) {
    		this.mainPage = mainPage;
    	}

		@Override
		public void run() {
			try {
				this.mainPage.pageHTMLSemaphore.acquire();
			} catch (InterruptedException e) {
				// Somehow failed to lock the pageHTML for reading. The process 
				// is probably being killed so don't try to do anything.
				return;
			}
			// Enable JS, load the page, then insert the JS interface.
			this.mainPage.webView.getSettings().setJavaScriptEnabled(true);
			this.mainPage.webView.loadDataWithBaseURL(
					"mainpage.html", this.mainPage.pageHTML,
					"text/html", null, "mainpage.html");
			this.mainPage.webView.addJavascriptInterface(
					new MainPageJSInterface(this.mainPage), jsInterfaceName );
			this.mainPage.pageHTMLSemaphore.release();
		}
    }

    private void reloadHTML()
    {
        if (webView == null || activity == null || !hasLoaded) return;
        
        try {
			pageHTMLSemaphore.acquire();
		} catch (InterruptedException e) {
			// Somehow failed to lock the pageHTML for writing. The process is 
			// probably being killed so don't try to do anything.
			return;
		}
        
        StringBuilder newPageHTML = new StringBuilder( "<html><head>" +
                "<style>" +
                "  body {" +
                "    font-family: sans-serif; " +
                "    background-color: " + backgroundColour + ";" +
                "  }" +
                "  div {" +
                "      margin-top: 6pt;" +
                "      margin-bottom: 6pt;" +
                "      color: black;" +
                "  }" +
                "  .holder {" +
                "      margin-top: 12pt;" +
                "  }" +
                "  div.picker {" +
                "      margin-top: 12pt;" +
                "      border-top: solid 1pt black;" +
                "  }" +
                "  div.picker div {" +
                "      border-bottom: solid 1pt black;" +
                "      padding-bottom: 8pt;" +
                "  }" +
                "  h1 {margin-top: 20pt; font-size: 24pt;}" +
                "  .command {" +
                "      text-decoration: none;" +
                "      border: 1pt solid black;" +
                "      padding: 4pt;" +
                "      margin-right: 4pt;" +
                "  }" +
                "  .information {" +
                "      font-size: 8pt;" +
                "  }" +
                "  pre {" +
                "      border: 1pt dashed black;" +
                "      white-space: pre-wrap;" +
                "  }" +
                "</style>" +
                "<script type=\"text/javascript\" >" +
                "function createNode(tag, text) {" +
                "    var elem = document.createElement(tag);" +
                "    if ( text != null ) {" +
                "       var etxt = document.createTextNode(text);" +
                "       elem.appendChild(etxt);" +
                "    }" +
                "    return elem;" +
                "}" +
                "" +
                "function appendNode(tag, text, parent) {" +
                "   return parent.appendChild( createNode(tag, text) );" +
                "}" +
                "" +
                "function display(arg) {" +
                "    appendNode('div', 'display(' + JSON.stringify(arg) + ')', " + 
                "        document.getElementById('h1'));" +
                "}" +
                "" +
                "var " + jsInterfaceName + ";" +
                "</script>" +
                "</head><body>" +
                "<h1 id=\"h1\">" + title + "</h1>");
        if (information != null) {
            newPageHTML.append(
            		"<div class=\"information\">" + information + "</div>" );
        }
        if (results != null) {
            newPageHTML.append(
                    "<div class=\"holder\"><pre>" + 
                    HTMLreplace(results, true) + "</pre><div>" + 
                    commandHTML("CLEAR", "&lt; Clear") + "</div></div>");
        }
        
        if (pickList != null) {
            newPageHTML.append("<div class=\"picker\">"); 
            for(int i=0; i<pickList.length; i++) {
                newPageHTML.append("<div>" + pickList[i] + " ");
                newPageHTML.append(commandHTML( "pick", "Go &gt;", i));
                newPageHTML.append("</div>"); 
            }
            newPageHTML.append("</div>"); 
        }

        if (editData != null) {
            String ctrlname = "savearea";
            newPageHTML.append(
                    "\n<div class=\"holder\"><textarea name=\"" + 
                            ctrlname + "\" id=\"" + ctrlname + "\">" + 
                    HTMLreplace(editData, false) + "</textarea></div><div>" + 
                    commandHTML("discard", "&lt; Discard") +
                    commandHTML("save", "Save &gt;", ctrlname) + "</div>");
        }
        
        for (int i=0; i<demos.size(); i++) {
            Component demoi = demos.get(i);
            String executeLabel = demoi.getExecuteLabel();
            String switchLabel = demoi.demoGetSwitchLabel();
            if (pickFor != i && (executeLabel != null || switchLabel != null)) {
                newPageHTML.append("<div class=\"holder\">");
                if (executeLabel != null) {
                	newPageHTML.append(commandHTML(
                			"execute", executeLabel + " &gt;", i));
                }
                if (switchLabel != null) {
                	newPageHTML.append(commandHTML("switch", switchLabel, i));
                }
                newPageHTML.append("</div>");
            }
        }

        newPageHTML.append("</body></html>");

        pageHTML = newPageHTML.toString();

        // Have to release the pageHTML before scheduling the UI update.
        // It's possible for the UI thread to execute the update immediately,
        // which leads to a deadlock if the pageHTML is still acquired here.
        pageHTMLSemaphore.release();

        // Run the loadData on the UI thread. This will acquire and release the
        // pageHTML too.
        this.activity.runOnUiThread( new RunReloadHTML(this) );
    }
    
}
