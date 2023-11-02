// The Swift Programming Language
// https://docs.swift.org/swift-book

/**
A macro that automatically generates AnyPublisher for the
functions that throw.
```
@ThrowPublisher
func doSomething() throws -> Void {
}
```
produces:
```
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
**/
@attached(peer, names: arbitrary)
public macro ThrowPublisher() = #externalMacro(module: "ThrowPublisherMacros", type: "ThrowPublisherMacro")
