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

var module;
com.good.example.contributor.jhawkins._package(
    "com.good.example.contributor.jhawkins.demo.mainpage", module,
function (namespace) {
    /* Constructor function */
    function MainPage() { (function(newMainPage) {
        /* Dependencies */
        var Demo = com.good.example.contributor.jhawkins.demo;
        var Utility = Demo.utility;
        var demoPrefix = "demo";
        var title = "Main Page";
        var information = null;
        var results = null;
        var webView = null;

        function isDemo(classname) {
            return (classname.slice(0,demoPrefix.length) == demoPrefix);
        }
        
        function setTitle(myTitle) {
            this.title = myTitle;
            return this;
        }

        function setInformation(myInformation) {
            this.information = myInformation;
            return this;
        }
        
        function setWebView(myNode_specifier) {
            if (typeof myNode_specifier == "string") {
                this.webView = document.getElementById(myNode_specifier);
                if (this.webView == null) {
                    throw new Error(
                        'MainPage.setWebView(): No node with ID "' +
                        myNode_specifier + '"');
                }
            }
            else {
                this.webView = myNode_specifier;
            }
            return this;
        }

        function demoLog(/* ... */) {
            if (arguments.length == 1 && arguments[0] == null) {
                this.results = null;
            }
            else {
                if (this.results == null) {
                    this.results = "";
                }
                for (var i=0; i < arguments.length; i++) {
                    message = arguments[i];
                    if (typeof message == "object" && message) {
                        this.results += Utility.toJSON(message, null);
                    }
                    else {
                        this.results += message;
                    }
                    this.results += "\n";
                }
            }
            this.load();
        }
        
        function mkCommand(label, parent, onclick) {
            var cmd_node = Utility.appendNode("span", label, parent);
            cmd_node.setAttribute('class', 'command');
            cmd_node.addEventListener( "click", onclick );
            return cmd_node;
        }
        
        function mkHolder(parent) {
            var holder = Utility.appendNode("div", null, parent);
            holder.setAttribute('class', 'holder');
            return holder;
        }
    
        function load() {
            if (this.webView == null) {
                return this;
            }

            Utility.removeChilds(this.webView);

            Utility.appendNode('h1', this.title, this.webView);
            if (this.information != null) {
                Utility.appendNode('div', this.information, this.webView
                ).setAttribute('class', 'information');
            }

            if (this.results != null) {
                /* Create a structure to hold the results display:
                 * At the top is a holder, which contains:
                 *     A <pre> that shows the results.
                 *     A <div> that contains:
                 *       A control that clears the results when clicked.
                 */
                var holder = mkHolder(this.webView);
                Utility.appendNode("pre", this.results, holder);
                mkCommand("< Clear", Utility.appendNode("div", null, holder),
                    (function(this_ref) { return function() {
                        this_ref.demoLog(null);
                    }})(this));
            }

            for (var demoName in Demo) {
                if (!isDemo(demoName)) { continue; }
                mkCommand(
                    Demo[demoName].demoLabel() + " >", mkHolder(this.webView),
                    (function(this_ref, demo) { return function() {
                        demo.demoExecute(function(/*...*/) {
                            this_ref.demoLog.apply(this_ref, arguments);
                        });
                    }})(this, Demo[demoName]));
            }
        
            return this;
        }
        
        /* Public methods of new object */
        newMainPage.setTitle = setTitle;
        newMainPage.setInformation = setInformation;
        newMainPage.demoLog = demoLog;
        newMainPage.setWebView = setWebView;
        newMainPage.load = load;
        
    })(this); } /* End of MainPage the constructor */

    /* Public methods */
    namespace.MainPage = MainPage;

    return namespace;
});