![Nomosi: Declarative plug and play network services for your iOS apps](https://raw.githubusercontent.com/MarioIannotta/Nomosi/develop/Resources/Nomosi.jpg)

[![Version](https://img.shields.io/cocoapods/v/Nomosi.svg?style=flat)](https://cocoapods.org/pods/Nomosi)
[![License](https://img.shields.io/cocoapods/l/Nomosi.svg?style=flat)](https://cocoapods.org/pods/Nomosi)
[![Platform](https://img.shields.io/cocoapods/p/Nomosi.svg?style=flat)](https://cocoapods.org/pods/Nomosi)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Why

Today every app is connected to some backend(s), usually that's achieved through a network layer, generally a singleton, that has the responsibility to take an input, perform a network request, parse the response and return a result.

In complex projects this approach could cause the network layer to be a massive and unmaintainable file with more than 20.000 LOC. Yes, that's a true story.

The idea behind Nomosi is to split the network layer into different *services* where every service represents a remote resource. 

Each service is indipendent and atomic making things like module-based app development, client api versioning, working in large teams, testing and maintain the codebase a lot easier.

### Features
<details>
<summary>Declarative functional syntax</summary>
<p>

The core object of Nomosi is a *Service*, declared as  `Service<Response: ServiceResponse>` aka a generic class where the placeholder `Response` conforms the protocol  `ServiceResponse`. 

In this way instead of having a singleton that handle tons of requests, you'll have different *services* and it's immediatly clear what you should expect from each service. 

After setting the required properties (url, method, etc..), by calling the `load()` function a new request will be performed. It is also possible to chain multiple actions like `onSuccess`, `onFailure`, `addingObserver` in a fancy functional way.

Example:
```swift
/**
  The service class: a resource "blueprint", here it is possible to set endpoint, cache policy, log level etc...
*/
class AService<AServiceResponse>: Service<Response> {

    init() {
        super.init()
        basePath = "https://api.a-backend.com/v1/resources/1234"
        cachePolicy = .inRam(timeout: 60*5)
        log = .minimal
        decorateRequest { [weak self] completion in
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

// iOS < 15, callback-based approach
AService()
    .load()
    .onSuccess { response in
        // response is an instance of `AServiceResponse`: Type-safe swift superpower!
    }
    .onFailure { error in
        // handle error
    }
}

// iOS 15+, async/await-based approach

let result = await AService().load()
switch result {
case .success(let response):
    // response is an instance of `AServiceResponse`: Type-safe swift superpower!
    print(response)
case .failure(let error):
    // handle error
    print(error)
}
```

</p>
</details>

<details>
<summary>Type-safe by design</summary>
<p>

Leveraging Swift's type system and latest features, with Nomosi you won't ever need to handle JSON and mixed data content directly. You can forget about third party libraries such as `Marshal` and `SwiftyJSON`.

</p>
</details>

<details>
<summary>Easy to decorate (eg: token refresh) and/or invalidate requests</summary>
<p>

Handling tokens and requests validation could be tricky. That's why the closure `decorateRequest` has been introduced.

The closure is called just before the network task is started and, using the completion block, it's possible to invalidate or decorate the request that is about to be performed.

Example:

```swift
class TokenProtectedService<ServiceResponse>: Service<Response> {

    init() {
        super.init()
        basePath = "https://api.aBackend.com/v1/resources/1234"
        decorateRequest { [weak self] completion in
            AuthManager.shared.retrieveToken { token in
                if let token = token {
                    self?.headers["Authorization"] = token
                    completion(nil)
                } else {
                    completion(ServiceError(code: 100, reason: "Unable to retrieve the token"))
                }
            }
        }
    }
    
}
```

</p>
</details>

<details>
<summary>Straightforward cache configuration with the layer of your choice (`URLCache` by default) </summary>
<p>

Cache is handled with the protocol `CacheProvider`.

`URLCache` already conforms this protocol and with the podspec `Nomosi/CoreDataCache` you can use `CoreData` as persistent storage. 

If you want to use another persistent layer library (`Realm`, `CouchBase`, etc...) you have to implement just three methods:
```swift
func removeExpiredCachedResponses()

func loadIfNeeded(request: URLRequest,
                  cachePolicy: CachePolicy,
                  completion: ((_ data: Data?) -> Void))

func storeIfNeeded(request: URLRequest,
                  response: URLResponse,
                  data: Data,
                  cachePolicy: CachePolicy,
                  completion: ((_ success: Bool) -> Void))
```

</p>
</details>

<details>
<summary>Discard invalid or redundant requests </summary>
<p>

Nomosi ensure that every performed request is valid and unique.

For exampe, if you call two time the `load()` method on the same service, only one request will be performed, you'll receive a *reduntant request* error for the second one. 

</p>
</details>

<details>
<summary>Mock support</summary>
<p>

Mock are handled with the protocol `MockProvider` defined as it follows:
```swift
protocol MockProvider {

    var isMockEnabled: Bool { get }
    var mockedData: DataConvertible? { get }
    var mockBundle: Bundle? { get }

}
```

By default mock are retieved by searching for files in the bundle named `ServiceName.mock`.

Example

```swift
// UserService.swift
class UserService<User>: Service<Response> {

    init(userID: Int) {
        super.init()
        basePath = "https://api.aBackend.com/v1/users/\(userID)"
    }

}
```

```swift
// User.swift
struct User {
    let name: String
    let surname: String
    let website: String
}
```

```swift
// UserService.mock
{
    "name": "Mario",
    "surname": "Iannotta",
    "website": "http://www.marioiannotta.com"
}
```

</p>
</details>

<details>
<summary>Develop and attach thirdy part components </summary>
<p>

Any class that conforms the protocol `ServiceObserver` can be notified when a request starts and ends; all the UI components such as loader and fancy buttons are built using this protocol. 

</p>
</details>

<details>
<summary>Prebaked UI Components</summary>
<p>

Installing `Nomosi/UI` you can use different prebaked components, such as:
- `NetworkActivityIndicatorHandler` to handle the network activity indicator in the status bar.
- `RemoteImageService` to load, efficiently cache and display remote images in imageviews using custom loaders and placeholders.
- `ServiceOverlayView` to handle loaders while performing requests and display any occurred errors alongside the retry button.
- `ServiceObserverButton` to perform custom animations (resize, show loader, hide content etc...) on buttons while performing requests.

</p>
</details>

<br/>

For an extensive overview about how all of that works, you can take a look at the [service flow chart](https://github.com/MarioIannotta/Nomosi/wiki/Service-flow-chart).


## Installation

#### Cocoapods
`pod 'Nomosi'`

#### Carthage
`github "MarioIannotta/Nomosi"`

## License

Nomosi is available under the MIT license. See the LICENSE file for more info.

## TODOs:

* [ ] Document all the public stuff
* [x] Support async/await (aka [Swift concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html))
* [x] Add unit tests
* [x] Add ssl pinning support
* [x] CoreData CacheProvider
* [x] Download requests
* [x] Upload requests
* [x] Add a way to mock services
* [x] Providing a generic interface for the cache so it's possible to use any storage layer by implementing just the methods loadIfNeeded and storeIfNeeded
* [x] UIImageView.Placeholder doesn't seems to work fine with cell reuse 
* [x] Add status bar activity indicator
* [x] Split pod in podspec (Core + UI)
* [x] Provide a dictionary as body
* [x] Http status code range validation
