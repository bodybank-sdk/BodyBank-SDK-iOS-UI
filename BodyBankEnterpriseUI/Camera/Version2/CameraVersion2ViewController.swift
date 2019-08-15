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
import Reachability

public protocol CameraVersion2ViewControllerDelegate: class{
    func cameraViewControllerDidCancel(viewController: CameraVersion2ViewController)
    func cameraViewControllerDidFinish(viewController: CameraVersion2ViewController)
    func cameraViewControllerDidFinishDebug(viewController: CameraVersion2ViewController)

}

public extension CameraVersion2ViewControllerDelegate {
    func cameraViewControllerDidFinishDebug(viewController: CameraVersion2ViewController) {
    }
}

open class CameraVersion2ViewController: UIViewController {
    
    @IBOutlet weak var frontImageEraceButton: UIButton!
    @IBOutlet open weak var cameraLayer: UIView!
    @IBOutlet weak var guideImageView: UIImageView!
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var frontImageButton: UIButton!
    @IBOutlet weak var timerButton: UIButton!
    
    @IBOutlet weak var countLabel: UILabel!
    
    // NewView
    @IBOutlet weak var heightTextField: UITextField!        // 160
    @IBOutlet weak var heightLabel: UILabel!                // cm
    @IBOutlet weak var weightTextField: UITextField!        // 54
    @IBOutlet weak var weightLabel: UILabel!                // kg
    @IBOutlet weak var ageTextField: UITextField!           // 30
    @IBOutlet weak var genderSegmented: UISegmentedControl!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var numberTextField: UITextField!        //extrafield
    
    // Gyro's View    
    @IBOutlet weak var angleView: UIView!
    @IBOutlet weak var tiltView: UIView!
    @IBOutlet weak var slideBarView: UIView!
    
    
    open weak var delegate: CameraVersion2ViewControllerDelegate?
    open var shouldBlurFace = false
    
    open var estimationParameter = EstimationParameter()
    
    // Camera
    var captureSession = AVCaptureSession()
    var captureDevice: AVCaptureDevice?     // Cront or Back
    var stillImageOutputImpl: NSObject?     // Camera iOS 9 or 10over
    
    var chaptureImageChecker = false        // ２連続写真が撮られる処理のガード
    
    @IBOutlet weak var versionLabel: UILabel!
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
    
    var isDebug = false
    
    var capturingFront = true {
        didSet {
            if capturingFront {
                if let bundle = BodyBankEnterprise.CameraUI.bundle{
                    guideImageView.image = UIImage(named: "front", in: bundle, compatibleWith: nil)
                }
                frontImageEraceButton.isHidden = true
                frontImageButton.isHidden = true
                estimationParameter.frontImage = nil
                frontImageButton.setImage(nil, for: .normal)
            } else {
                if let bundle = BodyBankEnterprise.CameraUI.bundle{
                    guideImageView.image = UIImage(named: "side", in: bundle, compatibleWith: nil)
                }
                frontImageEraceButton.isHidden = false
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
    
    let reachability = Reachability()!
    
    
    
    // MARK:- View Lifecycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        frontImageButton.imageView?.contentMode = .scaleAspectFill
        
        statusInit()
        statusLoad()
        
        title = NSLocalizedString("Stand inside the outline", comment: "")
        
        createToolber()
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        versionLabel.text = "v:\(version)"
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged(note:)),
                                               name: .reachabilityChanged,
                                               object: reachability)
        do {
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        buildGradientLayer()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        print("[camera][viewDidAppear]")
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
        
        if isDebug {
            numberTextField.isHidden = false
        }
    }
    
    
    open override func viewWillDisappear(_ animated: Bool) {
        print("[camera][viewWillDisappear]")
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        lockingTouch = true
        stopListeningGyro()
        timerStarted = false
        
        removeKVO()
        
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraLayer.alpha = 0
        
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
    
    
    func removeKVO(){
        for observer in _observers {
            observer.invalidate()
        }
        _observers.removeAll()
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

    
    @IBAction func helpButtonTapped(_ sender: Any) {
//        carouselModal?.show(self)
    }
    
    /// cameraView Open
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func captureButtonDidTap(_ sender: UIButton) {
        
        // check CameraParmission
        if !PermissionUtil.isCameraEnabled() {
            PermissionUtil.checkCameraPermission(self, callback: { (dialogShown) in
            })
            return
        }
        
        // check PhotoParmission
        if !PermissionUtil.isPhotoLibraryEnabled() {
            PermissionUtil.checkPhotoLibraryPermission(self, callback: { (dialogShown) in
            })
            return
        }
        
        // check InputParameter
        if !setupEstimationParameter() {
            Alertift
                .alert(title: nil,
                       message: NSLocalizedString("Input height, weight, age and gender.", comment: ""))
                .action(.default("OK"))
                .show(on: self, completion: nil)
            return
        }
        
        startCapturing()
    }
    
    @IBAction func timerButtonDidtap(sender: Any) {
        if !PermissionUtil.isCameraEnabled() {
            PermissionUtil.checkCameraPermission(self, callback: { (dialogShown) in
                
            })
            return
        }
        
        if !PermissionUtil.isPhotoLibraryEnabled() {
            PermissionUtil.checkPhotoLibraryPermission(self, callback: { (dialogShown) in
                
            })
            return
        }
        
        startCountDownTimer()
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
        }, completion: {[weak self] (finished: Bool) -> Void in
            guard let self = self else { return }
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
    

    
    @IBAction func frontImageButtonDidTap(sender: Any){
        let configuration = ImageViewerConfiguration { config in
            config.imageView = frontImageButton.imageView
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        DispatchQueue.main.async { [weak self] in
            self?.present(imageViewerController, animated: true)
        }
    }
    
    @IBAction func importPhotoButtonDidTap(sender: Any) {
        if setupEstimationParameter() {
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
    
    @IBAction func debugPictureUpload(_ sender: Any) {
        let _ = setupEstimationParameter()
        delegate?.cameraViewControllerDidFinishDebug(viewController: self)

    }
    
    @IBAction func typeButtonDidTap(_ sender: Any) {
        guard let btn = sender as? UIButton else { return }
        
        switch btn.titleLabel?.text {
            // ラベルを設定する
            
        case "Human":
            btn.setTitle("Mannequin", for: .normal)
            estimationParameter.race = .Mannequin
        default:
            btn.setTitle("Human", for: .normal)
            estimationParameter.race = .Human
        }
    }

    @IBAction func closeFrontButton(_ sender: Any) {
        self.capturingFront = true
    }
    
    @IBAction func helpButtonDidTouch(_ sender: Any) {
    }
    

    // MARK: - Initial Methods
    func setupFocusObserver() {
        
        guard let captureDevice = self.captureDevice else { return }
        print("[camera][setupFocusObserver]")
        
        removeKVO()
        
        _observers.append(captureDevice.observe(\.isAdjustingFocus, options: [.old, .new]) { [weak self] _, change in
            guard let self = self else { return }
            guard let isAdjusting = change.newValue else { return }
            
            
            if !isAdjusting && self.capturing {
                print("[camera][setupFocusObserver][captureImage]")
                // capture when auto-focus finished
                self.captureImage()
            }
        })
    }
    
    
    
    
    /// 画像を
    ///
    /// - Parameters:
    ///   - image: <#image description#>
    ///   - error: <#error description#>
    func optimizeAndSetImage2EstimationParams(_ image: UIImage?, _ error: NSError?) -> Void {
        print("[camera]:\(String(describing: image))")
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
            //写真を保存する
            UIImageWriteToSavedPhotosAlbum(transformedImage, nil, nil, nil)
            var targetImage: UIImage? = transformedImage
            
            // 顔にモザイクを掛ける
            if shouldBlurFace {
                let size = capturingFront == true ? .zero : CGPoint(x: -transformedImage.size.width / 20, y: 0)
                targetImage = BlurFace(image: transformedImage).blurFaces(centerOffset: size) ?? transformedImage
            }
            
            //
            if isDebug {
                let gender:String = {
                    switch genderSegmented.selectedSegmentIndex {
                    case 0:
                        return "Man"
                    case 1:
                        return "Woman"
                    default:
                        return "?"
                    }
                }()
                
                let str = """
                No.\(numberTextField.text ?? "none")
                H.\(heightTextField.text ?? "none" ): \(heightLabel.text ?? "none" )
                W.\(weightTextField.text ?? "none" ): \(weightLabel.text ?? "none" )
                A.\(ageTextField.text ?? "none")
                G.\(gender)
                """
                // テキストを書き込む
                if let image = transformedImage.drawText(text: str, drawRect: CGRect(x: 0, y: 0, width: transformedImage.size.width/5, height: image.size.height/5)) {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            }

            
            if let _ = estimationParameter.frontImage {
                estimationParameter.sideImage = targetImage
                
                statusSave()
                delegate?.cameraViewControllerDidFinish(viewController: self)
            } else {
                self.estimationParameter.frontImage = targetImage
                self.capturingFront = false
            }
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
    
}


extension CameraVersion2ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    open func imagePickerController(_ picker: UIImagePickerController,
                                    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: { [weak self] () -> Void in
            guard let self = self else { return }
            var data: Data!
            if #available(iOS 11.0, *){
                data = try! Data(contentsOf: info[.imageURL] as! URL)
            }else{
                data = try! Data(contentsOf: info[.referenceURL] as! URL)
            }
            
            if let transformedImage = UIImage(data: data){
                var targetImage: UIImage? = transformedImage
                if self.shouldBlurFace{
                    let size = self.capturingFront == true ? .zero : CGPoint(x: -transformedImage.size.width / 20, y: 0)
                    targetImage = BlurFace(image: transformedImage).blurFaces(centerOffset: size) ?? transformedImage
                }
                if let _ = self.estimationParameter.frontImage {
                    self.estimationParameter.sideImage = targetImage
                    
                    self.statusSave()
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


extension CameraVersion2ViewController {
    
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
            slideBarView.backgroundColor = UIColor.BodyBank.Gradient.begin
            capturable = true
        } else {
            angleView.backgroundColor = .white
            slideBarView.backgroundColor = .white
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
    }
}

// MARK: - Reachability
extension CameraVersion2ViewController {
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            warningLabel.isHidden = true
        case .cellular:
            warningLabel.isHidden = true
        case .none:
            warningLabel.isHidden = false
        }
    }
}

