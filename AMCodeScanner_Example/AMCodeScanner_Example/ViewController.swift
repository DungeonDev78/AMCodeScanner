//
//  ViewController.swift
//  AMCodeScanner_Example
//
//  Created by Alessandro Manilii on 08/03/21.
//

import UIKit
import AMCodeScanner

class ViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak private var viewVideoPreview: UIView!
    @IBOutlet weak private var viewAreaOfInterest: UIView!
    var scanner: AMCodeScanner?
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scanner = AMCodeScanner(cameraView: viewVideoPreview,
                                areaOfInterest: viewAreaOfInterest,
                                maskColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5),
                                aoiCornerRadius: 10,
                                typesToScan: [.qr],
                                delegate: self)
    }
}

// MARK: - AMCodeScannerDelegate
extension ViewController: AMCodeScannerDelegate {
    
    func codeScannerDidReadCode(_ code: String) {
        print(code)
        
        scanner?.stopScanning()
        
    
        let alert = UIAlertController(title: "AM Code reader",
                                      message: code,
                                      preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: UIAlertAction.Style.default,
                                      handler: { [weak self] _ in
                                        self?.scanner?.startScanning()
                                      }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func codeScannerdidFailToReadWithError(_ error: AMCodeScanner.CodeError) {
        print(error)
    }
}

