# Nomosi

[![Version](https://img.shields.io/cocoapods/v/Nomosi.svg?style=flat)](https://cocoapods.org/pods/Nomosi)
[![License](https://img.shields.io/cocoapods/l/Nomosi.svg?style=flat)](https://cocoapods.org/pods/Nomosi)
[![Platform](https://img.shields.io/cocoapods/p/Nomosi.svg?style=flat)](https://cocoapods.org/pods/Nomosi)

## Why

Today every app is connected to some backend(s), usually that's achieved through a network layer, generally a singleton, that has the resposability to take an input, perform a network request, parse the response and return a result.

In complex projects this approach could cause the network layer to be a massive and unmaintainable file with more than 20.000 LOC. Yes, that's a true story.

## How

The idea behind Nomosi is to breakdown the network layer into different *services* where every service represents a remote resource. 

Each service is indipendent and atomic making things like module-based app development, client api versioning, working in large teams, testing and maintain the codebase a lot easier.

### Features
- Declarative functional syntax
- Type-safe by design
- Easy to decorate (eg: token refresh) and/or invalidate requests
- Straightforward cache configuration with the layer of your choice (URLCache by default) 
- Discard invalid requests before performing them
- Avoid redundant requests
- Mock support
- Makes simple to attach thirdy part components with `ServiceObserver`
- Prebaked UI Components (by adding `Nomosi/UI`)

For an extensive overview about how all of that works, you can take a look at the [service flow chart](https://github.com/MarioIannotta/Nomosi/wiki/Service-flow-chart).

## What

The core object of Nomosi is declared as  `Service<Response: ServiceResponse>`: a generic class where the placeholder `Response` conforms the protocol  `ServiceResponse`. 

This protocol requires just one function `static func parse(data: Data) throws -> Self?` and it's already implemented for `Decodable` objects.

After setting the required properties (url, method, etc..), by calling the `load()` function a new request will be performed. It is also possible to chain multiple actions like `onSuccess`, `onFailure`, `addingObserver` in a fancy functional way.

Example:
```swift
/**
  The service class: a resource "blueprint", here it is possible to set endpoint, cache policy, log level etc...
*/
class AService<AServiceResponse>: Service<Response> {

    init() {
        super.init()
        basePath = "https://api.aBackend.com/v1/resources/1234"
        cachePolicy = .inRam(timeout: 60*5)
        log = .minimal
        decotateRequest { [weak self] completion in
            // here you can decorate the request as you wish,
            // for example you can place here the token refresh logic
            // it is possible to pass a ServiceError to the completion block or nil
            completion(nil)
        }
    }

}

/** 
  The service response, since it conforms `Decodable`, there's no need to implement the parse function.
*/
struct AServiceResponse: Decodable {
    var aPropertyOne: String?
    var aPropertyTwo: String?
}

AService()
    .load()?
    .onSuccess { aResponse in
        // aResponse is an instance of `AServiceResponse`: Type-safe swift superpower!
    }
    .onFailure { error in
        // handle error
    }
}
```

## Installation

Nomosi is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Nomosi'
```

## License

Nomosi is available under the MIT license. See the LICENSE file for more info.

## TODOs:

* [ ] Upload requests
* [ ] Document all the public stuff
* [x] Add a way to mock services
* [x] Providing a generic interface for the cache so it's possible to use any storage layer by implementing just the methods loadIfNeeded and storeIfNeeded
* [x] UIImageView.Placeholder doesn't seems to work fine with cell reuse 
* [x] Add status bar activity indicator
* [x] Split pod in podspec (Core + UI)
* [x] Provide a dictionary as body
* [x] Http status code range validation
