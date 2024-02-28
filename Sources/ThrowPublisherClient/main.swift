import ThrowPublisher
import Combine
import Foundation

var cancellables = Set<AnyCancellable>()

struct MyStruct {
    @ThrowPublisher
    func doSomething(arg: String) throws -> String {
        "Something"
    }

    @ThrowPublisher
    func doSomething(arg: (String) -> String) throws -> String {
        arg("Something")
    }

    @ThrowPublisher
    func doSomething(_ arg: String) throws -> String {
        "Something"
    }

    @ThrowPublisher
    func doSomething() throws -> Void {
        print("Something")
    }

    @ThrowPublisher
    func doSomething(arg: String?) throws -> String? {
        nil
    }

    @ThrowPublisher
    func doSomething<T, P>(arg: T, arg2: P) throws -> String where T: Equatable {
        "Something"
    }

    @ThrowPublisher
    static func doSomething(arg: String) throws -> String {
        "Something"
    }

    @ThrowPublisher
    var something: String {
        get throws {
            "Something"
        }
    }

    @ThrowPublisher
    var somethingWithVoid: Void {
        get throws {
            print("Something")
        }
    }

    @ThrowPublisher
    var somethingOptional: String? {
        get throws {
            "Something"
        }
    }

    @ThrowPublisher
    static var somethingStatic: String? {
        get throws {
            "Something"
        }
    }
}

extension Array {
    @ThrowPublisher
    func doSomething(arg: String) throws -> String where Self.Element == Int {
        "Something"
    }
}

let myStruct = MyStruct()

myStruct.something_publisher
    .sink { completion in
        switch completion {
        case .finished:
            print("finished")
        case .failure(let error):
            print(error.localizedDescription)
        }
    } receiveValue: { value in
        print(value)
    }.store(in: &cancellables)

myStruct.doSomething_publisher(arg: "Something")
    .sink { completion in
        switch completion {
        case .finished:
            print("finished")
        case .failure(let error):
            print(error.localizedDescription)
        }
    } receiveValue: { value in
        print(value)
    }.store(in: &cancellables)

