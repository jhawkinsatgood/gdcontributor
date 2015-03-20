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

/* This package is different to the others. It creates the _package function
 * that is used by all the other packages to insert themselves into the
 * namespace. It has to create the function in such a way that it can call it
 * to insert itself.
 * Another difference is that this file inserts a single function, not a package
 * as such.
 *
 * This is also where we insert the isArray attribute into the Array prototype.
 */

/* This is a trick from the Internet. It might originate from Doug Crockford. */
Array.prototype.isArray = true;

// Declare module but don't set it. This allows the code to check whether
// module has already been set, by the Cordova plugin loader.
var module;

(function(global){
    var parentName = "com.good.example.contributor.jhawkins";
    
    /** If this is being run in the context of a Cordova plugin, then module will
     * be set. In that case, packages are added to the module.exports attribute.
     * Otherwise they goes under the com.dom.ain namespace.
     */
    function _package(
        name_string /* string */, innerModule, setPackage /*function*/
    ) {
        var top = global;
        var names = ["exports"];
        if (innerModule) {
            top = innerModule;
        }
        else {
            names = name_string.split(".");
        }
        for ( var i=0; i<names.length; i++ ) {
            if (!( names[i] in top )) {  top[names[i]] = {}; }
            top = top[names[i]];
        }
        return setPackage(top);
    }

    // The following line would add the above function to the global object,
    // which would allow it to be called like _package without the domain
    // prefix. I'm not sure that's a good idea so it's commented out.
    //global._package = _package;
    //
    // The following lines would make it possible to call _package as a method on
    // any function, even an anonymous function. Something like:
    //     (function(a1, a2) { return a1+a2; })._package("com.math", "add");
    // That doesn't seem super necessary though.
    //Function.prototype._package = function(packageName, functionName) {
    //    _package(packageName, function(namespace) {
    //        namespace[functionName] = this;
    //    })
    //}

    _package(parentName, module, function(namespace){
        namespace._package = _package;
    });
})(this);
