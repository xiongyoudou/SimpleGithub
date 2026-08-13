import SwiftUI

struct DiffLabView: View {
    @State private var oldTree = [
        LabTreeNode(id: "A", type: "Text", value: "Hello"),
        LabTreeNode(id: "B", type: "Image", value: "star")
    ]
    @State private var newTree = [
        LabTreeNode(id: "A", type: "Text", value: "Hello"),
        LabTreeNode(id: "B", type: "Image", value: "star")
    ]

    private var operations: [TreeDiffOperation] {
        TreeDiffEngine.diff(old: oldTree, new: newTree)
    }

    var body: some View {
        LabPage(
            "Identity 与 Diff",
            subtitle: "一个公开、可测试的教学 Diff Engine，用稳定 ID 模拟复用、更新、创建与销毁。"
        ) {
            HStack(alignment: .top) {
                treeCard("Old Tree", nodes: oldTree)
                treeCard("New Tree", nodes: newTree)
            }

            LabCard("操作", systemImage: "slider.horizontal.3") {
                HStack {
                    Button("只改 Text 值") {
                        newTree = [
                            LabTreeNode(id: "A", type: "Text", value: "World"),
                            LabTreeNode(id: "B", type: "Image", value: "star")
                        ]
                        logDiff()
                    }
                    Button("换类型") {
                        newTree = [
                            LabTreeNode(id: "A", type: "Image", value: "photo"),
                            LabTreeNode(id: "B", type: "Image", value: "star")
                        ]
                        logDiff()
                    }
                    Button("增删节点") {
                        newTree = [
                            LabTreeNode(id: "B", type: "Image", value: "star"),
                            LabTreeNode(id: "C", type: "Button", value: "Tap")
                        ]
                        logDiff()
                    }
                }
                .buttonStyle(.bordered)
            }

            LabCard("Diff 结果", systemImage: "arrow.left.arrow.right") {
                ForEach(operations) { operation in
                    Label(operation.description, systemImage: icon(for: operation))
                }
            }

            Button("将 New 提交为 Old") {
                oldTree = newTree
                RuntimeTrace.event(.render, source: "DiffLab", message: "把新树作为下一轮旧树")
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func treeCard(_ title: String, nodes: [LabTreeNode]) -> some View {
        LabCard(title, systemImage: "tree") {
            ForEach(nodes) { node in
                Text("\(node.id) · \(node.type)(\(node.value))")
                    .font(.caption.monospaced())
            }
        }
    }

    private func icon(for operation: TreeDiffOperation) -> String {
        switch operation {
        case .reuse: "arrow.triangle.2.circlepath"
        case .update: "pencil"
        case .create: "plus.circle"
        case .destroy: "minus.circle"
        }
    }

    private func logDiff() {
        let result = TreeDiffEngine.diff(old: oldTree, new: newTree)
        RuntimeTrace.event(
            .diff,
            source: "TreeDiffEngine",
            message: result.map(\.description).joined(separator: "；")
        )
    }
}

