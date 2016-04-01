# JJJUtils

[![CI Status](http://img.shields.io/travis/jovito-royeca/JJJUtils.svg?style=flat)](https://travis-ci.org/jovito-royeca/JJJUtils)
[![Version](https://img.shields.io/cocoapods/v/JJJUtils.svg?style=flat)](http://cocoapods.org/pods/JJJUtils)
[![License](https://img.shields.io/cocoapods/l/JJJUtils.svg?style=flat)](http://cocoapods.org/pods/JJJUtils)
[![Platform](https://img.shields.io/cocoapods/p/JJJUtils.svg?style=flat)](http://cocoapods.org/pods/JJJUtils)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

JJJUtils is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JJJUtils"
```

If using JJJUtils in an OSX project you should use:

```ruby
pod "JJJUtils/OSX"
```

## Releasing a New Build
$ edit JJJUtils.podspec
# set the new version to 0.0.1
# set the new tag to 0.0.1
$ pod lib lint --allow-warnings
$ git add -A && git commit -m "Release 0.0.1."
$ git tag '0.0.1'
$ git push --tags
$ pod trunk push JJJUtils.podspec --allow-warnings

## Author

Jovito Royeca, http://jovitoroyeca.com

## License

JJJUtils is available under the MIT license. See the LICENSE file for more info.
