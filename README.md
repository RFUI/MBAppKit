# MBAppKit

[![Build Status](https://img.shields.io/travis/RFUI/MBAppKit.svg?style=flat-square&colorA=333333&colorB=6600cc)](https://travis-ci.org/RFUI/MBAppKit)

## Requirements

Xcode 9, iOS 9+

## Install

Install using CocoaPods is highly recommended.

```ruby
pod 'MBAppKit', :git => 'https://github.com/RFUI/MBAppKit.git', :subspecs => [
    'Core'
]
```

You must specify the git source, as this pod will never be shipped to the master spec repo.

Because some components must be defined in the main project which contains MBAppKit. So it can never pass the pod lint validation.

## Subspec list

* UserIDIsString

    By default, the user ID is an integer value. If you want it to be a string, you can include this subspec in your podfile.

## FAQs

### Build fails because symbol(s) not found

Some debugging tools and managers must be compiled along with the main project.

Check out `shadow.h` and implementation them in the main project.
