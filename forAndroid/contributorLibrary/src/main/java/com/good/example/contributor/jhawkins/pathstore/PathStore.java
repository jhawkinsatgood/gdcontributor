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

package com.good.example.contributor.jhawkins.pathstore;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class PathStore {
    private JSONObject obj = null;
    private JSONArray arr = null;
    
    public PathStore(JSONObject myObj) {
        obj = myObj;
        arr = null;
    }

    public PathStore(JSONArray myArr) {
        obj = null;
        arr = myArr;
    }

    public Object toICCObject()
    {
        if (obj != null) {
            Map<String,Object> ret = new HashMap<String,Object>();
            Iterator<String> iterator = obj.keys();
            while( iterator.hasNext() ) {
                String key = iterator.next();
                Object obji = obj.opt(key);
                if (obji != null) {
                    if (obji.getClass() == PathStore.class) {
                        ret.put(key, ((PathStore)obji).toICCObject());
                    }
                    else {
                        ret.put(key, obji);
                    }
                }
            }
            return ret;
        }
        else if (arr != null) {
            ArrayList<Object> ret = new ArrayList<Object>();
            for( int i=0; i<arr.length(); i++ ) {
                Object obji = opt(i);
                if (obji != null) {
                    if (obji.getClass() == PathStore.class) {
                        ret.add( ((PathStore)obji).toICCObject() );
                    }
                    else {
                        ret.add(obji);
                    }
                }
            }
            return ret;
        }
        else {
            return null;
        }
    }
    
    public Object toJSON() {
        if (obj != null) {
            JSONObject ret = new JSONObject();
            Iterator<String> iterator = obj.keys();
            while( iterator.hasNext() ) {
                String key = iterator.next();
                Object obji;
                try {
                    obji = obj.get(key);
                    if (obji.getClass() == PathStore.class) {
                        ret.put(key, ((PathStore)obji).toJSON());
                    }
                    else {
                        ret.put(key, obji);
                    }
                } catch (JSONException e) {
                    throw new Error(
                            "Failure in PathStore.toJSON() obj:" +
                            obj.toString() + ". " + e.toString());
                }
            }
            return ret;
        }
        else if (arr != null) {
            JSONArray ret = new JSONArray();
            for( int i=0; i<arr.length(); i++ ) {
                try {
                    Object obji = arr.get(i);
                    if (obji.getClass() == PathStore.class) {
                        ret.put(i, ((PathStore)obji).toJSON());
                    }
                    else {
                        ret.put(i, obji);
                    }
                } catch (JSONException e) {
                    throw new Error(
                            "Failure in PathStore.toJSON()arr:" +
                            arr.toString() + ". " + e.toString());
                }
            }
            return ret;
        }
        else {
            return null;
        }
    }

    public String toString() {
        if (obj != null) {
            return ((JSONObject)toJSON()).toString();
        }
        else if (arr != null) {
            return ((JSONArray)toJSON()).toString();
        }
        else {
            return null;
        }
    }
    
    public String toString(int indentSpaces) throws JSONException {
        if (obj != null) {
            return ((JSONObject)toJSON()).toString(indentSpaces);
        }
        else if (arr != null) {
            return ((JSONArray)toJSON()).toString(indentSpaces);
        }
        else {
            return null;
        }
    }
    
    public Boolean isArray() {
        return (arr != null);
    }
    public Boolean sameType(Object that) {
        if (that == null || that.getClass() != this.getClass()) {
            return false;
        }
        return (((PathStore)that).isArray() == isArray()); 
    }

    private PathStore put(Object o, Object value) throws JSONException {
        if (o.getClass() == String.class) {
            arr = null;
            if (obj == null) obj = new JSONObject();
            obj.put((String)o, value);
        }
        else if (o.getClass() == Integer.class) {
            obj = null;
            if (arr == null) arr = new JSONArray();
            arr.put((Integer)o, value);
        }
        return this;
    }

    public int length() {
        if (arr == null) {
            return 0;
        }
        else {
            return arr.length();
        }
    }

//    private Object get(Object o) throws JSONException {
//        if (o.getClass() == String.class) {
//            return obj.get((String)o);
//        }
//        else if (o.getClass() == Integer.class) {
//            return arr.get((Integer)o);
//        }
//        return null;
//    }

    private Boolean has(Object o) {
        if (obj != null && o.getClass() == String.class) {
            return obj.has((String)o);
        }
        else if (arr != null && o.getClass() == Integer.class) {
            int index = (Integer)o;
            return index >= 0 && index < arr.length();
        }
        else {
            return false;
        }
    }

    private Object opt(Object o) {
        if (obj != null && o.getClass() == String.class) {
            return obj.opt((String)o);
        }
        else if (arr != null && o.getClass() == Integer.class) {
            try {
                return arr.get((Integer)o);
            } catch (JSONException e) {
                return null;
            }
        }
        else {
            return null;
        }
    }

    public Object pathGet(Object... paths)
    {
        PathStore get_point = this;
        Object ret = null;
        for(int i=0; get_point != null; i++) {
            /* Check if the end of the path has been reached.
             * If it has, get now and return.
             */
            if (i+1 >= paths.length) {
                ret = get_point.opt(paths[i]);
                break;
            }

            /* If we get here, then we will be going around the loop again
             * and descending.
             *
             * First check if the thing into which we are descending is
             * missing. If it is, stop descending.
             */
            if ( !get_point.has(paths[i]) ) break;
            Object next = get_point.opt(paths[i]);

            /* Construct a blank thing to check the next thing is of the 
             * expected type.
             */
            PathStore checker = null;
            if (paths[i+1].getClass() == Integer.class) {
                checker = new PathStore(new JSONArray());
            }
            else {
                checker = new PathStore(new JSONObject());
            }

            /* Check the next thing is of the expected type.
             * If it isn't, stop descending.
             */
            if ( !checker.sameType(next) ) break;
            
            /* Descend.
             */
            get_point = (PathStore)next;
        }

        return ret;
    }
    
    public String pathGetString(Object... paths)
    {
        Object value = pathGet(paths);
        if (value != null && value.getClass() == String.class) {
            return (String)value;
        }
        else {
            return null;
        }
    }
    
    public Integer pathGetInteger(Object... paths)
    {
        Object value = pathGet(paths);
        if (value != null && value.getClass() == Integer.class) {
            return (Integer)value;
        }
        else {
            return null;
        }
    }
    
    public String[] pathGetStringArray(Object... paths)
    {
        Object value = pathGet(paths);
        if (value == null) return null;
        if (value.getClass() == String.class) {
            String[] ret = new String[1];
            ret[0] = (String)value;
            return ret;
        }
        if (value.getClass() != PathStore.class) return null;

        PathStore value_path = (PathStore)value;
        if (!value_path.isArray()) return null;
        
        int value_length = value_path.length();
        if (value_length <= 0) return null;

        Boolean allNull = true;
        String[] ret = new String[value_length];
        for(int stringi=0; stringi<value_length; stringi++) {
            String istring = value_path.pathGetString(stringi);
            allNull = allNull && (istring == null);
            ret[stringi] = istring;
        }
        if (allNull) return null;
        return ret;
    }
    
    private String descent(Object[] paths)
    {
        return descent(paths.length - 1, paths);
    }

    private String descent(int fail_index, Object[] paths)
    {
        if (fail_index < 1) return " the top";
        StringBuilder descent = new StringBuilder("");
        for ( int j=0; j < fail_index; j++ ) {
            descent.append(" \"" + paths[j].toString() + "\"");
        }
        return descent.toString();
    }
    
//    public PathStore pathSet(Object value, Object[]... arrays)
//    {
//        int path_length = 0;
//        for(Object[] array: arrays) {
//            if (array != null) path_length += array.length;
//        }
//        Object[] path = new Object[path_length];
//        if (path_length > 0) {
//            int i=0;
//            for(Object[] array: arrays) {
//                if (array != null) for(Object path_element: array) {
//                    path[i++] = path_element;
//                }
//            }
//        }
//        return pathSet(value, path);
//    }

    public PathStore pathSet(Object value, Object... paths)
    {
        if (paths.length < 1) {
            throw new Error("Cannot pathSet with empty paths.");
        }
        PathStore set_point = this;
        int i = 0;
        for(;;) {
            Object pathi = paths[i];
            /* If we are in an array, then the path will be a numeric index.
             * In that case, check if it is negative. A negative index means
             * append to the end of the array.
             */
            if (pathi.getClass() == Integer.class) {
                if ( (Integer)pathi < 0 ) {
                    pathi = set_point.length();
                    // pathi will be 0 if set_point is not an array.
                }
            }

            /* Check if the end of the path has been reached.
             * If it has, set now and return.
             */
            if (i+1 >= paths.length) {
                try {
                    set_point.put(pathi, value);
                } catch (JSONException e) {
                    throw new Error(
                            "Failed to put value \"" + value.toString() +
                            "\" in PathStore.set at" + descent(paths) + "." + 
                            e.toString());
                }
                break;
            }

            /* If we get here, then we will be going around the loop again
             * and descending.
             *
             * First check if the thing into which we are descending is
             * missing. If it isn't missing, get a reference to it.
             */
            Boolean absent = !set_point.has(pathi);
            Object checker = null;
            if (!absent) {
                checker = set_point.opt(pathi);
            }

            /* Construct a candidate blank thing in case it is needed.
             * Creating the object here avoids a nested if later.
             */
            PathStore next = null;
            if (paths[i+1].getClass() == Integer.class) {
                next = new PathStore(new JSONArray());
            }
            else {
                next = new PathStore(new JSONObject());
            }

            /* Put the candidate blank thing in place, if necessary.
             * It is necessary if there is no thing into which to descend,
             * or if the current thing is of the wrong type.
             */
            if ( absent || !next.sameType(checker) ) {
                try {
                    set_point.put(pathi, next);
                } catch (JSONException e) {
                    throw new Error(
                            "Failed to put next \"" + next.toString() + 
                            "\" in PathStore.set at" + descent(i, paths) + 
                            ". " + e.toString() );
                }
            }
            
            /* Descend and advance the index
             */
            set_point = (PathStore) set_point.opt(pathi);
            i++;
        }

        return this;
    }
    
    private Object[] append(Object[] array, Object element)
    {
        Object[] ret = new Object[array.length + 1];
        for( int pathi = 0; pathi < array.length; pathi++ ) {
            ret[pathi] = array[pathi];
        }
        ret[array.length] = element;
        return ret;
    }
    
    public PathStore pathSetAppend(Object value, Object... paths)
    {
        Object[] set_path = append(paths, -1);
        return pathSet(value, set_path);
    }

    public PathStore pathSetAppend(Object[] values, Object... paths)
    {
        Object[] set_path = append(paths, -1);
        for(Object value: values) {
            pathSet(value, set_path);
        }
        return this;
    }

    public static Object createFromICC(Object from)
    {
        // Eliminate the simplest case
        if (from == null) return from;

        String from_type = from.getClass().toString();
        if (from_type.endsWith("Map")) {
            PathStore ret = new PathStore(new JSONObject());
            Map<String,Object> from_map = (Map<String, Object>) from;
            Iterator<String> iterator = from_map.keySet().iterator();
            while(iterator.hasNext()) {
                String key = iterator.next();
                ret.pathSet( createFromICC( from_map.get(key) ), key);
            }
            return ret;
        }
        else if (from_type.endsWith(".ArrayList")) {
            PathStore ret = new PathStore(new JSONArray());
            ArrayList<Object> from_list = (ArrayList<Object>) from;
            for(int i=0; i < from_list.size(); i++ ) {
                ret.pathSet( createFromICC( from_list.get(i) ), i);
            }
            return ret;
        }
        else {
            return from;
        }
    }

}
