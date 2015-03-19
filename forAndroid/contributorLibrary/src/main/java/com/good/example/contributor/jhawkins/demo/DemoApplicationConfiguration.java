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

import java.util.Map;

import org.json.JSONException;
import org.json.JSONObject;

import com.good.example.contributor.jhawkins.demoframework.Component;
import com.good.example.contributor.jhawkins.gdruntime.RuntimeDispatcher;

public class DemoApplicationConfiguration
extends Component
implements RuntimeDispatcher.ConfigurationHandler
{

	public DemoApplicationConfiguration() {
        super();
        demoExecuteLabel = "Application Configuration";
    }

	@Override
	public String[] demoExecuteOrPickList()
	{
		RuntimeDispatcher.getInstance().addApplicationConfigurationHandler(
				this, true);
		userInterface.demoLog( "Ready for configuration updates.\n" );
		return null;
	}

	public void onReceiveMessage(Map<String, Object> map, String string) {
		userInterface.demoLog("Configuration map " + map.toString() + "\n");
		if (string == null) {
			userInterface.demoLog( "Configuration string null.\n" );
		}
		else {
			try {
				JSONObject jsonObject = new JSONObject(string);
				userInterface.demoLog( "Configuration string " + 
						jsonObject.toString(2) + "\n" );
			} catch (JSONException e) {
				userInterface.demoLog(
						"JSON exception raised by application configuration " +
						"string \"" + string + "\". " + 
						e.getLocalizedMessage() + ".\n");
			}
		}
	}

}
