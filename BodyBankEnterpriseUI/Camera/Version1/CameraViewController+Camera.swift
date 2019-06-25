//
//  CameraViewController+Camera.swift
//  AFDateHelper
//
//  Created by Masashi Horita on 2019/06/06.
//

//import Foundation
import AVFoundation

public extension CameraViewController{
    
    func setupCamera() {
        if cameraFacingBack {
            let _ = setFocusMode(AVCaptureDevice.FocusMode.continuousAutoFocus)
            let _ = setExposureMode(.continuousAutoExposure)
        }
        
        // get capture device
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession.addInput(captureDeviceInput)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        let output = AVCapturePhotoOutput()
        stillImageOutputImpl = output
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }

        let videoOutput = AVCaptureVideoDataOutput()
        
        if captureSession.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())
            captureSession.addOutput(videoOutput)
        }
        
        if captureDevice?.isFlashAvailable == nil {
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.frame = cameraLayer.bounds
        updatePreviewLayerOrientation(withLayerSize: cameraLayer.bounds.size)
        self.cameraLayer.layer.addSublayer(previewLayer!)
        captureSession.startRunning()
    }

}
