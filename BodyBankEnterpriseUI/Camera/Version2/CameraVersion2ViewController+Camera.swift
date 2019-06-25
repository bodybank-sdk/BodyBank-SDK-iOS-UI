//
//  CameraVersion2ViewController+Camera.swift
//  AFDateHelper
//
//  Created by Masashi Horita on 2019/06/24.
//

import Foundation
import AVFoundation
import SwiftSpinner
import Alertift

public extension CameraVersion2ViewController{
    
    func startCapturing() {
        
        if capturing { return }
        
        capturing = true
        
        // フロントカメラではフォーカスできないため、この時点で撮影を発火する
        if !cameraFacingBack {
            captureImage()
            return
        }
        
        focusOnCenter() { [unowned self] in
            self.capturing = false
            self.timerStarted = false
            Alertift
                .alert(title: NSLocalizedString("", comment: ""),
                       message: NSLocalizedString("Failed to focus", comment: ""))
                .action(.cancel(NSLocalizedString("OK", comment: "")))
                .show()
            return
        }
    }
    
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
    
    func focusOnCenter(errorCallback:(() -> Void)?) {
        // Front Cameraではフォーカスはできない
        print("canFocus: \(canFocus)")
        print("lockingTouch: \(lockingTouch)")
        
        // TODO: カメラの初期化処理において Front Camera ではフォーカスできないのかをチェックする必要がある
        //if(captureDevice?.position == .front) {
        //     successCallback?()
        //if (canFocus && !lockingTouch) {
        
        if !lockingTouch {
            let location = cameraLayer.bounds.center
            self.canFocus = false
            let pointOfInterest = CGPoint(x: location.y / view.bounds.height, y: 1.0 - (location.x / view.bounds.width))
            let focused = self.focusAtPoint(pointOfInterest)
            
            if (!focused){
                errorCallback?()
            }
            
            return
        }
        
        errorCallback?()
    }
    
    // MARK: Touch to forcus
    
    func focusAtPoint(_ atPoint: CGPoint) -> Bool{
        guard let device = captureDevice else { return false }
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusPointOfInterestSupported {
                //Add Focus on Point
                device.focusMode = .autoFocus
                device.focusPointOfInterest = atPoint
            }
            // animate
            canFocus = true
            device.unlockForConfiguration()
            return true
        } catch {
            // handle error
            return false
        }
    }
    
    func setFocusMode(_ mode: AVCaptureDevice.FocusMode) -> Bool {
        guard let device = captureDevice else { return true }
        do {
            try device.lockForConfiguration()
            
            if device.isFocusModeSupported(mode) {
                //Add Focus on Point
                device.focusMode = mode
            }
            device.unlockForConfiguration()
        } catch {
            // handle error
            return false
        }
        
        return true
    }
    
    func setExposureMode(_ mode: AVCaptureDevice.ExposureMode) -> Bool {
        guard let device = captureDevice else { return true }
        do {
            try device.lockForConfiguration()
            
            if device.isExposureModeSupported(mode) {
                device.exposureMode = mode
            }
            
            device.unlockForConfiguration()
            return true
        } catch {
            return false
        }
    }
    
    func captureImage() {
        guard let _ = stillImageOutputImpl else { return }
        
        var sessionQueue: DispatchQueue!
        sessionQueue = DispatchQueue(label: "Capture Session", attributes: [])
        sessionQueue.async(execute: {
            do {
                try self.captureDevice?.lockForConfiguration()
            } catch {
                // handle error
                return
            }
            
            let settingsForMonitoring = AVCapturePhotoSettings()
            settingsForMonitoring.flashMode = .auto
            settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
            settingsForMonitoring.isHighResolutionPhotoEnabled = false
            self.completionAfterPhotoCapture = self.optimizeAndSetImage2EstimationParams
            self.stillImageOutput!.capturePhoto(with: settingsForMonitoring, delegate: self)
            self.captureDevice?.unlockForConfiguration()
        })
    }

    
}

extension CameraVersion2ViewController: AVCapturePhotoCaptureDelegate {
    @available(iOS 11.0, *)
    public func photoOutput(_ output: AVCapturePhotoOutput,
                            didFinishProcessingPhoto photo: AVCapturePhoto,
                            error: Error?) {
        
        attitudeWhenPhotoCaptured = currentAttitude
        if let cgImage = photo.cgImageRepresentation()?.takeUnretainedValue() {
            let image = UIImage(cgImage: cgImage)//, scale: 1.0, orientation: .right)
            self.completionAfterPhotoCapture?(image, nil)
        } else {
            self.completionAfterPhotoCapture?(nil, NSError())
        }
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput,
                            didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
    }
    
}

extension CameraVersion2ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput,
                              didOutput sampleBuffer: CMSampleBuffer,
                              from connection: AVCaptureConnection) {
        if showingLoading {
            showingLoading = false
            DispatchQueue.main.async {
                SwiftSpinner.hide()
            }
        }
    }
}



