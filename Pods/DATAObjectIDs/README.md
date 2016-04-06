# DATAObjectIDs

[![Version](https://img.shields.io/cocoapods/v/DATAObjectIDs.svg?style=flat)](http://cocoadocs.org/docsets/DATAObjectIDs)
[![License](https://img.shields.io/cocoapods/l/DATAObjectIDs.svg?style=flat)](http://cocoadocs.org/docsets/DATAObjectIDs)
[![Platform](https://img.shields.io/cocoapods/p/DATAObjectIDs.svg?style=flat)](http://cocoadocs.org/docsets/DATAObjectIDs)

## Usage

```objc
NSDictionary *dictionary = [DATAObjectIDs objectIDsInEntityNamed:@"User"
                                             withAttributesNamed:@"remoteID"
                                                         context:context];
```

This will be a dictionary that has as keys your primary key, such as the `remoteID`, and as value the `NSManagedObjectID`.

## Installation

**DATAObjectIDs** is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'DATAObjectIDs'
```

## Author

Elvis Nuñez, [elvisnunez@me.com](mailto:elvisnunez@me.com)

## License

**DATAObjectIDs** is available under the MIT license. See the LICENSE file for more info.
