# FMProgressHUD

![Platform Support](https://img.shields.io/static/v1?label=platform&message=ios&color=lightgrey)
![iOS Version](https://img.shields.io/static/v1?label=iOS&message=v13+&color=blue)
![SPM Compatible](https://img.shields.io/static/v1?label=SwiftPackageManager&message=compatible&color=green)

Swift-based HUD for showing loading spinner, progress or any image with a status. <br />
The library is compatible with Swift 5.2 and iOS 13+ 
See [FMProgressHUD-Demo](https://github.com/matchifang/FMProgressHUD-Demo) for demo<br />
HUD should show either one of the following combinations:
1. indefinite loading spinner
2. indefinite loading spinner with status
3. progress loading spinner
4. progress loading spinner with status
5. image
6. image with status

![Example Screenshots](./ReadMe_Resources/examples.png)


## Installation

### Swift Package Manager
1. Copy the github URL for FMProgressHUD<br />
![Github URL](./ReadMe_Resources/1_github_clone.png)

2. In Project Settings -> Swift Package Manager, click +, paste the github URL and select the version settings
![Adding Swift Packages](./ReadMe_Resources/2_adding_package.png)

3. Added packages are shown under Project Settings -> Swift Package Manager and in Source Control Navigator
![Added Swift Package in ](./ReadMe_Resources/4_package_added.png)
![Added Swift Package in Source Control Navigator](./ReadMe_Resources/5_package_shown.png)

4. Add `import FMProgressHUD` to files where you want to use the HUD<br />

### Manual
1. Copy over the `FMProgressHUD` folder into your project
2. Add `import FMProgressHUD`<br />

## Usage
`FMProgressHUD` is a singleton class that provides static properties to configure the HUD and static methods to show the HUD. No initialisation is required.<br />
```swift
// show indefinite loading spinner
FMProgressHUD.show()

// show progress loading spinner
// note that progess ranges from 0 to 1
FMProgressHUD.show(progress: 0.1, status: "Loading...")

// show info
FMProgressHUD.showInfo(status: "Information")

// show success
FMProgressHUD.showSuccess(status: "Success")

// show error
FMProgressHUD.showError(status: "Error")

// show an image with a status
let image = UIImage(systemName: "person.fill.checkmark")!
FMProgressHUD.show(image: image, status: "Contact added")

// dismiss the HUD
FMProgressHUD.dismiss()
```

FMProgressHUD static methods:
```swift
static func show(status: String? = nil)
static func showInfo(status: String? = nil)
static func showSuccess(status: String? = nil)
static func showError(status: String? = nil)
static func show(image: UIImage, status: String? = nil)
```

## Customise your HUD

The following fields can be customised:
```swift
var animationType = FMProgressHUDAnimationType.flat // Can be: flat, native (iOS native UIActicityIndicatorView)
var maskType = FMProgressHUDMaskType.clear  // Can be: clear, black, or custom
var hudStyle = FMProgressHUDStyle.light // Can be: light, dark, or custom
var backgroundColor = UIColor.clear
var hudForegroundColor = UIColor.black 
var hudBackgroundColor = UIColor.white
var hudViewCustomBlurEffect: UIBlurEffect?
var allowUserInteraction = true
var fadeInAnimationDuration: TimeInterval = 0.15
var fadeOutAnimationDuration: TimeInterval = 0.15
var imageSize = CGSize(width: 28, height: 28)
var cornerRadius: CGFloat = 14
var ringThickness: CGFloat = 2
var labelFontSize: CGFloat = 15
```
### Customise Loading Animation
You can set loading animation using `FMProgressHUD.animationType`<br />
![Added Swift Package in Source Control Navigator](./ReadMe_Resources/loading.png)

### Customise Mask
You can set mask using `FMProgressHUD.maskType`<br />
For custom masks color, set `FMProgressHUD.backgroundColor`<br /><br />
![Added Swift Package in Source Control Navigator](./ReadMe_Resources/mask.png)

### Customise HUD Style
You can set style using `FMProgressHUD.hudStyle`<br /><br />
If `.custom` is selected, you can customise it by setting: `FMProgressHUD.hudViewCustomBlurEffect`, `FMProgressHUD.hudBackgroundColor`, and  `FMProgressHUD.hudForegroundColor`<br />
![Added Swift Package in Source Control Navigator](./ReadMe_Resources/style.png)
