import Foundation
import Shared

final class ObjCAccessibleRetainer: SourceGraphMutator {
    private let graph: SourceGraph
    private let configuration: Configuration

    required init(graph: SourceGraph, configuration: Configuration) {
        self.graph = graph
        self.configuration = configuration
    }

    func mutate() {
        if configuration.retainObjcAccessible {
            // Most of the retention is performed in SwiftIndexer, this section just retain
            // explicitly annotated private members.
            for kind in Declaration.Kind.accessibleKinds {
                for decl in graph.declarations(ofKind: kind) {
                    if decl.accessibility.value == .private && (decl.attributes.contains("objc") || decl.attributes.contains("objc.name")) {
                        retain(decl)
                    }
                }
            }
        } else if configuration.retainObjcAnnotated {
            for kind in Declaration.Kind.accessibleKinds {
                for decl in graph.declarations(ofKind: kind) {
                    guard decl.attributes.contains("objc") || decl.attributes.contains("objc.name") || decl.attributes.contains("objcMembers") else { continue }
                    retain(decl)

                    if decl.attributes.contains("objcMembers") || decl.kind == .extensionClass || decl.kind == .protocol {
                        decl.declarations.forEach { retain($0) }
                    }
                }
            }
        }
    }

    // MARK: - Private

    private func retain(_ declaration: Declaration) {
        graph.markRetained(declaration)
    }
}
