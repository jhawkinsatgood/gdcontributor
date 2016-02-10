# Media Capture Application

The application has been tested in the following environment.

-   Android device: Samsung S4 running Android 5.0.1
-   iOS device: iPad running 9.2.1

Record Audio
============
To record audio in the contributor application:

1.  Tap the Record button. Audio recording **starts immediately**, to the Good
    Dynamics secure file system.  
    A new button appears: Stop.

2.  Tap the Stop button. Recording stops.

3.  An audio file is created and appears in the listing part of the display.

File formats are:

-   Raw PCM, for Android.
-   Uncompressed AIFF, for iOS.

Take Photo
==========
To take a photo in the contributor application:

1.  Tap the Camera button. The display is replaced with a camera preview.

2.  The camera preview is different on different platforms.

    -   For Android, single tap the screen anywhere. The device will auto-focus
        and take a picture.
    -   For iOS, the device does continuous auto-focus. Tap the Photo button to
        take a picture.
        
    On either platform, the camera preview closes when you take a picture.

3.  Image data is written to the God Dynamics secure file system, in JPEG format.
    The file appears in the listing part of the display.

Listing
=======
The contributor application lists files that have been captured below the Record
and Camera buttons. For each file:

-   The name is displayed.
-   The file size in bytes is displayed. On iOS, the modified time is also
    displayed.
-   A number of action buttons are displayed:

    -   Tap the Upload button to initiate upload of the file to a server, see
        below.
    -   Tap the Play button to play an audio file, on the device. This button is
        only shown for audio files.
    -   Tap the Delete button to delete the file. It will be removed from the
        device, and from the listing.

Upload
======
The contributor application can upload files that it captured.

-   Upload is to the first server address and port configured in the enterprise
    Good Control server. A URL is constructed by appending those values to
    `http://`.

-   The contributor sends a simple POST request using Good Dynamics secure
    communication. The request body consists of the file and no form parameters.

-   A sample server that can receive the request is provided, in the
    `recvmedia.py` file.

-   Audio files from Android are uploaded in raw PCM format, which cannot be
    played by most media players. It is easy to convert raw PCM to uncompressed
    WAV, for example, with the `sox` utility. The sample server, above, invokes
    the sox utility with suitable parameters to do this conversion.

Feature Requests
================
The following features have been requested at time of writing.

-   The application for Android should resume camera preview after a change of
    orientation of the device.
-   The application should be able to consume the Good Dynamics Send File
    service, and perhaps other services.
-   There should be a way to display a previously captured image on the device.
-   The camera preview user interface should be programmatic so that it would be
    easy to utilise in another application.
-   The application for Android should compute and add a RIFF header to the
    audio files that it creates. The files would then be playable without
    conversion.
-   Audio files should be compressed on the device. This would require
    conversion to a compressed format. The files would then be quicker to
    upload.
-   The application for iOS should use chunked transfer encoding and display
    upload progress.
-   The application source should include code that uses current supported
    programming interfaces:
    
    -   Android Camera2 instead of Android Camera.
    -   A replacement for Android Apache HTTP Client, when available in Good
        Dynamics for Android.
    -   The new GDFileManager class for iOS instead of GDFileSystem.
