import SwiftUI

struct StateLifecycleLabView: View {
    @State private var count = 0
    @State private var unrelatedToggle = false
    @State private var model = StateReferenceModel()

    var body: some View {
        let started = ContinuousClock.now
        defer { RuntimeTrace.body("StateLifecycleLabView.body", startedAt: started) }

        return LabPage(
            "@State 生命周期",
            subtitle: "验证 View value 重建时 State Storage 仍由稳定 Identity 持有。"
        ) {
            LabCard("值类型 State", systemImage: "number") {
                HStack {
                    MetricBadge(title: "count", value: "\(count)")
                    MetricBadge(
                        title: "无关状态",
                        value: unrelatedToggle ? "ON" : "OFF",
                        tint: .orange
                    )
                }

                HStack {
                    Button("count + 1") {
                        RuntimeTrace.event(.action, source: "State Lab", message: "点击 count + 1")
                        count += 1
                        RuntimeTrace.event(.mutation, source: "@State count", message: "新值 \(count)")
                    }
                    .buttonStyle(.borderedProminent)

                    Button("切换无关状态") {
                        unrelatedToggle.toggle()
                        RuntimeTrace.event(
                            .mutation,
                            source: "@State unrelatedToggle",
                            message: "count 仍为 \(count)"
                        )
                    }
                    .buttonStyle(.bordered)
                }
            }

            LabCard("@State 持有引用", systemImage: "link") {
                Text("对象 token：\(model.token.id.short)")
                    .font(.system(.body, design: .monospaced))
                Text("即使本 View 的 body 多次求值，只要 Identity 不变，@State 保存的对象引用不变。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("替换引用（显式 mutation）") {
                    model = StateReferenceModel()
                    RuntimeTrace.event(
                        .mutation,
                        source: "@State model",
                        message: "显式替换引用，新 token \(model.token.id.short)"
                    )
                }
            }

            LabCard("关键结论", systemImage: "lightbulb") {
                Text("@State 的初始值只在对应 Storage 第一次建立时采用。View struct 可以重新生成；Identity 不变时，Storage 会继续复用。")
            }

            InlineTimeline()
        }
    }
}

@MainActor
final class StateReferenceModel {
    let token = LifetimeToken("StateLifecycleLab.model")
}

