import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ThrowPublisherMacros)
import ThrowPublisherMacros

let testMacros: [String: Macro.Type] = [
    "ThrowPublisher": ThrowPublisherMacro.self,
]
#endif

final class ThrowPublisherTests: XCTestCase {
    func testMacro() throws {
        #if canImport(ThrowPublisherMacros)
        assertMacroExpansion(
            """
            @ThrowPublisher
            func someFunc(arg1: String, arg2: Int) throws -> String {
                "something"
            }
            """,
            expandedSource: """
            func someFunc(arg1: String, arg2: Int) throws -> String {
                "something"
            }

            func someFunc_publisher(arg1: String, arg2: Int) -> AnyPublisher<String, Error> {
                func getResult() -> Result<String, Error> {
                    do {
                        let result = try someFunc(arg1: arg1, arg2: arg2)
                        return .success(result)
                    } catch {
                        return .failure(error)
                    }
                }
                return getResult()
                .publisher
                .eraseToAnyPublisher()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithWildcard() throws {
        #if canImport(ThrowPublisherMacros)
        assertMacroExpansion(
            """
            @ThrowPublisher
            func someFunc(_ arg1: String, arg2: Int) throws -> String {
                "something"
            }
            """,
            expandedSource: """
            func someFunc(_ arg1: String, arg2: Int) throws -> String {
                "something"
            }

            func someFunc_publisher(_ arg1: String, arg2: Int) -> AnyPublisher<String, Error> {
                func getResult() -> Result<String, Error> {
                    do {
                        let result = try someFunc(arg1, arg2: arg2)
                        return .success(result)
                    } catch {
                        return .failure(error)
                    }
                }
                return getResult()
                .publisher
                .eraseToAnyPublisher()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithNoReturnType() throws {
        #if canImport(ThrowPublisherMacros)
        assertMacroExpansion(
            """
            @ThrowPublisher
            func someFunc() throws {
                print("hop")
            }
            """,
            expandedSource: """
            func someFunc() throws {
                print("hop")
            }

            func someFunc_publisher() -> AnyPublisher<Void, Error> {
                func getResult() -> Result<Void, Error> {
                    do {
                        try someFunc()
                        return .success(())
                    } catch {
                        return .failure(error)
                    }
                }
                return getResult()
                .publisher
                .eraseToAnyPublisher()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithOptionals() throws {
        #if canImport(ThrowPublisherMacros)
        assertMacroExpansion(
            """
            @ThrowPublisher
            func someFunc(arg: String?) throws -> String? {
                print("hop")
            }
            """,
            expandedSource: """
            func someFunc(arg: String?) throws -> String? {
                print("hop")
            }

            func someFunc_publisher(arg: String?) -> AnyPublisher<String?, Error> {
                func getResult() -> Result<String?, Error> {
                    do {
                        let result = try someFunc(arg: arg)
                        return .success(result)
                    } catch {
                        return .failure(error)
                    }
                }
                return getResult()
                .publisher
                .eraseToAnyPublisher()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithGeneric() throws {
        #if canImport(ThrowPublisherMacros)
        assertMacroExpansion(
            """
            @ThrowPublisher
            func someFunc<T, P>(arg1: T, arg2: P) throws -> String {
                "something"
            }
            """,
            expandedSource: """
            func someFunc<T, P>(arg1: T, arg2: P) throws -> String {
                "something"
            }

            func someFunc_publisher<T, P>(arg1: T, arg2: P) -> AnyPublisher<String, Error> {
                func getResult() -> Result<String, Error> {
                    do {
                        let result = try someFunc(arg1: arg1, arg2: arg2)
                        return .success(result)
                    } catch {
                        return .failure(error)
                    }
                }
                return getResult()
                .publisher
                .eraseToAnyPublisher()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithClosureParameter() throws {
        #if canImport(ThrowPublisherMacros)
        assertMacroExpansion(
            """
            @ThrowPublisher
            func someFunc(arg1: (String) -> String, arg2: Int) throws -> String {
                arg1("something")
            }
            """,
            expandedSource: """
            func someFunc(arg1: (String) -> String, arg2: Int) throws -> String {
                arg1("something")
            }

            func someFunc_publisher(arg1: (String) -> String, arg2: Int) -> AnyPublisher<String, Error> {
                func getResult() -> Result<String, Error> {
                    do {
                        let result = try someFunc(arg1: arg1, arg2: arg2)
                        return .success(result)
                    } catch {
                        return .failure(error)
                    }
                }
                return getResult()
                .publisher
                .eraseToAnyPublisher()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithWhere() throws {
        #if canImport(ThrowPublisherMacros)
        assertMacroExpansion(
            """
            @ThrowPublisher
            func someFunc<T>(arg1: T) throws -> String where T: Equatable, Self.Element == Int {
                "something"
            }
            """,
            expandedSource: """
            func someFunc<T>(arg1: T) throws -> String where T: Equatable, Self.Element == Int {
                "something"
            }

            func someFunc_publisher<T>(arg1: T) -> AnyPublisher<String, Error> where T: Equatable, Self.Element == Int {
                func getResult() -> Result<String, Error> {
                    do {
                        let result = try someFunc(arg1: arg1)
                        return .success(result)
                    } catch {
                        return .failure(error)
                    }
                }
                return getResult()
                .publisher
                .eraseToAnyPublisher()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithStatic() throws {
        #if canImport(ThrowPublisherMacros)
        assertMacroExpansion(
            """
            @ThrowPublisher
            static func someFunc(arg1: String, arg2: Int) throws -> String {
                "something"
            }
            """,
            expandedSource: """
            static func someFunc(arg1: String, arg2: Int) throws -> String {
                "something"
            }

            static func someFunc_publisher(arg1: String, arg2: Int) -> AnyPublisher<String, Error> {
                func getResult() -> Result<String, Error> {
                    do {
                        let result = try someFunc(arg1: arg1, arg2: arg2)
                        return .success(result)
                    } catch {
                        return .failure(error)
                    }
                }
                return getResult()
                .publisher
                .eraseToAnyPublisher()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithNotFunction() throws {
        #if canImport(ThrowPublisherMacros)
        assertMacroExpansion(
            """
            @ThrowPublisher
            var someVariable: String
            """,
            expandedSource: """
            var someVariable: String
            """,
            diagnostics: [.init(message: "Declaration must be function.", line: 1, column: 1)],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithAsync() throws {
        #if canImport(ThrowPublisherMacros)
        assertMacroExpansion(
            """
            @ThrowPublisher
            func someFunc() async throws {
                print("hop")
            }
            """,
            expandedSource: """
            func someFunc() async throws {
                print("hop")
            }
            """,
            diagnostics: [.init(message: "ThrowPublisher doesn't support async specifier.", line: 1, column: 1)],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testMacroWithNotThrowing() throws {
        #if canImport(ThrowPublisherMacros)
        assertMacroExpansion(
            """
            @ThrowPublisher
            func someFunc() {
                print("hop")
            }
            """,
            expandedSource: """
            func someFunc() {
                print("hop")
            }
            """,
            diagnostics: [.init(message: "Function doesn't throw.", line: 1, column: 1)],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
