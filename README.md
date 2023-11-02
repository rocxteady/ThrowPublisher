# ThrowPublisher
Swift Macro that automatically generates AnyPublisher for the functions that throw.

## Installation

You can add the package to the dependencies value of your Package.swift

```
dependencies: [
    .package(url: "https://github.com/rocxteady/ThrowPublisher.git", .upToNextMajor(from: "0.0.3"))
]
```

## Usage

### 1. Import the package

```
import ThrowPublisher
```

### 2. Use ThrowPubkisher macro

```
@ThrowPublisher
func doSomething() throws -> Void {
}
// expanded to...
func doSomething_publisher() -> AnyPublisher<Void, Error> {
    func getResult() -> Result<Void, Error> {
        do {
            try doSomething()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    return getResult()
    .publisher
    .eraseToAnyPublisher()
}
```

## Contribute

We appreciate contributions! If you have any suggestions, feature requests, or bug reports, please open a new issue on our GitHub repository.

## License

This package is available under the MIT license. See the LICENSE file for more info.
