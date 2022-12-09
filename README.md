# LLNetworkAccessibility-Swift

[![CI Status](https://img.shields.io/travis/lanlinxl/LLNetworkAccessibility-Swift.svg?style=flat)](https://travis-ci.org/lanlinxl/LLNetworkAccessibility-Swift)
[![Version](https://img.shields.io/cocoapods/v/LLNetworkAccessibility-Swift.svg?style=flat)](https://cocoapods.org/pods/LLNetworkAccessibility-Swift)
[![License](https://img.shields.io/cocoapods/l/LLNetworkAccessibility-Swift.svg?style=flat)](https://cocoapods.org/pods/LLNetworkAccessibility-Swift)
[![Platform](https://img.shields.io/cocoapods/p/LLNetworkAccessibility-Swift.svg?style=flat)](https://cocoapods.org/pods/LLNetworkAccessibility-Swift)



## Installation

LLNetworkAccessibility-Swift is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LLNetworkAccessibility-Swift'
}
```
## Example
```ruby
1. 开启检测
LLNetworkAccessibility.start()

2. 配置自定义弹框
LLNetworkAccessibility.configAlertStyle(type: .custom,closeEnable: false,tintColor: .red)

3. 网络授权监听
LLNetworkAccessibility.reachabilityUpdateCallBack = { state in
    guard let state = state else { return }
    switch state {
    case .available:
         print("网络已授权")
    case .restricted:
         print("网络没授权")
    case .unknown:
         print("没有网络（飞行模式）")
    default:
        break
    }
```

## Sample graph
![wecom-temp-3333310-b849c7c289043303f0a7cf115841ad97](https://user-images.githubusercontent.com/38074234/206689390-d110724b-1c8c-4d39-a89c-cfb0b43acb83.gif)

## My information
```javascript
var info = {
  nickName  : "lanlinxl",
  address : "https://juejin.cn/post/7175080567648550969"
}
```

## License

LLNetworkAccessibility-Swift is available under the MIT license. See the LICENSE file for more info.

