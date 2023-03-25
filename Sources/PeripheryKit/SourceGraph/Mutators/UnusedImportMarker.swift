import Foundation
import Shared

final class UnusedImportMarker: SourceGraphMutator {
    private let graph: SourceGraph

    required init(graph: SourceGraph, configuration: Configuration) {
        self.graph = graph
    }

    func mutate() {
        for (file, references) in graph.allReferencesBySourceFile {
            let importedModules = file.importStatements
                .filter { !$0.isExported }
                .compactMapSet { $0.parts.first }
                .intersection(graph.indexedModules)

            let referencedModules = references.flatMapSet { ref -> Set<String> in
                guard let decl = graph.explicitDeclaration(withUsr: ref.usr) else { return [] }
                return decl.location.file.modules
            }

            let unusedModules = importedModules
                .filter { !referencedModules.contains($0) }

            for unusedModule in unusedModules {

                let exportedModule = referencedModules.first {
                    graph.isModule($0, exportedBy: unusedModule)
                }

//                let exportsReferencedModule = referencedModules.contains {
//                    if graph.isModule($0, exportedBy: unusedModule) {
//                        print("Module \($0) is exported by \(unusedModule) in \(file.path)")
//                        return true
//                    } else {
//                        return false
//                    }
//                }

                if let exportedModule {
                    // Import is unused if the exported referenced module is imported directly.
                    if importedModules.contains(exportedModule) {
                        print("\"\(file.path) \(unusedModule)\",")
                    } else {
//                        print("!!! \(file.path) unused \(unusedModule) is not unused because it exports \(exportedModule)")
                    }
                } else {
                    print("\"\(file.path) \(unusedModule)\",")
                }
            }
        }

        // TODO: remove
        exit(0)
    }
}
