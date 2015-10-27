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

package com.good.example.contributor.jhawkins.gdcmedia;

import android.app.Activity;
import android.content.Context;
import android.hardware.Camera;
import android.util.AttributeSet;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.widget.Toast;

import com.good.gd.file.File;
import com.good.gd.file.FileOutputStream;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.List;

public class CameraPreview
        extends SurfaceView
        implements SurfaceHolder.Callback, View.OnClickListener, Camera.AutoFocusCallback
{
    public Utility.Logger logger = null;
    public Runnable runnableOnCapture = null;
    private View viewAtClick = null;

    private Camera camera = null;
    private List supportedPreviewSizes = null;

    private SurfaceHolder surfaceHolder = null;

    private File path = null;

    // setUp() is only called by the constructors.
    private void setUp() {
        surfaceHolder = this.getHolder();
        surfaceHolder.addCallback(this);
        this.setOnClickListener(this);
        this.setClickable(true);
        this.setSecure(true);

        logger = new Utility.Logger() {
            @Override
            public void logMessage(String message) {
                return;
            }
        };
    }

    public CameraPreview(Context context) {
        super(context);
        if (!this.isInEditMode()) setUp();
    }

    public CameraPreview(Context context, AttributeSet attrs) {
        super(context, attrs);
        if (!this.isInEditMode()) setUp();
    }

    public CameraPreview(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        if (!this.isInEditMode()) setUp();
    }

    private void setCameraDisplayOrientation(Activity activity, int cameraId)
    {
        android.hardware.Camera.CameraInfo info = new android.hardware.Camera.CameraInfo();
        android.hardware.Camera.getCameraInfo(cameraId, info);

        int rotation = activity.getWindowManager().getDefaultDisplay().getRotation();
        int degrees = 0;
        switch (rotation) {
            case Surface.ROTATION_0: degrees = 0; break;
            case Surface.ROTATION_90: degrees = 90; break;
            case Surface.ROTATION_180: degrees = 180; break;
            case Surface.ROTATION_270: degrees = 270; break;
        }

        int result;
        if (info.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
            result = (info.orientation + degrees) % 360;
            result = (360 - result) % 360;  // compensate the mirror
        } else {  // back-facing
            result = (info.orientation - degrees + 360) % 360;
        }
        camera.setDisplayOrientation(result);
    }

    public void setCamera(File path, Activity activity)
    {
        this.path = null;
        clearCamera();

        int numberOfCameras = Camera.getNumberOfCameras();
        logger.logMessage("Number of cameras:" + numberOfCameras + "\n");
//                for (int cameraNumber=0; cameraNumber < numberOfCameras; cameraNumber++) {
        this.camera = Camera.open();
        if (this.camera == null) {
            logger.logMessage("Failed to open camera.\n");
            return;
        }
        this.path = path;

//                }
        this.setVisibility(View.VISIBLE);

        List<android.hardware.Camera.Size> localSizes =
                this.camera.getParameters().getSupportedPreviewSizes();
        supportedPreviewSizes = localSizes;
        requestLayout();

        try {
            camera.setPreviewDisplay(surfaceHolder);
        } catch (IOException e) {
            e.printStackTrace();
        }

        camera.enableShutterSound(true);
        setCameraDisplayOrientation(activity, 0);

        // Important: Call startPreview() to start updating the preview
        // surface. Preview must be started before you can take a picture.
        this.camera.startPreview();
        Toast.makeText(activity, "Tap to focus and take picture.", Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onAutoFocus(boolean success, Camera camera) {
        capture();
    }

    private class PictureCallbackJPEG implements Camera.PictureCallback {
        private Runnable runnable;

        public PictureCallbackJPEG(Runnable runnable) {
            this.runnable = runnable;
        }

        @Override
        public void onPictureTaken(byte[] data, Camera camera) {

            FileOutputStream fileOutputStream = null;
            if (path == null) {
                logger.logMessage("Picture taken but path is null.\n");
            }
            else {
                try {
                    fileOutputStream = new FileOutputStream(path);
                } catch (FileNotFoundException exception) {
                    logger.logMessage(this.getClass().getSimpleName() +
                            " failed to open for writing \"" + path + "\". " + exception + ".\n");
                    fileOutputStream = null;
                }

                if (fileOutputStream != null) {
                    try {
                        fileOutputStream.write(data);
                    } catch (IOException exception) {
                        logger.logMessage(this.getClass().getSimpleName() +
                                " failed to write to \"" + path + "\". " + exception + ".\n");
                    }
                    try {
                        fileOutputStream.close();
                    } catch (IOException exception) {
                        logger.logMessage(this.getClass().getSimpleName() +
                                " failed to close \"" + path + "\". " + exception);
                    }
                }
            }

            runnable.run();
        }
    }

    private void clearCamera()
    {
        if (this.camera != null) {
            this.camera.stopPreview();
            this.camera.release();
            this.camera = null;
        }

    }

    private void capture()
    {
        if (this.camera == null) {
            logger.logMessage("Camera null at capture.\n");
            return;
        }

        final View view = viewAtClick;
        this.camera.takePicture(null, null, null, new PictureCallbackJPEG(
                new Runnable() {
                    @Override
                    public void run() {
                        clearCamera();
                        if (view != null) view.setVisibility(INVISIBLE);
                        if (runnableOnCapture != null) runnableOnCapture.run();
                    }
                }
        ));
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {

        logger.logMessage(
                "surfaceCreated() " + holder.getSurfaceFrame().width() +
                        " x " + holder.getSurfaceFrame().height() + ".\n");
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
        logger.logMessage(
                "surfaceChanged() " + width + " x " + height + ".\n");
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        logger.logMessage("surfaceDestroyed()\n");
        clearCamera();
    }

    @Override
    public void onClick(View view) {
        viewAtClick = view;
        camera.autoFocus(this);
    }

}
