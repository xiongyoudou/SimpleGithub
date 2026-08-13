import Foundation

struct LabTreeNode: Identifiable, Equatable, Sendable {
    let id: String
    let type: String
    let value: String

    init(id: String, type: String, value: String = "") {
        self.id = id
        self.type = type
        self.value = value
    }
}

enum TreeDiffOperation: Identifiable, Equatable, Sendable {
    case reuse(id: String)
    case update(id: String, from: String, to: String)
    case create(id: String)
    case destroy(id: String)

    var id: String {
        switch self {
        case let .reuse(id): "reuse-\(id)"
        case let .update(id, _, _): "update-\(id)"
        case let .create(id): "create-\(id)"
        case let .destroy(id): "destroy-\(id)"
        }
    }

    var description: String {
        switch self {
        case let .reuse(id): "复用 \(id)"
        case let .update(id, from, to): "更新 \(id)：\(from) → \(to)"
        case let .create(id): "创建 \(id)"
        case let .destroy(id): "销毁 \(id)"
        }
    }
}

enum TreeDiffEngine {
    static func diff(old: [LabTreeNode], new: [LabTreeNode]) -> [TreeDiffOperation] {
        let oldByID = Dictionary(uniqueKeysWithValues: old.map { ($0.id, $0) })
        let newByID = Dictionary(uniqueKeysWithValues: new.map { ($0.id, $0) })
        var operations: [TreeDiffOperation] = []

        for oldNode in old where newByID[oldNode.id] == nil {
            operations.append(.destroy(id: oldNode.id))
        }

        for newNode in new {
            guard let oldNode = oldByID[newNode.id] else {
                operations.append(.create(id: newNode.id))
                continue
            }
            if oldNode.type != newNode.type {
                operations.append(.destroy(id: oldNode.id))
                operations.append(.create(id: newNode.id))
            } else if oldNode.value != newNode.value {
                operations.append(.update(id: newNode.id, from: oldNode.value, to: newNode.value))
            } else {
                operations.append(.reuse(id: newNode.id))
            }
        }
        return operations
    }
}
