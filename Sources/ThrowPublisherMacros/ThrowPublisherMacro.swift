import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

enum ThrowPublisherError: Error, CustomStringConvertible {
    case notFunction
    case wildcard
    case identifierType
    case asyncSpecifier
    case noThrow

    var description: String {
        switch self {
        case .notFunction:
            return "Declaration must be function."
        case .identifierType:
            return "Parameter type must be identifier type."
        case .wildcard:
            return "Could not get the name of wildcard(_) parameter."
        case .asyncSpecifier:
            return "ThrowPublisher doesn't support async specifier."
        case .noThrow:
            return "Function doesn't throw."
        }
    }
}

public struct ThrowPublisherMacro: PeerMacro {
    private static func expansionForFunction(functionDecl: FunctionDeclSyntax) throws -> [DeclSyntax] {
        guard functionDecl.signature.effectSpecifiers?.asyncSpecifier == nil else {
            throw ThrowPublisherError.asyncSpecifier
        }
        guard functionDecl.signature.effectSpecifiers?.throwsSpecifier != nil else {
            throw ThrowPublisherError.noThrow
        }

        let modifiers = functionDecl.modifiers.map {
            $0.name.text
        }.joined(separator: " ")

        let returnType: String
        if let name = functionDecl.signature.returnClause?.type.as(IdentifierTypeSyntax.self)?.name {
            returnType = name.text
        } else if let optionalTypeSyntax = functionDecl.signature.returnClause?.type.as(OptionalTypeSyntax.self),
                  let name = optionalTypeSyntax.wrappedType.as(IdentifierTypeSyntax.self)?.name {
            returnType = "\(name.text)?"
        } else {
            returnType = "Void"
        }

        let functionName = functionDecl.name.text
        var newFunctionName = "\(functionName)_publisher"

        if let genericParameterClause = functionDecl.genericParameterClause {
            newFunctionName += "\(genericParameterClause)"
        }

        var genericPart: String?
        if let genericWhereClause = functionDecl.genericWhereClause {
            genericPart = "where \(genericWhereClause.requirements)"
        }

        let parameters = "\(functionDecl.signature.parameterClause)"
        let parametersWithCall = try functionDecl.signature.parameterClause.parameters.map {
            if $0.firstName.text == "_" {
                guard let secondName = $0.secondName else { throw ThrowPublisherError.wildcard }
                return secondName.text
            }
            return "\($0.firstName.text): \($0.firstName.text)"
        }.joined(separator: ", ")

        let resultString: String
        if returnType == "Void" {
            resultString = """
        try \(functionName)(\(parametersWithCall))
        return .success(())
        """
        } else {
            resultString = """
        let result = try \(functionName)(\(parametersWithCall))
        return .success(result)
        """
        }

        var returnPart = "AnyPublisher<\(returnType), Error>"
        if let genericPart {
            returnPart += " \(genericPart)"
        }

        var startOfFunction = "func"
        if !modifiers.isEmpty {
            startOfFunction = "\(modifiers) \(startOfFunction)"
        }
        let hop = """
        \(startOfFunction) \(newFunctionName)\(parameters)-> \(returnPart){
            func getResult() -> Result<\(returnType), Error> {
                do {
                    \(resultString)
                } catch {
                    return .failure(error)
                }
            }
            return getResult()
            .publisher
            .eraseToAnyPublisher()
        }
        """

        return ["""
        \(raw: hop)
        """
        ]
    }

    private static func expansionForVariable(variableDecl: VariableDeclSyntax) throws -> [DeclSyntax] {
        guard variableDecl.bindingSpecifier.tokenKind == .keyword(.var) else {
            throw ThrowPublisherError.asyncSpecifier
        }

        guard variableDecl.bindings.count == 1 else { throw ThrowPublisherError.asyncSpecifier }
        let firstBinding = variableDecl.bindings.first!

        guard case .accessors(let accessors) = firstBinding.accessorBlock?.accessors else {
            throw ThrowPublisherError.asyncSpecifier
        }
        if accessors.contains(where: { $0.effectSpecifiers?.asyncSpecifier != nil }) {
            throw ThrowPublisherError.asyncSpecifier
        }
        guard accessors.contains(where: { $0.effectSpecifiers?.throwsSpecifier != nil }) else {
            throw ThrowPublisherError.asyncSpecifier
        }

        let modifiers = variableDecl.modifiers.map {
            $0.name.text
        }.joined(separator: " ")

        let returnType: String
        if let name = firstBinding.typeAnnotation?.type.as(IdentifierTypeSyntax.self)?.name {
            returnType = name.text
        } else if let optionalTypeSyntax = firstBinding.typeAnnotation?.type.as(OptionalTypeSyntax.self),
                  let name = optionalTypeSyntax.wrappedType.as(IdentifierTypeSyntax.self)?.name {
            returnType = "\(name.text)?"
        } else {
            returnType = "Void"
        }

        let variableName = "\(firstBinding.pattern)"
        let newVaraibleName = "\(variableName)_publisher"

        let resultString: String
        if returnType == "Void" {
            resultString = """
        try \(variableName)
        return .success(())
        """
        } else {
            resultString = """
        let result = try \(variableName)
        return .success(result)
        """
        }

        let returnPart = "AnyPublisher<\(returnType), Error>"

        var startOfVariable = "var"
        if !modifiers.isEmpty {
            startOfVariable = "\(modifiers) \(startOfVariable)"
        }

        let hop = """
        \(startOfVariable) \(newVaraibleName): \(returnPart){
            func getResult() -> Result<\(returnType), Error> {
                do {
                    \(resultString)
                } catch {
                    return .failure(error)
                }
            }
            return getResult()
            .publisher
            .eraseToAnyPublisher()
        }
        """

        return ["""
        \(raw: hop)
        """
        ]
    }

   public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
       if let functionDecl = declaration.as(FunctionDeclSyntax.self) {
           return try expansionForFunction(functionDecl: functionDecl)
       } else if let variableDecl = declaration.as(VariableDeclSyntax.self) {
           return try expansionForVariable(variableDecl: variableDecl)
       }
       throw ThrowPublisherError.notFunction
   }
}
@main
struct ThrowPublisherPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ThrowPublisherMacro.self,
    ]
}
