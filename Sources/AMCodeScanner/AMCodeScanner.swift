//
//  AMCodeScanner.swift
//
//  Created with 💪 by Alessandro Manilii.
//  Copyright © 2021 Alessandro Manilii. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - PPBCodeScannerDelegate
public protocol AMCodeScannerDelegate: AnyObject {
    func codeScannerDidReadCode(_ code: String)
    func codeScannerdidFailToReadWithError(_ error: AMCodeScanner.CodeError)
}

public class AMCodeScanner: NSObject {
    
    // MARK: - CodeError
    /// All the possible types of errors that could occur
    public enum CodeError {
        case generic
        case captureDevice
        case captureSession
        case cameraPermissionNotGranted
    }
    
    // MARK: - Properties
    private var cameraView: UIView
    private var areaOfInterest: UIView
    private var typesToScan: [AVMetadataObject.ObjectType]
    private weak var delegate: AMCodeScannerDelegate?
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private let maskLayer = CAShapeLayer()
    private let maskColor: UIColor
    private let aoiCornerRadius: CGFloat

    // MARK: - Lifecycles
    /// Initialization of the class
    /// - Parameters:
    ///   - cameraView: the main view where the camera is shown
    ///   - areaOfInterest: the small area where it's needed to read the code, if nil it's the whole cameraView
    ///   - maskColor: the color of the area ouside the areaOfInterest
    ///   - aoiCornerRadius: the corner radius of the areaOfInterest area
    ///   - typesToScan: the list of the types of scanner needed to read (ie.: QR, code39, dataMatrix, etc...)
    ///   - delegate: the protocol delegate
    public init(cameraView: UIView,
         areaOfInterest: UIView? = nil,
         maskColor: UIColor = .clear,
         aoiCornerRadius: CGFloat = 0,
         typesToScan: [AVMetadataObject.ObjectType],
         delegate: AMCodeScannerDelegate) {
        self.cameraView = cameraView
        self.areaOfInterest = areaOfInterest ?? cameraView
        self.maskColor = maskColor
        self.aoiCornerRadius = aoiCornerRadius
        self.typesToScan = typesToScan
        self.delegate = delegate
        
        super.init()
        // Start to listen for orentation changes
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        self.setupVideoPreviewLayer()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIDevice.orientationDidChangeNotification,
                                                  object: nil)
    }
    
    // MARK: - Public functions
    /// Start the scanning sequence
    public func startScanning() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didChangeCaptureInputPortFormatDescription(notification:)),
            name: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange,
            object: nil)
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            startRunningCaptureSession()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    self.startRunningCaptureSession()
                } else {
                    self.delegate?.codeScannerdidFailToReadWithError(.cameraPermissionNotGranted)
                }
            })
        }
        
       configureAreaOfInterest()
    }
    
    /// Stop the scanning sequence
    public func stopScanning() {
        if self.captureSession?.isRunning == true {
            self.captureSession?.stopRunning()
            
            guard videoPreviewLayer != nil else {
                delegate?.codeScannerdidFailToReadWithError(.generic)
                return
            }            
        }
    }
}

// MARK: - Private
private extension AMCodeScanner {
    
    @objc func didChangeCaptureInputPortFormatDescription(notification: NSNotification) {
        configureAreaOfInterest()
    }
    
    func startRunningCaptureSession() {
        if self.captureSession?.isRunning == false {
            self.captureSession?.startRunning()
        }
    }
    
    /// Configure the main view in order to show the Camera Preview
    func setupVideoPreviewLayer() {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            guard let gCaptureDevice = captureDevice else {
                delegate?.codeScannerdidFailToReadWithError(.captureDevice)
                return
            }
            
            // Configuration
            let input = try AVCaptureDeviceInput(device: gCaptureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // Code listener... and supported code list
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = typesToScan
            
            guard let gCaptureSession = captureSession else {
                delegate?.codeScannerdidFailToReadWithError(.captureSession)
                return
            }
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: gCaptureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            guard let gVideoPreviewLayer = videoPreviewLayer else {
                delegate?.codeScannerdidFailToReadWithError(.generic)
                return
            }
            
            self.cameraView.layer.addSublayer(gVideoPreviewLayer)
            
            // Configure layer
            let layerRect = self.cameraView.layer.bounds
            self.videoPreviewLayer?.frame = layerRect
            self.videoPreviewLayer?.position = CGPoint(x: layerRect.midX, y: layerRect.midY)
            
            // Start video capture.
            startScanning()
        } catch {
            var error = CodeError.generic
            if AVCaptureDevice.authorizationStatus(for: .video) !=  .authorized {
                error = .cameraPermissionNotGranted
            }
            delegate?.codeScannerdidFailToReadWithError(error)
            return
        }
    }
    
    /// Configuration of the Area Of Interest. It's the area red by the scanner reader. Outside this area the codes will be not read.
    func configureAreaOfInterest() {
        if let metadataOutput = captureSession?.outputs.last as? AVCaptureMetadataOutput,
            let rect = videoPreviewLayer?.metadataOutputRectConverted(fromLayerRect: areaOfInterest.frame) {
            metadataOutput.rectOfInterest = rect
        }
        
        configureAreaOfInterestLayer()
    }
    
    /// Perform the configuration of the area of interest
    func configureAreaOfInterestLayer() {
        maskLayer.removeFromSuperlayer()
        let updFrame = cameraView.convert(areaOfInterest.frame, from: areaOfInterest.superview)
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0,
                                                    width: cameraView.bounds.size.width,
                                                    height: cameraView.bounds.size.height),
                                cornerRadius: 0)
        let aoiPath = UIBezierPath(roundedRect: updFrame, cornerRadius: aoiCornerRadius)
        path.append(aoiPath)
        path.usesEvenOddFillRule = true

        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = maskColor.cgColor
        cameraView.layer.addSublayer(maskLayer)
    }
}

// MARK: - Orientation Changes
private extension AMCodeScanner {
    
    /// React to Device otientation changes
    @objc func orientationChanged() {
        updateLayerFrames()
    }
    
    /// Update sizes and positions of the layers
    private func updateLayerFrames() {
        // Configure layer
        let layerRect = self.cameraView.layer.bounds
        self.videoPreviewLayer?.frame = layerRect
        self.videoPreviewLayer?.position = CGPoint(x: layerRect.midX, y: layerRect.midY)
        
        videoPreviewLayer?.connection?.videoOrientation = getDeviceOrientation()
        
        configureAreaOfInterest()
    }
    
    /// Return the actual Device orientation as AVCaptureVideoOrientation Enum
    /// - Returns: the actual orientation itself
    private func getDeviceOrientation() -> AVCaptureVideoOrientation {
        let device = UIDevice.current
        if device.isGeneratingDeviceOrientationNotifications {
                device.beginGeneratingDeviceOrientationNotifications()
            
                switch device.orientation {
                case .portrait           : return .portrait
                case .portraitUpsideDown : return .portraitUpsideDown
                case .landscapeRight     : return .landscapeLeft
                case .landscapeLeft      : return .landscapeRight
                default                  : return .portrait
                }
            } else {
                return .portrait
            }
        }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension AMCodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Get the metadata object.
        if let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            // Shake baby shake...
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            self.delegate?.codeScannerDidReadCode(metadataObj.stringValue ?? "---")
        }
    }
}
