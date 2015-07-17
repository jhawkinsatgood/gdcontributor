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

package com.good.example.contributor.jhawkins.gdruntime;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.good.gd.GDAndroid;
import com.good.gd.GDAppEvent;
import com.good.gd.GDAppEventListener;
import com.good.gd.GDAppEventType;
import com.good.gd.GDAppServer;
import com.good.gd.GDStateListener;

public class RuntimeDispatcher implements GDStateListener, GDAppEventListener {
	// This class is a static singleton.
    private static RuntimeDispatcher _instance = null;
    private RuntimeDispatcher() {
        super();
    }
    public static RuntimeDispatcher getInstance() {
        if (null == _instance) {
            _instance = new RuntimeDispatcher();
        	GDAndroid.getInstance().setGDAppEventListener(_instance);
        	GDAndroid.getInstance().setGDStateListener(_instance);
        }
        return _instance;
    }

	// Interface for StateListener handlers that have no parameters.
	public interface VoidHandler {
		public void onReceiveMessage();
	}
	// Interface for StateListener handlers that have a map parameter.
	public interface MapHandler {
		public void onReceiveMessage(Map<String, Object> map);
	}
	// Interface for generic GDAppEventListener handlers.
	public interface EventHandler {
		public void onReceiveMessage(GDAppEvent event);
	}
	
	// Interface for application configuration handlers.
	public interface ConfigurationHandler {
		public void onReceiveMessage(Map<String, Object> map, String string);
	}

	// There will be an array of EventHandlers for each event type, and an 
	// array of handlers for each state type. Store these in arrays of arrays.
	private ArrayList<ArrayList<EventHandler>> eventHandlerLists = null;
	private ArrayList<ArrayList<VoidHandler>> voidStateHandlerLists = null;
	private ArrayList<ArrayList<MapHandler>> mapStateHandlerLists = null;

	// Enumeration for state handlers
	public enum State {
		AUTHORIZED(false), LOCKED(false), UPDATE_CONFIG(true), 
		UPDATE_POLICY(true), UPDATE_SERVICES(false), WIPED(false);
		
		public final Boolean getsMap;
		
		private State(Boolean getsMap) {
			this.getsMap = getsMap;
		}
	};

    private ArrayList<EventHandler> listForEventType( GDAppEventType type)
    {
    	if (eventHandlerLists == null) {
    		// Initially, this code initialized the array to have as many elements
    		// as GDAppEvent.Type.values().length but this seemed to be zero.
    		// Now it initializes it to zero and then appends an element for every
    		// value.
    		eventHandlerLists = new ArrayList<ArrayList<EventHandler>>(GDAppEventType.values().length);
    		for( @SuppressWarnings("unused") GDAppEventType value:
    			GDAppEventType.values())
    		{
    			eventHandlerLists.add(new ArrayList<EventHandler>(0));
    		}
    		// Executing the for loop seems to set the .length property.
    	}
        
        for( int i=0; i<GDAppEventType.values().length; i++ ) {
    		GDAppEventType valuei = GDAppEventType.values()[i];
    		if (valuei == type) {
    			return eventHandlerLists.get(i);
    		}
    	}
    	return null;
    }
    
    public void addEventHandler(
    		GDAppEventType type, EventHandler eventHandler)
    {
    	listForEventType(type).add(eventHandler);
    }
	
	@Override
	public void onGDEvent(GDAppEvent event) {
		for(EventHandler handler: listForEventType(event.getEventType())) {
        	handler.onReceiveMessage(event);
		}
	}

    private ArrayList<?> _listForState(State state)
    {
    	if (voidStateHandlerLists == null) {
    		voidStateHandlerLists = new ArrayList<ArrayList<VoidHandler>>(0);
    		mapStateHandlerLists = new ArrayList<ArrayList<MapHandler>>(0);
    		for( @SuppressWarnings("unused") State value: State.values())
    		{
    			voidStateHandlerLists.add(new ArrayList<VoidHandler>(0));
    			mapStateHandlerLists.add(new ArrayList<MapHandler>(0));
    		}
    	}

    	for( int i=0; i<State.values().length; i++ ) {
    		State valuei = State.values()[i];
    		if (valuei == state) {
    			if (state.getsMap) {
    				return mapStateHandlerLists.get(i);
    			}
    			else {
    				return voidStateHandlerLists.get(i);
    			}
    		}
    	}
    	return null;
    }
    
    @SuppressWarnings("unchecked")
	private ArrayList<MapHandler> mapListForState(State state) {
    	return (ArrayList<MapHandler>) _listForState(state);
    }

    @SuppressWarnings("unchecked")
	private ArrayList<VoidHandler> voidListForState(State state) {
    	return (ArrayList<VoidHandler>) _listForState(state);
    }

	public void addStateHandler(State state, Object handler)
    {
		if (state.getsMap) {
			mapListForState(state).add( (MapHandler)handler );
		}
		else {
			voidListForState(state).add( (VoidHandler)handler );
		}
    }
	 
	@Override
	public void onAuthorized() {
		for( VoidHandler handler: voidListForState(State.AUTHORIZED)) {
			handler.onReceiveMessage();
		}
	}

	@Override
	public void onLocked() {
		for( VoidHandler handler: voidListForState(State.LOCKED)) {
			handler.onReceiveMessage();
		}
	}

	@Override
	public void onUpdateConfig(Map<String, Object> map) {
		for( MapHandler handler: mapListForState(State.UPDATE_CONFIG)) {
			handler.onReceiveMessage(map);
		}
	}

	@Override
	public void onUpdatePolicy(Map<String, Object> map) {
		for( MapHandler handler: mapListForState(State.UPDATE_POLICY)) {
			handler.onReceiveMessage(map);
		}
	}

	@Override
	public void onUpdateServices() {
		for( VoidHandler handler: voidListForState(State.UPDATE_SERVICES)) {
			handler.onReceiveMessage();
		}
	}

    @Override
    public void onUpdateDataPlan() {

    }

    @Override
	public void onWiped() {
		for( VoidHandler handler: voidListForState(State.WIPED)) {
			handler.onReceiveMessage();
		}
	}

	public void addApplicationPoliciesHandler(
			final ConfigurationHandler handler,
			Boolean invokeNow )
	{
		if (invokeNow) {
			GDAndroid gdAndroid = GDAndroid.getInstance();
			handler.onReceiveMessage(
					gdAndroid.getApplicationPolicy(),
					gdAndroid.getApplicationPolicyString() );
		}
		addEventHandler(
			GDAppEventType.GDAppEventPolicyUpdate,
			new RuntimeDispatcher.EventHandler() {

				@Override
				public void onReceiveMessage(GDAppEvent event) {
					GDAndroid gdAndroid = GDAndroid.getInstance();
					handler.onReceiveMessage(
							gdAndroid.getApplicationPolicy(),
							gdAndroid.getApplicationPolicyString() );
				}
			});

	}
	
	public static Map<String,Object> getApplicationConfigWithoutDeprecations()
	{
		Map<String,Object> map = new HashMap<String,Object>(
				GDAndroid.getInstance().getApplicationConfig());
		map.remove("appHost");
		map.remove("appPort");
		return map;
	}
	
	public static Object JSONItemFrom(Object origin)
	{
		// If this was API level 19 only, we would use:
		// org.json.JSONObject.wrap()
		if (origin.getClass() == Map.class ||
			origin.getClass() == HashMap.class
		) {
			@SuppressWarnings("unchecked")
			Map<String,Object> map = (Map<String,Object>)origin;
			JSONObject ret = new JSONObject();
			for( String key: map.keySet() ) {
				Object value = map.get(key);
				try {
					ret.put(key, JSONItemFrom(value));
				} catch (JSONException e) {
					throw new Error(
						"RuntimeDispatcher JSONItemFrom((" +
						value.getClass().getSimpleName() + ") \"" + value + 
						"\") failed. JSONException thrown: " + e + ".\n");
				}
			}
			return ret;
		}
		else if (origin.getClass() == List.class ||
				 origin.getClass() == ArrayList.class
		) {
			@SuppressWarnings("unchecked")
			List<Object> list = (List<Object>)origin;
			JSONArray ret = new JSONArray();
			for( Object object : list) {
				ret.put( JSONItemFrom(object) );
			}
			return ret;
		}
		else if (origin.getClass() == GDAppServer.class) {
			GDAppServer gdAppServer = (GDAppServer)origin;
			JSONObject ret = new JSONObject();
			try {
				ret.put("server", gdAppServer.server);
				ret.put("port", gdAppServer.port);
				ret.put("priority", gdAppServer.priority);
			} catch(JSONException e) {
				throw new Error(
					"RuntimeDispatcher JSONItemFrom((GDAppServer) \"" + 
					gdAppServer + "\") failed. JSONException thrown: " + e + 
					".\n");
			}
			return ret;
		}
		else {
			JSONObject object = new JSONObject();
			try {
				object.putOpt("value", origin);
			} catch (JSONException e) {
				throw new Error(
						"RuntimeDispatcher JSONItemFrom((" +
						origin.getClass().getSimpleName() + ") \"" + origin + 
						"\") failed. No JSON itm for class.\n");
			}
			// Looks like the original object can be put in a JSONObject as is.
			return origin;
		}
	}
	
	public static String JSONStringFrom(Map<String,Object> map)
	{
		Object object = JSONItemFrom(map);
		if (object.getClass() == JSONObject.class) {
			return object.toString();
		}
		return null;
	}
	
	private void invokeHandler(
			ConfigurationHandler handler, Map<String,Object> map)
	{
		handler.onReceiveMessage( map, JSONStringFrom(map) );
	}

	public void addApplicationConfigurationHandler(
			final ConfigurationHandler handler, Boolean invokeNow )
	{
		if (invokeNow) {
			invokeHandler(handler, 
					getApplicationConfigWithoutDeprecations());
		}
		addEventHandler(
			GDAppEventType.GDAppEventRemoteSettingsUpdate,
			new RuntimeDispatcher.EventHandler() {

				@Override
				public void onReceiveMessage(GDAppEvent event) {
					invokeHandler(handler, 
							getApplicationConfigWithoutDeprecations());
				}
			});

	}
}
