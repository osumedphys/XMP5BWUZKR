/*
     File: AVCamDemoCaptureManager.h
 Abstract: Code that calls the AVCapture classes to implement the camera-specific features in the app such as recording, still image, camera exposure, white balance and so on.
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol AVCamDemoCaptureManagerDelegate
@optional
- (void) captureStillImageFailedWithError:(NSError *)error;
- (void) acquiringDeviceLockFailedWithError:(NSError *)error;
- (void) cannotWriteToAssetLibrary;
- (void) assetLibraryError:(NSError *)error forURL:(NSURL *)assetURL;
- (void) someOtherError:(NSError *)error;
- (void) recordingBegan;
- (void) recordingFinished;
- (void) deviceCountChanged;
@end

@interface AVCamDemoCaptureManager : NSObject {
    @private
    AVCaptureSession *_session;
    AVCaptureDeviceInput *_videoInput;
    id <AVCamDemoCaptureManagerDelegate> _delegate;
    
    AVCaptureDeviceInput *_audioInput;
    AVCaptureMovieFileOutput *_movieFileOutput;
    AVCaptureStillImageOutput *_stillImageOutput;
    AVCaptureVideoDataOutput *_videoDataOutput;
    AVCaptureAudioDataOutput *_audioDataOutput;
    id _deviceConnectedObserver;
    id _deviceDisconnectedObserver;
    UIBackgroundTaskIdentifier _backgroundRecordingID;
}

@property (nonatomic,readonly,retain) AVCaptureSession *session;
@property (nonatomic,readonly,retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic,assign) AVCaptureFlashMode flashMode;
@property (nonatomic,assign) AVCaptureTorchMode torchMode;
@property (nonatomic,assign) AVCaptureFocusMode focusMode;
@property (nonatomic,assign) AVCaptureExposureMode exposureMode;
@property (nonatomic,assign) AVCaptureWhiteBalanceMode whiteBalanceMode;
@property (nonatomic,readonly,getter=isRecording) BOOL recording;
@property (nonatomic,assign) id <AVCamDemoCaptureManagerDelegate> delegate;
@property (nonatomic,retain) UIImage *lastCapped;

- (BOOL) setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error;
- (NSUInteger) cameraCount;
- (NSUInteger) micCount;
- (void) startRecording;
- (void) stopRecording;
- (void) captureStillImage;
- (BOOL) cameraToggle;
- (BOOL) hasMultipleCameras;
- (BOOL) hasFlash;
- (BOOL) hasTorch;
- (BOOL) hasFocus;
- (BOOL) hasExposure;
- (BOOL) hasWhiteBalance;
- (void) focusAtPoint:(CGPoint)point;
- (void) exposureAtPoint:(CGPoint)point;
- (void) setConnectionWithMediaType:(NSString *)mediaType enabled:(BOOL)enabled;
+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections;

- (UIImage*) getLastCapped;

@end
