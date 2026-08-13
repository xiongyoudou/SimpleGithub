import SwiftUI

struct UpdatePipelineLabView: View {
    @State private var count = 0
    @State private var lastRun: [RuntimeEventKind] = []

    private let phases: [RuntimeEventKind] = [
        .action, .mutation, .dependency, .invalidation,
        .dynamicUpdate, .body, .diff, .render
    ]

    var body: some View {
        LabPage(
            "更新流水线",
            subtitle: "把一次更新拆成可阅读阶段。灰色阶段是教学模拟；body 与 DynamicProperty Lab 可用真实日志交叉验证。"
        ) {
            LabCard("流水线", systemImage: "arrow.down.forward.and.arrow.up.backward") {
                ForEach(Array(phases.enumerated()), id: \.offset) { index, phase in
                    HStack {
                        Image(systemName: phase.symbol)
                            .frame(width: 28)
                            .foregroundStyle(
                                lastRun.contains(phase)
                                    ? Color.accentColor
                                    : Color.secondary
                            )
                        VStack(alignment: .leading) {
                            Text(phase.rawValue).bold()
                            Text(detail(for: phase))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if index < phases.count - 1 {
                        FlowArrow(label: "")
                    }
                }
            }

            Button("执行 count \(count) → \(count + 1)") {
                runPipeline()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            LabCard("边界说明", systemImage: "exclamationmark.shield") {
                Text("SwiftUI 没有公开 AttributeGraph、Diff 或 Render Commit 的监听 API。本页明确模拟概念顺序；它不伪装成私有运行时抓取器。")
                    .font(.caption)
            }

            InlineTimeline(limit: 12)
        }
    }

    private func detail(for phase: RuntimeEventKind) -> String {
        switch phase {
        case .action: "Button action"
        case .mutation: "@State count 写入"
        case .dependency: "查询依赖当前状态的计算节点"
        case .invalidation: "把相关 View 节点标为需要重新求值"
        case .dynamicUpdate: "准备动态属性"
        case .body: "生成新的 View value"
        case .diff: "Identity 匹配并比较描述"
        case .render: "提交必要的布局与显示变化"
        default: ""
        }
    }

    private func runPipeline() {
        lastRun.removeAll()
        for (index, phase) in phases.enumerated() {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(index * 90))
                if phase == .mutation {
                    count += 1
                }
                lastRun.append(phase)
                RuntimeRecorder.shared.record(
                    phase,
                    source: "PipelineLab",
                    message: detail(for: phase)
                )
            }
        }
    }
}
