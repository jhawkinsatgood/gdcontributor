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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;

import com.good.gd.GDAndroid;
import com.good.gd.GDAppServer;
import com.good.gd.net.GDSocket;

import com.good.example.contributor.jhawkins.demoframework.Component;
import com.good.gd.utility.GDAuthTokenCallback;
import com.good.gd.utility.GDUtility;

public class DemoAuthenticationToken extends Component implements GDAuthTokenCallback {
	
	public DemoAuthenticationToken() {
        super();
        demoExecuteLabel = "Authentication Token";
    }
	
	private GDAppServer gdAppServer0 = null;
	private GDUtility gdUtility = null;
    private GDSocket gdSocket = null;
    private OutputStream gdSocketOutput = null;
    private BufferedReader gdSocketReader = null;
    
    private Boolean openGDSocket(String server, int port)
    {
    	Boolean ret = true;
        try {
        	this.gdSocket = new GDSocket();
        	userInterface.demoLog(
        			"Socket connect \"" + server + "\" " + port + "...\n" );
        	this.gdSocket.connect(server, port, 0);
        	this.gdSocketOutput = this.gdSocket.getOutputStream();
            this.gdSocketReader =
            		new BufferedReader(
            				new InputStreamReader(
            						this.gdSocket.getInputStream()));
        } catch (IOException e) {
        	ret = false;
        	userInterface.demoLog(
        			"DemoAuthenticationToken open socket error " + e + ".\n");
        }
    	
        return ret;
    }
	
	@Override
	public String[] demoExecuteOrPickList()
	{
		this.gdAppServer0 = null;
		// Following palaver is to avoid unchecked type conversion warnings.
		// The approach is to get every object as an Object, then check it isn't
		// null and is of the correct type, which it will be, then cast it.
		userInterface.demoLog("Reading server configuration.\n");
		Object gdAppServers_object = 
				GDAndroid.getInstance().getApplicationConfig()
				.get(GDAndroid.GDAppConfigKeyServers);
		if (gdAppServers_object != null &&
			gdAppServers_object.getClass() == ArrayList.class
		) {
			ArrayList<?> gdAppServers = (ArrayList<?>)gdAppServers_object;
			if (gdAppServers.size() > 0) {
				Object gdAppServer_object = gdAppServers.get(0);
				if (gdAppServer_object != null && 
					gdAppServer_object.getClass() == GDAppServer.class
				) {
					this.gdAppServer0 = (GDAppServer)gdAppServer_object;
				}
			}
		}
		// End of palaver.
		
		if (this.gdAppServer0 == null) {
			userInterface.demoLog("No server addresses configured.\n");
			return null;
		}

	    // Initialise GD Auth utility
		if (this.gdUtility == null) {
			this.gdUtility = new GDUtility();
		}

        if (!openGDSocket(this.gdAppServer0.server, this.gdAppServer0.port)) {
        	// An error message will have been logged.
        	return null;
        }

        userInterface.demoLog("Socket write ...\n"); 
        byte cmd[] = new String("CHALLENGE\n").toString().getBytes();
        String challenge = null;
        try {
        	this.gdSocketOutput.write(cmd);
            userInterface.demoLog("Socket written.\n"); 
            userInterface.demoLog("Socket reading...\n");
            challenge = this.gdSocketReader.readLine();
            userInterface.demoLog("Received data \"" + challenge + "\"\n");
        } catch (IOException e) {
        	userInterface.demoLog(
        		"DemoAuthenticationToken challenge socket error " + e + ".\n");
        	challenge = null;
        }

		if (challenge != null) {
			gdUtility.getGDAuthToken(challenge, gdAppServer0.server, this);
            // Processing will continue in an onGDAuthToken... callback
		}
		
		return null;
	}

	@Override
	public void onGDAuthTokenFailure(int errCode, String errMsg) {
		userInterface.demoLog(
				"onGDAuthToken failure " + errCode + " " + errMsg + ".\n");
	}

	@Override
	public void onGDAuthTokenSuccess(String token) {
		userInterface.demoLog("onGDAuthToken success \"" + token + "\"\n");
		byte cmd[] = new String("TOKEN\n" + token + "\n\n").getBytes();
		String response = null;
		try {
			gdSocketOutput.write(cmd);
			// Read two lines.
            response = gdSocketReader.readLine() + "\n" +
            		gdSocketReader.readLine();
            userInterface.demoLog("Received response \"" + response + "\"\n");
            gdSocket.close();
            gdSocket = null;
		} catch (IOException e) {
        	userInterface.demoLog(
        		"DemoAuthenticationToken token socket error " + e + ".\n");
        	response = null;
		}

		// Check if the first character is O from OK
        if (response != null) {
        	if (response.charAt(0) == 'O') {
        		userInterface.demoLog("Token verified.\n");
        	}
        	else {
        		userInterface.demoLog("Token rejected.\n");
        	}
        }
	}

}
