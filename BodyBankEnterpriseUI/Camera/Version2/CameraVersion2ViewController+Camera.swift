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
    
    // MARK: - Initial Methods
    func initializeCapture() {
        previewLayer?.removeFromSuperlayer()
        stillImageOutputImpl = nil
        captureSession = AVCaptureSession()
        initializeCameraSession(captureDevice?.position != .front)
        setupFocusObserver()
    }
    
    
    /// Camera Initialize
    /// カメラの初期化を行う
    /// - Parameter facingBack: false=frontCamera,true=backCamera
    func initializeCameraSession(_ facingBack: Bool) {
        cameraFacingBack = facingBack
        canFocus = facingBack
        captureSession = AVCaptureSession()
        // iPhoneバージョンによるサポートする解像度の違い (iPhone S4は切り捨て)
        // https://stackoverflow.com/questions/19422322/method-to-find-devices-camera-resolution-ios
        if facingBack {
            captureSession.sessionPreset = .hd1920x1080
        } else {
            captureSession.sessionPreset = .photo
        }
        
        
        if facingBack {
            captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                    for: .video,
                                                    position: .back)
        } else {
            captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                    for: .video,
                                                    position: .front)
        }
        
        setupCamera()
    }
    


    /// カメラの撮影を行う
    /// startCaputuring
    func startCapturing() {
        print("[camera][startCapturing]: \(capturing)")
        if capturing { return }
        capturing = true
        
        // フロントカメラではフォーカスできないため、この時点で撮影を発火する
        if !cameraFacingBack {
            captureImage()
            return
        }
        
        // Foce Error happen
        focusOnCenter() { [weak self] in
            guard let self = self else { return }
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
        
        let _ = setHDR(mode: false)
        
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
        
        if lockingTouch {
            errorCallback?()
            return
        }

        let location = cameraLayer.bounds.center
        self.canFocus = false
        let pointOfInterest = CGPoint(x: location.y / view.bounds.height, y: 1.0 - (location.x / view.bounds.width))
        let focused = self.focusAtPoint(pointOfInterest)
        
        if !focused {
            errorCallback?()
        }
        
    
    }
    
    // MARK: Touch to forcus
    
    
    /// Catch the isAdjusting Focus with KVO after doing the focus. Shoot the camera
    /// フォーカスを行なった後にKVOでisAdjustingFocusをキャッチして、カメラの撮影を行う
    /// - Parameter atPoint: <#atPoint description#>
    /// - Returns: <#return value description#>
    func focusAtPoint(_ atPoint: CGPoint) -> Bool{
        print("[camera][focusAtPoint]")
        guard let device = captureDevice else { return false }
        
        do {
            try device.lockForConfiguration()
            
            //focasチェック
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
                device.focusMode = mode
            }
            device.unlockForConfiguration()
        } catch {
            return false
        }
        
        return true
    }
    
    
    /// Setting Exposure
    /// 露出の設定を行う
    /// - Parameter mode:
    /// - Returns: true:success false:false
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
    
    /// Setting HDR
    /// 露出の設定を行う
    /// - Parameter mode:
    /// - Returns: true:success false:false
    func setHDR( mode: Bool) -> Bool {
//        guard let device = captureDevice else { return true }
//        do {
//            try device.lockForConfiguration()
//            device.isVideoHDREnabled = mode
//            device.unlockForConfiguration()
//            return true
//        } catch {
//            return false
//        }
        return true
    }

    
    func captureImage() {
        guard let _ = stillImageOutputImpl else { return }
        
        //MEMO: 連写されるバグが発生。
        //      原因が不明の為、二秒以内に呼び出された場合、写真を送り込まないように処理を実装しておく
        if chaptureImageChecker {
            print("[camera][連写]")
            return
        }
        print("[camera][連写防止]")
        chaptureImageChecker = true
        let dispatchQueue = DispatchQueue(label: "qu")
        dispatchQueue.asyncAfter(deadline: .now() + 1) {
            print("[camera][連写防止完了]")
            self.capturing = false
            self.chaptureImageChecker = false
        }
        
        
        var sessionQueue: DispatchQueue!
        sessionQueue = DispatchQueue(label: "Capture Session", attributes: [])
        sessionQueue.async(execute: {
            do {
                try self.captureDevice?.lockForConfiguration()
            } catch {
                print("[camera][captureImage][lockError]")
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

    // CameraTimer
    
    func startCountDownTimer() {
        if timerStarted { return }
        
        if !setupEstimationParameter() {
            Alertift.alert(title: nil, message: NSLocalizedString("Input height, weight, age and gender.", comment: ""))
                .action(.default("OK"))
                .show(on: self, completion: nil)
            return
        }
        
        timerStarted = true
        countLabel.isHidden = false
        countLabel.alpha = 0
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.countLabel.alpha = 1
        }) { [weak self] finished in
            if finished {
                self?.startCaptureTimer()
            }
        }
    }
    
    func startCaptureTimer() {
        countDownTimeCount(count: 10)
    }
    
    func countDownTimeCount(count: Int) {
        countLabel.text = "\(count)"
        if count == 0 {
            countLabel.isHidden = true
            
            // ADD:
            // angle condition
            if !captureButton.isEnabled {
                Alertift
                    .alert(title: nil,
                           message: NSLocalizedString("Angle condition is not met. Please fix the angle.", comment: ""))
                    .action(.default("OK"))
                    .show(on: self, completion: nil)
                timerStarted = false
                return
            }
            
            startCapturing()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.countDownTimeCount(count: count - 1)
            }
        }
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



