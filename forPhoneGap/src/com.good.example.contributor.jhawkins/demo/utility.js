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

/* Utility functions
 */
var module;
com.good.example.contributor.jhawkins._package(
    "com.good.example.contributor.jhawkins.demo.utility", module,
function (namespace) {
   
    function removeChilds(parent) {
        while(parent.hasChildNodes()) {
            parent.removeChild(parent.lastChild);
        }
        return parent;
    }

    function createNode(tag, text) {
        var elem = document.createElement(tag);
        if ( text != null ) {
            var etxt = document.createTextNode(text);
            elem.appendChild(etxt);
        }
        return elem;
    }

    function appendNode(tag, text, parent) {
        return parent.appendChild( createNode(tag, text) );
    }

    function insertNode(tag, text, parent) {
        return parent.insertBefore( createNode(tag, text), parent.firstChild );
    }

    function documentTitle() {    
        var head = document.documentElement.getElementsByTagName("head")[0];
        if (!head) { return null; }
        var title = head.getElementsByTagName("title")[0];
        if (!title) {
            return null;
        }
        return title.text;
    }


    function attrDump(obj, parent){
        var acnt = 0;
        for (var attr in obj) {
            acnt++;
            var attrval;
            var maxlen = 256;
            if (obj[attr].length > maxlen) {
                attrval = obj[attr].slice(0, maxlen) + '...';
            }
            else {
                attrval = obj[attr]; 
            }
            appendNode(
                'p', '' + acnt + ' ' + attr + ': "' + attrval + '"', parent
            );
        }
        return appendNode('p', 'Attribute count: ' + acnt, parent);
    }

    function sortedProperties(properties, orderer) {
        var ret = [];
        for( var property in properties ) {
            ret.push(property);
        }
        return ret.sort(function(a,b) {
            return (0 + properties[a][orderer]) - properties[b][orderer];
        });
    }

    /* toJSON - Create a JSON string from a service definition object.
     * This is a fairly trivial recursive process. The only tricky part is
     * sorting according to a specified ordering attribute, when present.
     * At face value, it looks like it should be possible to achieve this by
     * using JSON.stringify with a replacement function as a parameter. However,
     * this seems not to work with recursion: strings returned seem to get
     * stringified again by JSON.stringify. The solution is to do the recursive
     * descent in our own function, and only call JSON.stringify at the leaf
     * level, i.e. for simple types.
     *
     * There are two functions:
     * toJSON1 is the recursive engine.
     * toJSON is the public method.
     */
    function toJSON1(obj, orderer, prefix) {
        if ( (typeof obj != 'object') || obj == null ) {
            return JSON.stringify(obj);
        }
        if (obj.isArray) {
            var prefix1 = prefix + '    ';
            var ret = '[';
            var sep = '\n';
            for( var i=0; i < obj.length; i++ ) {
                ret += sep + prefix1 + toJSON1(obj[i], orderer, prefix1);
                sep = ',\n';
            }
            ret += '\n' + prefix + ']';
        }
        else {
            var prefix1 = prefix + '    ';
            var ret = '{';
            var sep = '\n';
            var ordered = (orderer == null ? false : true);
            var properties = [];
            for( var property in obj ) {
                ordered =
                    ordered &&
                    (typeof obj[property] == 'object') &&
                    (obj[property] != null) &&
                    (orderer in obj[property]);
                properties.push(property);
            }
            if (ordered) {
                properties = sortedProperties(obj, orderer);
            }
            for( var i=0; i< properties.length; i++ ) {
                var propi = properties[i];
                ret += sep + prefix1 + '"' + propi + '": ' +
                    toJSON1(obj[propi], orderer, prefix1);
                sep = ',\n';
            }
            ret += '\n' + prefix + '}';
        }
        return ret;
    }

    function toJSON(obj, orderer) {
        return toJSON1( obj, orderer, '' );
    }

    /* Static methods */
    namespace.removeChilds = removeChilds;
    namespace.appendNode = appendNode;
    namespace.insertNode = insertNode;
    namespace.documentTitle = documentTitle;
    namespace.attrDump = attrDump;
    namespace.sortedProperties = sortedProperties;
    namespace.toJSON = toJSON;

    return namespace;
});

