# OSLocationService Framework
[![CircleCI](https://circleci.com/gh/OrdnanceSurvey/oslocationservices-ios.svg?style=svg)](https://circleci.com/gh/OrdnanceSurvey/oslocationservices-ios)
[![Coverage Status](https://coveralls.io/repos/github/OrdnanceSurvey/oslocationservices-ios/badge.svg?branch=master)](https://coveralls.io/github/OrdnanceSurvey/oslocationservices-ios?branch=master)

Simple wrapper around Core Location's `CLLocationManager` to provide a sensible
set of defaults to make configuration simple.

## Installation
This framework supports carthage if you're using a dependency manager. Just add

`github "OrdnanceSurvey/oslocationservices-ios"`

to your Cartfile

## Usage
Implement `OSLocationProviderDelegate` which is basically the same as `CLLocationManagerDelegate`, but passing the `OSLocationProvider` instead
of the `CLLocationManager`. Then simply instantiate and start listening.

```
OSLocationProvider *locationProvider = [[OSLocationProvider alloc] initWithDelegate:self];
[locationProvider startLocationServiceUpdatesForAuthorisationStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
```

## License
This framework is released under the [Apache 2.0 License](LICENSE).
