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

//BodyBankEnterprise
open class CameraViewController: UIViewController {
    
    @IBOutlet open weak var cameraLayer: UIView!
    @IBOutlet weak var guideImageView: UIImageView!
    
    @IBOutlet weak var grayoutView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var frontImageButton: UIButton!
    @IBOutlet weak var timerButton: UIButton!
    
    @IBOutlet weak var countLabel: UILabel!
    
    // OldView
    @IBOutlet weak var heightValueLabel: UILabel!  // 160
    @IBOutlet weak var heightUnitLabel: UILabel!   // cm
    @IBOutlet weak var weightValueLabel: UILabel!  // 54
    @IBOutlet weak var weightUnitLabel: UILabel!   // kg
    @IBOutlet weak var ageValueLabel: UILabel!     // 30
    
    @IBOutlet weak var genderSegmented: UISegmentedControl!
    @IBOutlet weak var warningLabel: UILabel!
    
    // Gyro's View
    @IBOutlet weak var angleView: UIView!
    @IBOutlet weak var tiltView: UIView!
    @IBOutlet weak var slideBarView: UIView!
    
    
    open weak var delegate: CameraViewControllerDelegate?
    open var shouldBlurFace = false
    
    open var estimationParameter = EstimationParameter()
    
    // Camera
    var captureSession = AVCaptureSession()
    var captureDevice: AVCaptureDevice?     // Cront or Back
    var stillImageOutputImpl: NSObject?     // Camera iOS 9 or 10over
    
    private var _observers = [NSKeyValueObservation]()
    
    var stillImageOutput: AVCapturePhotoOutput?{
        get{
            return stillImageOutputImpl as? AVCapturePhotoOutput
        }
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var imageCaptured: UIImage?
    
    var showingLoading = false
    var lockingTouch: Bool = false
    var cameraFacingBack: Bool = false
    var capturing: Bool = false
    
    // Gyro's
    let motionManager = CMMotionManager()
    var currentAttitude: CMAttitude?
    // over iOS11
    var attitudeWhenPhotoCaptured: CMAttitude?
    var currentGravity: CMAcceleration?
    //    var previousTranslationY = 0.0
    
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
    var timerStarted = false{
        didSet{
            timerButton.isEnabled = !timerStarted
        }
    }
    
    var canFocus: Bool = true
    
    // MARK: Process Methods
    var completionAfterPhotoCapture: ((UIImage?, NSError?) -> Void)?
    
    var isParameterAllInput: Bool{
        get{
            return estimationParameter.age > 0 &&
                estimationParameter.heightInCm > 0 &&
                estimationParameter.weightInKg > 0
        }
    }
    
    // MARK: View cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        frontImageButton.imageView?.contentMode = .scaleAspectFill
        reloadParameters()
        
        title = NSLocalizedString("Stand inside the outline", comment: "")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        buildGradientLayer()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SwiftSpinner.show(NSLocalizedString("Please Wait...", comment: ""))
        showingLoading = true
        
        PermissionUtil.checkPhotoLibraryPermission(self, callback: { [unowned self] (dialogShown) in
            PermissionUtil.checkCameraPermission(self, callback: { (dialogShown) in
                self.initializeCapture()
                self.setupAfterViewAppear()
            })
        })
        startListeningGyro()
    }
    
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        lockingTouch = true
        stopListeningGyro()
        timerStarted = false
        
        for observer in _observers {
            observer.invalidate()
        }
        
        _observers.removeAll()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraLayer.alpha = 0
        
    }
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier{
        case "show_height_picker":
            if let vc = segue.destination as? HeightPickerViewController{
                vc.setInitialValue(valueString: heightValueLabel.text!,
                                   unit: heightUnitLabel.text!)
            }
        case "show_weight_picker":
            if let vc = segue.destination as? WeightPickerViewController{
                vc.setInitialValue(valueString: weightValueLabel.text!,
                                   unit: weightUnitLabel.text!)
            }
            
        case "show_age_picker":
            if let vc = segue.destination as? AgePickerViewController{
                vc.setInitialValue(valueString: ageValueLabel.text!,
                                   unit: "")
            }
        default:
            break
        }
    }
    
    func buildGradientLayer(){
        if navigationBarBackgroundImage == nil{
            navigationBarBackgroundImage =  navigationController?.navigationBar.setUpBodyBankGradient()
        }
    }
    
    func setupAfterViewAppear() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
        lockingTouch = false
        if cameraLayer.alpha == 0 {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.cameraLayer.alpha = 1;
            })
        }
        
    }
    
    
    // MARK: - IBAction
    
    @IBAction func genderControlValueDidChange(sender: UISegmentedControl){
        switch sender.selectedSegmentIndex {
        case 0:
            estimationParameter.gender = .male
        default:
            estimationParameter.gender = .female
        }
    }
    
    @IBAction func cancelButtonDidTap(sender: Any){
        if capturingFront{
            closeButtonDidTap(sender: sender)
        }else{
            delegate?.cameraViewControllerDidCancel(viewController: self)
        }
    }
    
    @IBAction func helpButtonTapped(_ sender: Any) {
    }
    
    // MARK: Initial Methods
    func initializeCapture() {
        previewLayer?.removeFromSuperlayer()
        stillImageOutputImpl = nil
        captureSession = AVCaptureSession()
        initializeCameraSession(captureDevice?.position != .front)
        setupFocusObserver()
    }
    
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
    
    func setupFocusObserver() {
        guard let captureDevice = self.captureDevice else { return }
        
        _observers.append(captureDevice.observe(\.isAdjustingFocus, options: [.old, .new]) { [unowned self] _, change in
            guard let isAdjusting = change.newValue else { return }
            
            if !isAdjusting && self.capturing {
                // capture when auto-focus finished
                self.captureImage()
            }
        })
    }
    
    
    
    // MARK: ImagePicker Delegates
    
    
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
    
    func optimizeAndSetImage2EstimationParams(_ image: UIImage?, _ error: NSError?) -> Void {
        
        guard let image = image else { return }
        if let _ = error { return }
        
        self.capturing = false
        self.timerStarted = false
        
        guard let orientation = previewLayer?.connection?.videoOrientation else { return }
        
        let normalizedImage = image.normalized(videoOrientation: orientation)
        var transformedImage: UIImage? = normalizedImage
        if let attitude = attitudeWhenPhotoCaptured {
            transformedImage = self.transformedImage(image: normalizedImage, withAttitude: attitude)
        }
        
        if let transformedImage = transformedImage {
            UIImageWriteToSavedPhotosAlbum(transformedImage, nil, nil, nil)
            var targetImage: UIImage? = transformedImage
            if shouldBlurFace {
                targetImage = BlurFace(image: transformedImage).blurFaces(centerOffset: capturingFront == true ? .zero : CGPoint(x: -transformedImage.size.width / 20, y: 0)) ?? transformedImage
            }
            if let _ = estimationParameter.frontImage {
                estimationParameter.sideImage = targetImage
                
                delegate?.cameraViewControllerDidFinish(viewController: self)
            } else {
                self.estimationParameter.frontImage = targetImage
                self.capturingFront = false
            }
        }
    }
    
    
    /// cameraView Open
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func captureButtonDidTap(_ sender: UIButton) {
        
        // check CameraParmission
        if (!PermissionUtil.isCameraEnabled()) {
            PermissionUtil.checkCameraPermission(self, callback: { (dialogShown) in
            })
            return
        }
        
        // check PhotoParmission
        if (!PermissionUtil.isPhotoLibraryEnabled()) {
            PermissionUtil.checkPhotoLibraryPermission(self, callback: { (dialogShown) in
            })
            return
        }
        
        if isParameterAllInput {
            Alertift
                .alert(title: nil,
                       message: NSLocalizedString("Input height, weight, age and gender.", comment: ""))
                .action(.default("OK"))
                .show(on: self, completion: nil)
            return
        }
        
        startCapturing()
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
    
    
    /// <#Description#>
    /// why need tranceform?
    /// - Parameters:
    ///   - image: <#image description#>
    ///   - attitude: <#attitude description#>
    /// - Returns: <#return value description#>
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
        
        // TODO:これ使わないとなんか変更されないはず？？？？
        //        let outputImage = perspectiveCorrection.outputImage
        return image
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func updatePreviewLayer(layer: AVCaptureConnection,
                                    orientation: AVCaptureVideoOrientation,
                                    size: CGSize) {
        layer.videoOrientation = orientation
        previewLayer?.frame = CGRect(origin: .zero, size: size)
        
    }
    
    
    open override func viewWillTransition(to size: CGSize,
                                          with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updatePreviewLayerOrientation(withLayerSize: size)
        
    }
    
    func updatePreviewLayerOrientation(withLayerSize size: CGSize) {
        if let connection = self.previewLayer?.connection {
            
            let currentDevice: UIDevice = UIDevice.current
            
            let orientation: UIDeviceOrientation = currentDevice.orientation
            
            let previewLayerConnection: AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                
                if UIApplication.shared.statusBarOrientation.isPortrait {
                    switch (orientation) {
                    case .portrait:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait, size: size)
                    case .portraitUpsideDown:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown, size: size)
                    default:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait, size: size)
                    }
                } else {
                    switch (orientation) {
                    case .landscapeRight:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft, size: size)
                    case .landscapeLeft:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight, size: size)
                    default:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait, size: size)
                    }
                }
            }
        }
    }
    
    @IBAction func switchCameraButtonDidTap(_ sender: UIButton) {
        if !PermissionUtil.isCameraEnabled() {
            PermissionUtil.checkCameraPermission(self, callback: nil)
            return
        }
        
        sender.isEnabled = false
        let nextFacingBack = captureDevice?.position == .front
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
    
    @IBAction func timerButtonDidtap(sender: Any) {
        if (!PermissionUtil.isCameraEnabled()) {
            PermissionUtil.checkCameraPermission(self, callback: { (dialogShown) in
                
            })
            return
        }
        
        if (!PermissionUtil.isPhotoLibraryEnabled()) {
            PermissionUtil.checkPhotoLibraryPermission(self, callback: { (dialogShown) in
                
            })
            return
        }
        
        startCountDownTimer()
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
        if timerStarted { return }
        
        if isParameterAllInput {
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
    
    @IBAction func closeButtonDidTap(sender: Any) {
        Alertift
            .actionSheet(title: NSLocalizedString("", comment: ""),
                         message: NSLocalizedString("Do you want to discard changes?", comment: ""))
            .action(.cancel(NSLocalizedString("Cancel", comment: "")))
            .action(.destructive(NSLocalizedString("Discard", comment: ""))) { [weak self] _, _ in
                self?.capturingFront = true
            }
            .show(on: self, completion: nil)
    }
    
    
    @IBAction func importPhotoButtonDidTap(sender: Any) {
        if isParameterAllInput {
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
    
    open func imagePickerController(_ picker: UIImagePickerController,
                                    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
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
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
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

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
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

extension CameraViewController {
    
    func startListeningGyro() {
        if !motionManager.isDeviceMotionAvailable { return }
        
        motionManager.deviceMotionUpdateInterval = 1/60
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical,
                                               to: .main,
                                               withHandler: { [weak self] (motion, error) -> Void in
                                                guard
                                                    let self = self,
                                                    let motion = motion
                                                    else { return }
                                                
                                                self.currentAttitude = motion.attitude
                                                self.currentGravity = motion.gravity
                                                self.updateGyroIndicator()
        })
    }
    
    func stopListeningGyro() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    func updateGyroIndicator() {
        guard let gravity = currentGravity else { return } // Handle error!
        
        var capturable = false
        let slideBarTopY = slideBarView.frame.maxY
        let slideBarMidY = slideBarView.frame.midY
        let slideBarHalfHeight = slideBarTopY - slideBarMidY
        let ballCenterX = angleView.frame.midX
        let inversedGravityZ = gravity.z * -1
        
        // pitchIndicator
        angleView.center = CGPoint(x: ballCenterX, y: slideBarMidY + slideBarHalfHeight * CGFloat(inversedGravityZ))
        
        if fabs(inversedGravityZ * 90) < 3.0 {
            angleView.backgroundColor = UIColor.BodyBank.Gradient.begin
            capturable = true
        } else {
            angleView.backgroundColor = .white
            capturable = false
        }
        
        // tiltIndicator
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
        
        // enable capture button
        captureButton.isEnabled = capturable
        // ADD:
        if !timerStarted {
            timerButton.isEnabled = capturable
        }
    }
    
    open func reset(){
        capturingFront = true
        estimationParameter.clear()
        reloadParameters()
    }
}

