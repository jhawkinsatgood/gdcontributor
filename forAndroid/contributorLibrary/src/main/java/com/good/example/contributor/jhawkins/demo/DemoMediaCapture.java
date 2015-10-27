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

import com.good.example.contributor.jhawkins.demoframework.Panel;
import com.good.example.contributor.jhawkins.demoframework.PanelItem;
import com.good.example.contributor.jhawkins.demoframework.PanelItemType;
import com.good.example.contributor.jhawkins.gdccommunication.GdcHttp;
import com.good.example.contributor.jhawkins.gdccommunication.ProgressListener;
import com.good.example.contributor.jhawkins.gdcmedia.CameraPreview;
import com.good.example.contributor.jhawkins.gdcmedia.Playback;
import com.good.example.contributor.jhawkins.gdcmedia.Recording;
import com.good.example.contributor.jhawkins.gdcmedia.Utility;
import com.good.example.contributor.jhawkins.gdruntime.RuntimeDispatcher;
import com.good.gd.GDAndroid;
import com.good.gd.GDAppServer;
import com.good.gd.file.File;

import java.io.IOException;
import java.util.List;
import java.util.Map;

public class DemoMediaCapture extends Panel {

    private PanelItem stopItem = null;
    private int[] stopItemLocation = null;

    private Recording recording = null;
    private Playback playback = null;
    Utility.Logger mediaLogger = null;

    private String uploadURL = null;
    private RuntimeDispatcher.ConfigurationHandler configurationHandler = null;

    private class PanelItemStop extends PanelItem {
        public PanelItemStop () {
            super(PanelItemType.COMMANDBACK, "Stop");
        }

        public void onClick() {
            this.panel.userInterface().demoLog(
                    this.getClass().getSimpleName() + ".onClick(" + userData + ")\n");

            if (recording != null) recording.stop();
            if (playback != null) playback.stop();

            removeStopItem();

            // Todo: Replace this with a completion handler in the Recording, or Playback.
            demoPanelLoad(false);
        }
    }

    public void addStopItem() {
        if (stopItemLocation != null) return;

        if (stopItem == null) {
            stopItem = new PanelItemStop();
        }
        stopItemLocation = appendToDivision(0, stopItem);
    }

    public PanelItem removeStopItem() {
        if (stopItemLocation == null) return null;
        PanelItem panelItem = removeItemAt(stopItemLocation[0], stopItemLocation[1]);
        stopItemLocation = null;
        return panelItem;
    }

    private Utility.Logger getMediaLogger() {
        if (mediaLogger == null)
            mediaLogger = new Utility.Logger() {
                @Override
                public void logMessage(String message) {
                    DemoMediaCapture.this.userInterface().demoLog(message);
                }
            };
        return mediaLogger;
    }

    private class PanelItemRecord extends PanelItem {
        public PanelItemRecord (String userData) {
            super(PanelItemType.COMMANDON, "Record", userData);
        }

        public void onClick() {
            this.panel.userInterface().demoLog(
                    this.getClass().getSimpleName() + ".onClick(" + userData + ")\n");

            File directory = new File((String)userData);
            final File path = com.good.example.contributor.jhawkins.demo.Utility.
                    numberedFileIn(directory, "capture", "pcm");
            if (path == null) {
                userInterface().demoLog(
                        "Couldn't generate numbered file in \"" + directory + "\".\n");
                return;
            }

            recording = new Recording();
            recording.logger = getMediaLogger();
            String recordingError = recording.startOrError(path, getActivity());
            if (recordingError == null) {
                addStopItem();
            }
            else {
                this.panel.userInterface().demoLog(
                        this.getClass().getSimpleName() + " failed to start recording. " +
                        recordingError+ "\n");
            }
        }
    }

    private class PanelItemPlay extends PanelItem {
        public PanelItemPlay (String userData) {
            super(PanelItemType.COMMANDON, "Play", userData);
        }

        public void onClick() {
            this.panel.userInterface().demoLog(
                    this.getClass().getSimpleName() + ".onClick(" + userData + ")\n");

            playback = new Playback();
            playback.logger = getMediaLogger();
            String playbackError = playback.startOrError((String)userData, getActivity());
            if (playbackError == null) {
                addStopItem();
            }
            else {
                this.panel.userInterface().demoLog(
                        this.getClass().getSimpleName() + " failed to start playback. " +
                                playbackError+ "\n");
            }
        }

    }

    private class PanelItemCamera extends PanelItem {
        public PanelItemCamera (String userData) {
            super(PanelItemType.COMMANDON, "Camera", userData);
        }

        CameraPreview cameraPreview = null;

        @Override
        public void onClick() {
            userInterface().demoLog(
                    this.getClass().getSimpleName() + ".onClick(" + userData + ")\n");

            File directory = new File((String)userData);
            final File path = com.good.example.contributor.jhawkins.demo.Utility.
                    numberedFileIn(directory, "capture", "jpeg");
            if (path == null) {
                userInterface().demoLog(
                        "Couldn't generate numbered file in \"" + directory + "\".\n");
                return;
            }

            userInterface().activity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    cameraPreview = (CameraPreview)(userInterface().secondView());
                    cameraPreview.logger = getMediaLogger();

                    cameraPreview.runnableOnCapture = new Runnable() {
                        @Override
                        public void run() {
                            panel.demoPanelLoad(true);
                        }
                    };

                    cameraPreview.setCamera(path, userInterface().activity());
                }
            });

        }
    }

    private class PanelItemUpload extends PanelItem {
        public PanelItemUpload (File userData) {
            super(PanelItemType.COMMANDON, "Upload", userData);
        }

        private ProgressListener progressListener = null;
        private Boolean needNL = false;

        @Override
        public void onClick() {
            if (uploadURL == null) {
                userInterface().demoLog("No upload URL.\n");
                return;
            }

            File path = (File)userData;

            progressListener = new ProgressListener() {
                @Override
                public long getProgressStep() { return 10L * 0x8000L; }

                @Override
                public void started() {
                    userInterface().demoLog("Starting upload");
                    needNL = true;
                }

                @Override
                public void transferred(long transferredBytes) {
                    userInterface().demoLog(" " + transferredBytes);
                    needNL = true;
                }
            };

            try {
                String status = GdcHttp.upload(uploadURL, path, progressListener);
                userInterface().demoLog( (needNL ? "\n" : "") +
                        "Upload finished: " + status + ".\n");
            } catch (IOException exception) {
                userInterface().demoLog( (needNL ? "\n" : "") +
                        "Failed to upload \"" + path + "\". " + exception.toString());
            }
            needNL = false;
        }
    } // PanelItemUpload class.

    private class PanelItemDelete extends PanelItem {
        public PanelItemDelete(File userData) {
            super(PanelItemType.COMMANDON, "Delete", userData);
        }

        @Override
        public void onClick() {
            File path = (File)userData;

            if (!path.delete()) userInterface().demoLog(
                    "Failed to delete \"" + path.toString() + "\".\n");
            panel.demoPanelLoad(true);
        }
    }

    private void listMediaDirectory(String path, Boolean playButtons)
    {
        File directory = new File(path);

        if (!directory.exists()) {
            // Todo: Check whether there is a file already and delete it if there is.
            Boolean mkdirsOK = directory.mkdirs();
            if (mkdirsOK) {
                userInterface().demoLog("Created directory \"" + path + "\".\n");
            }
            else {
                userInterface().demoLog("Failed to create directory \"" + path + "\".\n");
            }
        }

        String[] listing = directory.list();
        for (String listingi : listing) {
            File file = new File(path, listingi);
            int division = addDivision( new PanelItem(file.getName()) );
            if (playButtons) {
                appendToDivision(division, new PanelItemPlay(file.toString()));
            }
            appendToDivision(division, new PanelItemUpload(file));
            appendToDivision(division, new PanelItem(Long.toString(file.length())));
            appendToDivision(division, new PanelItemDelete(file));
        }
    }

    private void observeConfiguration()
    {
        if (configurationHandler == null) {
            configurationHandler = new RuntimeDispatcher.ConfigurationHandler() {
                @Override
                public void onReceiveMessage(Map<String, Object> map, String string) {
                    List<GDAppServer> servers =
                            (List<GDAppServer>) map.get(GDAndroid.GDAppConfigKeyServers);
                    if (servers.size() <= 0) {
                        userInterface().demoLog("No server configured for upload.\n");
                        return;
                    }

                    String newURL = "http://" + servers.get(0).server + ":" + servers.get(0).port;
                    if (uploadURL == null || !uploadURL.equalsIgnoreCase(newURL)) {
                        uploadURL = newURL;
                        userInterface().demoLog("Will upload to \"" + uploadURL + "\"\n");
                    }
                }
            };
            RuntimeDispatcher.getInstance().addApplicationConfigurationHandler(
                    configurationHandler, true);
        }
    }

    @Override
    public void demoPanelLoad(Boolean andRefresh)
    {
        observeConfiguration();
        deleteAllDivisions();

        addDivision(
                new PanelItem("Media Capture"),
                new PanelItemRecord("recordings"),
                new PanelItemCamera("photos")
        );

        listMediaDirectory("photos", false);
        listMediaDirectory("recordings", true);

        if (andRefresh) {
            this.userInterface.refresh();
        }
    }

}
