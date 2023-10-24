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
    func doSomething<T>(arg: T) throws -> String where T: Equatable {
        "Something"
    }
}

let myStruct = MyStruct()

myStruct.doSomething_publisher()
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

