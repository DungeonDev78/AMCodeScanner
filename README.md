# AMCodeScanner
A small and configurable Code Scanner for iOS

![Image description](https://github.com/DungeonDev78/AMUISegmentedControl/blob/master/img001.jpg)

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

In your ViewController (or in its Storyboard) add two UIView, one for the camera preview and a second one, that is optional, for the area of interest where you should search for the code to scan.

Add the scanner property:
```swift
var scanner: AMCodeScanner?
```

In viewWillAppear init the code reader:
```swift
scanner = AMCodeScanner(cameraView: cameraView,
                        areaOfInterest: focusView,
                        maskColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5),
                        aoiCornerRadius: 10,
                        typesToScan: [.qr],
                        delegate: self)
```

Implement the two functions of **AMCodeScannerDelegate**:
```swift
func codeScannerDidReadCode(_ code: String)
func codeScannerdidFailToReadWithError(_ error: AMCodeScanner.CodeError)
```

If you need to stop or restart your reader, use the functions:
```swift
func stopScanning()
func startScanning()
```

#### Options
In the init function, if desired, you can avoid to pass: 
1. *areaOfInterest*: the sensitive scanner area will be the whole camera preview
2. *maskColor*: the mask color will be clear
3. *aoiCornerRadius*: the corner radius will be 0


## Author

* **Alessandro "DungeonDev78" Manilii**

## License

This project is licensed under the MIT License
