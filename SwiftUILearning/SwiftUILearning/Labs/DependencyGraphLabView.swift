import Observation
import SwiftUI

struct DependencyGraphLabView: View {
    @State private var model = DependencyDemoModel()
    @ObservedObject private var recorder = RuntimeRecorder.shared

    var body: some View {
        LabPage(
            "依赖关系图",
            subtitle: "这是对公开可观察行为的教学记录，不读取 Apple 私有 AttributeGraph。"
        ) {
            LabCard("消费者", systemImage: "rectangle.3.group") {
                DependencyNameView(model: model)
                Divider()
                DependencyAgeView(model: model)
            }

            LabCard("修改源属性", systemImage: "slider.horizontal.3") {
                HStack {
                    Button("切换 name") {
                        model.name = model.name == "Ada" ? "Grace" : "Ada"
                        recordMutation("DependencyDemoModel.name")
                    }
                    Button("age + 1") {
                        model.age += 1
                        recordMutation("DependencyDemoModel.age")
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            LabCard("已观察到的依赖边", systemImage: "point.3.connected.trianglepath.dotted") {
                if recorder.dependencies.isEmpty {
                    Text("等待 View body 读取属性…")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(recorder.dependencies.sorted { $0.id < $1.id }) { edge in
                        HStack(spacing: 10) {
                            Text(edge.source)
                                .font(.caption.monospaced())
                                .padding(8)
                                .background(.blue.opacity(0.12), in: Capsule())
                            Image(systemName: "arrow.right")
                            Text(edge.target)
                                .font(.caption.bold())
                                .padding(8)
                                .background(.green.opacity(0.12), in: Capsule())
                        }
                    }
                }
            }

            InlineTimeline(limit: 12)
        }
    }

    private func recordMutation(_ property: String) {
        let affected = recorder.dependencies
            .filter { $0.source == property }
            .map(\.target)
            .sorted()
        RuntimeTrace.event(
            .mutation,
            source: property,
            message: "教学图预测受影响 View：\(affected.isEmpty ? "无" : affected.joined(separator: ", "))"
        )
    }
}

@Observable
@MainActor
private final class DependencyDemoModel {
    var name = "Ada"
    var age = 36
}

private struct DependencyNameView: View {
    let model: DependencyDemoModel

    var body: some View {
        let started = ContinuousClock.now
        defer { RuntimeTrace.body("DependencyNameView.body", startedAt: started) }
        RuntimeTrace.dependency("DependencyDemoModel.name", view: "DependencyNameView")

        return LabeledContent("NameView", value: model.name)
    }
}

private struct DependencyAgeView: View {
    let model: DependencyDemoModel

    var body: some View {
        let started = ContinuousClock.now
        defer { RuntimeTrace.body("DependencyAgeView.body", startedAt: started) }
        RuntimeTrace.dependency("DependencyDemoModel.age", view: "DependencyAgeView")

        return LabeledContent("AgeView", value: "\(model.age)")
    }
}

