//
//  CameraViewController.swift
//  Bodygram
//
//  Created by Shunpei Kobayashi on 2018/05/13.
//  Copyright © 2018年 Original Inc. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
import MobileCoreServices
import ImageIO
import CoreMotion
import CoreImage
import Photos
import SwiftSpinner
import Alertift
import BodyBankEnterprise
import SimpleImageViewerNew

public protocol CameraViewControllerDelegate: class{
    func cameraViewControllerDidCancel(viewController: CameraViewController)
    func cameraViewControllerDidFinish(viewController: CameraViewController)
}

open class CameraViewController: UIViewController {

    open weak var delegate: CameraViewControllerDelegate?
    open var shouldBlurFace = true
    @IBOutlet open weak var cameraLayer: UIView!
    var captureSession = AVCaptureSession()
    var captureDevice: AVCaptureDevice?
    var stillImageOutputImpl: NSObject?
    
    @available(iOS 10.0, *)
    var stillImageOutput: AVCapturePhotoOutput?{
        get{
            return stillImageOutputImpl as? AVCapturePhotoOutput
        }
    }
    
    var stillImageOutputV9: AVCaptureStillImageOutput?{
        get{
            return stillImageOutputImpl as? AVCaptureStillImageOutput
        }
    }

    var previewLayer: AVCaptureVideoPreviewLayer?
    var imageCaptured: UIImage?

    var showingLoading = false
    var lockingTouch: Bool = false
    var cameraFacingBack: Bool = false
    var capturing: Bool = false
    @IBOutlet weak var guideImageView: UIImageView!
    open var estimationParameter: EstimationParameter = EstimationParameter()
    @IBOutlet weak var grayoutView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var frontImageButton: UIButton!
    @IBOutlet weak var heightValueLabel: UILabel!
    @IBOutlet weak var heightUnitLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var angleView: UIView!
    @IBOutlet weak var tiltView: UIView!
    @IBOutlet weak var weightValueLabel: UILabel!
    @IBOutlet weak var weightUnitLabel: UILabel!
    @IBOutlet weak var ageValueLabel: UILabel!

    let motionManager: CMMotionManager = CMMotionManager()
    var currentAttitude: CMAttitude?
    var attitudeWhenPhotoCaptured: CMAttitude?
    var currentGravity: CMAcceleration?
    var previousTranslationY = 0.0
    var capturingFront = true {
        didSet {
            if capturingFront {
                if let bundle = BodyBankEnterprise.CameraUI.bundle{
                 guideImageView.image = UIImage(named: "front", in: bundle, compatibleWith: nil)
                }
                frontImageButton.isHidden = true
                estimationParameter.frontImage = nil
                frontImageButton.setImage(nil, for: .normal)
            } else {
                if let bundle = BodyBankEnterprise.CameraUI.bundle{
                    guideImageView.image = UIImage(named: "side", in: bundle, compatibleWith: nil)
                }
                frontImageButton.isHidden = false
                estimationParameter.sideImage = nil
                frontImageButton.setImage(estimationParameter.frontImage, for: .normal)
            }
        }
    }
    var navigationBarBackgroundImage: UIImage?

    // MARK: View cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        frontImageButton.imageView?.contentMode = .scaleAspectFill
        reloadParameters()
        title = NSLocalizedString("Stand inside the outline", comment: "")
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        buildGradientLayer()
    }
    
    func buildGradientLayer(){
        if navigationBarBackgroundImage == nil{
            navigationBarBackgroundImage =  navigationController?.navigationBar.setUpBodyBankGradient()
        }
    }

    func setupAfterViewAppear() {
        if (!captureSession.isRunning) {
            captureSession.startRunning()
        }
        lockingTouch = false
        if (cameraLayer.alpha == 0) {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.cameraLayer.alpha = 1;
            })
        }

    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SwiftSpinner.show(NSLocalizedString("Please Wait...", comment: ""))
        showingLoading = true

        PermissionUtil.checkPhotoLibraryPermission(self, callback: { [weak self] (dialogShown) in
            PermissionUtil.checkCameraPermission(self, callback: { (dialogShown) in
                self?.initializeCapture()
                self?.setupAfterViewAppear()
            })
        })
        startListeningGyro()
    }
    

    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier{
        case "show_height_picker":
            if let vc = segue.destination as? HeightPickerViewController{
                vc.setInitialValue(valueString: heightValueLabel.text!, unit: heightUnitLabel.text!)
            }
        case "show_weight_picker":
            if let vc = segue.destination as? WeightPickerViewController{
                vc.setInitialValue(valueString: weightValueLabel.text!, unit: weightUnitLabel.text!)
            }
            
        case "show_age_picker":
            if let vc = segue.destination as? AgePickerViewController{
                vc.setInitialValue(valueString: ageValueLabel.text!, unit: "")
            }
        default:
            break
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession.isRunning) {
            captureSession.stopRunning()
        }
        lockingTouch = true
        stopListeningGyro()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraLayer.alpha = 0
    }

    @IBAction func genderControlValueDidChange(sender: UISegmentedControl){
        switch sender.selectedSegmentIndex {
        case 0:
            estimationParameter.gender = .male
        default:
            estimationParameter.gender = .female
        }
    }
    
    @IBAction func didFinishPickingParameter(segue: UIStoryboardSegue){
        if let vc = segue.source as? AgePickerViewController{
            estimationParameter.age = vc.age
            ageValueLabel.text = String(estimationParameter.age)
        }else if let vc = segue.source as? HeightPickerViewController{
            estimationParameter.heightInCm = vc.heightInCm
            heightValueLabel.text = String(format:"%.2f", vc.currentValue)
            heightUnitLabel.text = vc.unit
        }else if let vc = segue.source as? WeightPickerViewController{
            estimationParameter.weightInKg = vc.weightInKg
            weightValueLabel.text = String(format:"%.2f", vc.currentValue)
            weightUnitLabel.text = vc.unit
        }
    }
    
    @IBAction func didCancelPickingParameter(segue: UIStoryboardSegue){
        
    }
    
    @IBAction func cancelButtonDidTap(sender: Any){
        if capturingFront{
            closeButtonDidTap(sender: sender)
        }else{
            delegate?.cameraViewControllerDidCancel(viewController: self)
        }
    }
    
    
    // MARK: Initial Methods
    func initializeCapture() {
        previewLayer?.removeFromSuperlayer()
        stillImageOutputImpl = nil
        captureSession = AVCaptureSession()
        initializeCameraSession(captureDevice?.position != .front)
    }


    func initializeCameraSession(_ facingBack: Bool) {
        cameraFacingBack = facingBack
        canFocus = facingBack
        // captureSession
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if ((device as AnyObject).hasMediaType(.video)) {
                if facingBack {
                    if ((device as AnyObject).position == AVCaptureDevice.Position.back) {
                        captureDevice = device as? AVCaptureDevice
                        if captureDevice != nil {
                            setupCamera()
                        }
                    }
                } else {
                    if ((device as AnyObject).position == AVCaptureDevice.Position.front) {
                        captureDevice = device as? AVCaptureDevice
                        if captureDevice != nil {
                            setupCamera()
                        }
                    }
                }
            }

        }
    }

    func setupCamera() {
        if cameraFacingBack {
            setFocusMode(AVCaptureDevice.FocusMode.continuousAutoFocus)
            setExposureMode(.continuousAutoExposure)
        }

        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession.addInput(captureDeviceInput)
        } catch let error as NSError {
            print(error.localizedDescription)
        }

        if #available(iOS 10.0, *) {
            let output = AVCapturePhotoOutput()
            stillImageOutputImpl = output
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
        }else{
            let output = AVCaptureStillImageOutput()
            stillImageOutputImpl = output
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
        }

       let videoOutput = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())
            captureSession.addOutput(videoOutput)
        }


        if (captureDevice?.isFlashAvailable == nil) {
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer?.frame = cameraLayer.bounds
        uptdatePreviewLayerOrientation(withLayerSize: cameraLayer.bounds.size)
        self.cameraLayer.layer.addSublayer(previewLayer!)
        captureSession.startRunning()
    }


    // MARK: ImagePicker Delegates


    // MARK: Touch to forcus
    var canFocus: Bool = true

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if (canFocus && !lockingTouch) {
            if let anyTouch: AnyObject = touches.first {
                let location = anyTouch.location(in: self.view)
                canFocus = false
                let pointOfInterest = CGPoint(x: location.y / view.bounds.height, y: 1.0 - (location.x / view.bounds.width))
                focusAtPoint(pointOfInterest)
            }

        }
    }
    

    func focusAtPoint(_ atPoint: CGPoint) -> Bool{
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()

                if device.isFocusPointOfInterestSupported {
                    //Add Focus on Point
                    device.focusMode = .autoFocus
                    device.focusPointOfInterest = atPoint

                }

                // animate
                self.canFocus = true
                device.unlockForConfiguration()
                return true
            } catch {
                // handle error
                return false
            }
        }
        return false
    }

    func setFocusMode(_ mode: AVCaptureDevice.FocusMode) -> Bool {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()

                if device.isFocusModeSupported(mode) {
                    //Add Focus on Point
                    device.focusMode = mode
                }

                device.unlockForConfiguration()
                return true
            } catch {
                // handle error
                return false
            }
        }
        return true
    }

    func setExposureMode(_ mode: AVCaptureDevice.ExposureMode) -> Bool {
        if let device = captureDevice {
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
        return true
    }

    // MARK: Process Methods
    var completionAfterPhotoCapture: ((UIImage?, NSError?) -> Void)?

//    @available(iOS 10.0, *)
    func captureImage(_ completion: ((UIImage?, NSError?) -> Void)?) {

        if (stillImageOutputImpl == nil) {
            return
        }
        var sessionQueue: DispatchQueue!
        sessionQueue = DispatchQueue(label: "Capture Session", attributes: [])
        sessionQueue.async(execute: {
            //                    self.captureDevice?.lockForConfiguration(nil)

            do {
                try self.captureDevice?.lockForConfiguration()
            } catch {
                // handle error
                return
            }
            if #available(iOS 10.0, *){
                let settingsForMonitoring = AVCapturePhotoSettings()
                settingsForMonitoring.flashMode = .auto
                settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
                settingsForMonitoring.isHighResolutionPhotoEnabled = false
                self.completionAfterPhotoCapture = completion
                self.stillImageOutput!.capturePhoto(with: settingsForMonitoring, delegate: self)
            }else{
                self.stillImageOutputV9!.captureStillImageAsynchronously(
                    from: self.stillImageOutputV9!.connection(with: .video)!,
                    completionHandler: {(imageDataSampleBuffer: CMSampleBuffer?, error: Error?) -> Void in
                        if (imageDataSampleBuffer == nil || error != nil) {
                            completion?(nil, nil)
                        } else if imageDataSampleBuffer != nil {
                            let imageData: Data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)!
                            let image = UIImage(data: imageData)
                            completion?(image, nil)
                        }
                })
            }
            self.captureDevice?.unlockForConfiguration()
        })
    }

    @IBAction func captureButtonDidTap(_ sender: UIButton) {
        if (!PermissionUtil.isCameraEnabled()) {
            PermissionUtil.checkCameraPermission(self, callback: { (dialogShown) in
                
            })
        } else if (!PermissionUtil.isPhotoLibraryEnabled()) {
            PermissionUtil.checkPhotoLibraryPermission(self, callback: { (dialogShown) in
                
            })
        } else {
            if isParameterAllInput{
                captureImpl()
            }else{
                Alertift.alert(title: nil, message: NSLocalizedString("Input height, weight, age and gender.", comment: "")).action(.default("OK")).show(on: self, completion: nil)
            }
        }
        
    }
    
    func focusOnCenterThen(successCallback: (() -> Void)?, errorCallback:(() -> Void)?){
        if (canFocus && !lockingTouch) {
            let location = cameraLayer.bounds.center
            self.canFocus = false
            let pointOfInterest = CGPoint(x: location.y / view.bounds.height, y: 1.0 - (location.x / view.bounds.width))
            if(self.focusAtPoint(pointOfInterest)){
               successCallback?()
            }else{
               errorCallback?()
            }
            
        }
    }

    func captureImpl() {
        if capturing {
            return
        }

        capturing = true
        focusOnCenterThen(successCallback: {[unowned self] in
            self.captureImage { [unowned self](image, error) -> Void in
                if (error == nil && image != nil) {
                    guard let _ = image else {
                        return
                    }
                    self.capturing = false
                    if let orientation = self.previewLayer?.connection?.videoOrientation {
                        if let normalizedImage = image?.normalized(videoOrientation: orientation) {
                            var transformedImage: UIImage? = normalizedImage
                            if let attitude = self.attitudeWhenPhotoCaptured {
                                transformedImage = self.transformedImage(image: normalizedImage, withAttitude: attitude)
                            }
                            if let transformedImage = transformedImage{
                                UIImageWriteToSavedPhotosAlbum(transformedImage, nil, nil, nil)
                                var targetImage: UIImage? = transformedImage
                                if self.shouldBlurFace{
                                    targetImage = BlurFace(image: transformedImage).blurFaces(centerOffset: self.capturingFront == true ? .zero : CGPoint(x: -transformedImage.size.width / 20, y: 0)) ?? transformedImage
                                }
                                if let _ = self.estimationParameter.frontImage {
                                    self.estimationParameter.sideImage = targetImage
                                    self.delegate?.cameraViewControllerDidFinish(viewController: self)
                                } else {
                                    self.estimationParameter.frontImage = targetImage
                                    self.capturingFront = false
                                }
                            }
                        }
                    }
                }
            }
        }) {[unowned self] in
            self.capturing = false
            Alertift.alert(title: NSLocalizedString("", comment: ""), message: NSLocalizedString("Failed to focus", comment: "")).action(.cancel(NSLocalizedString("OK", comment: ""))).show()

        }

    }
    
    func transformedImage(image: UIImage, withAttitude attitude: CMAttitude) -> UIImage? {
        let ciImage = CIImage(image: image)
        let rect = CIRectangleFeature()
        let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection")!

        perspectiveCorrection.setValue(CIVector(cgPoint: rect.topLeft),
                forKey: "inputTopLeft")
        perspectiveCorrection.setValue(CIVector(cgPoint: rect.topRight),
                forKey: "inputTopRight")
        perspectiveCorrection.setValue(CIVector(cgPoint: rect.bottomRight),
                forKey: "inputBottomRight")
        perspectiveCorrection.setValue(CIVector(cgPoint: rect.bottomLeft),
                forKey: "inputBottomLeft")
        perspectiveCorrection.setValue(ciImage,
                forKey: kCIInputImageKey)

        // Third step: Apply transformation
        let outputImage = perspectiveCorrection.outputImage
        return image
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation, size: CGSize) {

        layer.videoOrientation = orientation
        previewLayer?.frame = CGRect(origin: .zero, size: size)

    }


    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        super.viewWillTransition(to: size, with: coordinator)
        uptdatePreviewLayerOrientation(withLayerSize: size)

    }

    func uptdatePreviewLayerOrientation(withLayerSize size: CGSize) {
        if let connection = self.previewLayer?.connection {

            let currentDevice: UIDevice = UIDevice.current

            let orientation: UIDeviceOrientation = currentDevice.orientation

            let previewLayerConnection: AVCaptureConnection = connection

            if previewLayerConnection.isVideoOrientationSupported {

                if interfaceOrientation.isPortrait {
                    switch (orientation) {
                    case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait, size: size)
                        break
                    case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown, size: size)
                        break
                    default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait, size: size)
                        break
                    }
                } else {
                    switch (orientation) {
                    case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft, size: size)
                        break
                    case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight, size: size)
                        break
                    default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait, size: size)
                        break
                    }
                }
            }
        }
    }

    @IBAction func switchCameraButtonDidTap(_ sender: UIButton) {
        if (!PermissionUtil.isCameraEnabled()) {
            PermissionUtil.checkCameraPermission(self, callback: nil)
        } else {
            sender.isEnabled = false
            var nextFacingBack = captureDevice?.position == .front
            UIView.animate(
                    withDuration: 0.2,
                    animations: { () -> Void in
                        self.cameraLayer.alpha = 0.1
                    }, completion: {[unowned self] (finished: Bool) -> Void in
                self.previewLayer?.removeFromSuperlayer()
                self.stillImageOutputImpl = nil
                self.captureSession = AVCaptureSession()
                self.initializeCameraSession(nextFacingBack)
                UIView.animate(
                        withDuration: 0.2,
                        animations: { () -> Void in
                            self.cameraLayer.alpha = 1
                        },
                        completion: { (isFinished: Bool) -> Void in
                            sender.isEnabled = true
                        }
                )
            })
        }
    }

    @IBAction func timerButtonDidtap(sender: Any) {
        if (!PermissionUtil.isCameraEnabled()) {
            PermissionUtil.checkCameraPermission(self, callback: { (dialogShown) in
                
            })
        } else if (!PermissionUtil.isPhotoLibraryEnabled()) {
            PermissionUtil.checkPhotoLibraryPermission(self, callback: { (dialogShown) in
                
            })
        } else {
            startCountDownTimer()
        }
    }
    
    @IBAction func frontImageButtonDidTap(sender: Any){
        let configuration = ImageViewerConfiguration { config in
            config.imageView = frontImageButton.imageView
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        DispatchQueue.main.async { [weak self] in
            self?.present(imageViewerController, animated: true)
        }
    }

    func startCountDownTimer() {
        countLabel.isHidden = false
        countLabel.alpha = 0
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.countLabel.alpha = 1
        }) { [weak self] finished in
            if finished {
                self?.startCapturingTimer()
            }
        }
    }

    func countDownTimeCount(count: Int) {
        countLabel.text = "\(count)"
        if count == 0 {
            countLabel.isHidden = true
            if #available(iOS 10.0, *){
                captureImpl()
            }else{
                
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.countDownTimeCount(count: count - 1)
            }
        }
    }

    func startCapturingTimer() {
        countDownTimeCount(count: 10)
    }

    @IBAction func closeButtonDidTap(sender: Any) {
        Alertift.actionSheet(title: NSLocalizedString("", comment: ""), message: NSLocalizedString("Do you want to discard changes?", comment: "")).action(.cancel(NSLocalizedString("Cancel", comment: "")))
                .action(.destructive(NSLocalizedString("Discard", comment: ""))) { [weak self] _, _ in
                    self?.capturingFront = true
                }.show(on: self, completion: nil)
    }


    @IBAction func importPhotoButtonDidTap(sender: Any) {
        if isParameterAllInput{
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }else{
            Alertift.alert(title: nil, message: NSLocalizedString("Input height, weight, age and gender.", comment: ""))
                .action(.default("OK"))
                .show(on: self, completion: nil)
        }
    }
    
    var isParameterAllInput: Bool{
        get{
            return estimationParameter.age > 0 && estimationParameter.heightInCm > 0 && estimationParameter.weightInKg > 0
        }
    }


   

    func reloadParameters(){
        if estimationParameter.age > 0{
            ageValueLabel.text = "\(estimationParameter.age)"
        }else{
            ageValueLabel.text = "-"
        }
        if estimationParameter.heightInCm > 0{
            heightValueLabel.text = String(format: "%.1f", estimationParameter.heightInCm)
            heightUnitLabel.text = "cm"
        }else{
            heightValueLabel.text = "-"
            heightUnitLabel.text = ""
        }
        if estimationParameter.weightInKg > 0{
            weightValueLabel.text = String(format: "%.1f", estimationParameter.weightInKg)
            weightUnitLabel.text = "kg"
        }else{
            weightValueLabel.text = "-"
            weightUnitLabel.text = ""
        }
    }
}


extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    

    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: { [unowned self] () -> Void in
            var data: Data!
            if #available(iOS 11.0, *){
                data = try! Data(contentsOf: info[.imageURL] as! URL)
            }else{
                data = try! Data(contentsOf: info[.referenceURL] as! URL)
            }

            if let transformedImage = UIImage(data: data){
                var targetImage: UIImage? = transformedImage
                if self.shouldBlurFace{
                    targetImage = BlurFace(image: transformedImage).blurFaces(centerOffset: self.capturingFront == true ? .zero : CGPoint(x: -transformedImage.size.width / 20, y: 0)) ?? transformedImage
                }
                if let _ = self.estimationParameter.frontImage {
                    self.estimationParameter.sideImage = targetImage
                    self.delegate?.cameraViewControllerDidFinish(viewController: self)
                } else {
                    self.estimationParameter.frontImage = targetImage
                    self.capturingFront = false
                }
            }
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    @available(iOS 11.0, *)
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        attitudeWhenPhotoCaptured = currentAttitude
        if let cgImage = photo.cgImageRepresentation()?.takeUnretainedValue() {
            let image = UIImage(cgImage: cgImage)//, scale: 1.0, orientation: .right)
            self.completionAfterPhotoCapture?(image, nil)
        } else {
            self.completionAfterPhotoCapture?(nil, NSError())
        }
    }
    
    @available(iOS 10.0, *)
    public func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        
    }

}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if showingLoading {
            showingLoading = false
            DispatchQueue.main.async {
                SwiftSpinner.hide()
            }
        }
    }
}

extension CameraViewController {
    func startListeningGyro() {
        let updateInterval: TimeInterval = 0.1
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = updateInterval

            motionManager.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryZVertical, to: OperationQueue.main, withHandler: { [weak self] (motion, error) -> Void in
                if let motion = motion {
                    self?.currentAttitude = motion.attitude
                    self?.currentGravity = motion.gravity
                    DispatchQueue.main.async { [weak self] in
                        self?.updateGyroIndicator()
                    }
                }
            })
        }
    }

    func stopListeningGyro() {
        motionManager.stopDeviceMotionUpdates()
    }

    func updateGyroIndicator() {

        var capturable = false
        if let attitude = currentAttitude {
            let q = attitude.quaternion
            let qPitch = atan2(2 * (q.x * q.w + q.y * q.z), 1 - 2 * q.x * q.x - 2 * q.z * q.z)

            let diff = Double.pi / 2 - qPitch
            let scale = Double.pi / 6
            let scaledDiff = max(-1, min(diff / scale, 1))
            let translationY = 100 * scaledDiff

            angleView.translatesAutoresizingMaskIntoConstraints = true
            angleView.center = CGPoint(x: angleView.center.x, y: angleView.center.y + CGFloat(translationY - previousTranslationY))
            previousTranslationY = translationY
            if abs(diff) < 3.0 / 180.0 * Double.pi {
                angleView.backgroundColor = UIColor.BodyBank.Gradient.begin
                capturable = true
            } else {
                angleView.backgroundColor = .white
                capturable = false
            }


        }

        if let gravity = currentGravity {
            var angle = CGFloat(atan2(gravity.y, gravity.x))
            if (angle < 0 && angle > -CGFloat.pi) {
                angle += CGFloat.pi / 2
            } else if (angle >= CGFloat.pi / 2 && angle < CGFloat.pi) {
                angle -= 3 * CGFloat.pi / 2
            } else {
                angle += CGFloat.pi / 2
            }
            tiltView.transform = CGAffineTransform(rotationAngle: angle)
            if abs(angle) < CGFloat(3.0 / 180.0 * Double.pi) {
                capturable = capturable && true
                tiltView.backgroundColor = UIColor.BodyBank.Gradient.begin
            } else {
                capturable = false
                tiltView.backgroundColor = .white
            }
        }
        captureButton.isEnabled = capturable
    }
}

