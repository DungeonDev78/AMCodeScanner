# AMCodeScanner
A small and configurable Code Scanner for iOS

![Image description](https://github.com/DungeonDev78/AMCodeScanner/blob/main/Images/img001.jpg)

## Installation
Requirements
.iOS(.v10)

#### Swift Package Manager 
1. In Xcode, open your project and navigate to File → Swift Packages → Add Package Dependency.
2. Paste the repository URL (https://github.com/DungeonDev78/AMCodeScanner.git) and click Next.
3. For Rules, select version.
4. Click Finish.

#### Swift Package
```swift
.package(url: "https://github.com/DungeonDev78/AMCodeScanner.git", .upToNextMajor(from: "1.0.0"))
```


## Usage

Import AMCodeScanner package to your controller
```swift
import AMCodeScanner
```

Add the *Privacy - Camera Usage Description* in your *Info.plist*

In your ViewController (or in its Storyboard) add two UIView, one for the camera preview and a second one, that is optional, for the area of interest where you should search for the code to scan.

Add the scanner property:
```swift
var scanner: AMCodeScanner?
```

In viewWillAppear init the code reader:
```swift
scanner = AMCodeScanner(
    cameraView: cameraView,
    areaOfInterest: focusView,
    maskColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5),
    aoiCornerRadius: 10,
    typesToScan: [.qr, .code128, .dataMatrix],
    completion: { result in
        switch result {
        case .success(let code):
            print("Code scaned: \(code)")
        case .failure(let error):
            print(error)
        }
    })
```
The completion handler will handle the result of the reading.

If you need to stop or restart your reader, use the functions:
```swift
func stopScanning()
func startScanning()
```

#### Full Example - ViewController
```swift
import UIKit
import AMCodeScanner

class ViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak private var cameraView: UIView!
    @IBOutlet weak private var focusView: UIView!
    private var scanner: AMCodeScanner?

    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scanner = AMCodeScanner(
            cameraView: cameraView,
            areaOfInterest: focusView,
            maskColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5),
            aoiCornerRadius: 10,
            typesToScan: [.qr, .code128, .dataMatrix],
            completion: { result in
                switch result {
                case .success(let code):
                    print("Code scaned: \(code)")
                case .failure(let error):
                    print(error)
                }
            })
    }
}
```

#### Options
In the init function, if desired, you can avoid to pass: 
1. *areaOfInterest*: the sensitive scanner area will be the whole camera preview
2. *maskColor*: the mask color will be clear
3. *aoiCornerRadius*: the corner radius will be 0

#### Supported codes
1. UPC-E
2. Code 39
3. Code 39 mod 43
4. EAN-13
5. EAN-8
6. Code 93
7. Code 128
8. PDF417
9. QR
10. Aztec
11. Interleaved 2 of 5
12. ITF14
13. DataMatrix


## Author

* **Alessandro "DungeonDev78" Manilii**

## License

This project is licensed under the MIT License
