import Foundation
import SwiftSyntax

public struct ImportStatement {
    let parts: [String]
    let isTestable: Bool
    let isExported: Bool
}

final class ImportSyntaxVisitor: PeripherySyntaxVisitor {
    var importStatements: [ImportStatement] = []

    init(sourceLocationBuilder: SourceLocationBuilder) {}

    func visit(_ node: ImportDeclSyntax) {
        let parts = node.path.map { $0.name.text }
        let attributes = node.attributes?.compactMap { $0.as(AttributeSyntax.self)?.attributeName.trimmedDescription } ?? []
        let statement = ImportStatement(
            parts: parts,
            isTestable: attributes.contains("testable"),
            isExported: attributes.contains("_exported"))
        importStatements.append(statement)
    }
}
