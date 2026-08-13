import SwiftUI

struct DynamicPropertyLabView: View {
    @DebugDynamicProperty("DynamicPropertyLab.count")
    private var count = 0

    @State private var unrelated = false

    var body: some View {
        let started = ContinuousClock.now
        defer { RuntimeTrace.body("DynamicPropertyLabView.body", startedAt: started) }

        return LabPage(
            "DynamicProperty",
            subtitle: "通过自定义包装器实际记录 update()；它是 body 前的准备入口，不等于“把新值再同步一次”。"
        ) {
            LabCard("可交互实验", systemImage: "gearshape.2") {
                HStack {
                    MetricBadge(title: "DebugDynamicProperty", value: "\(count)")
                    MetricBadge(title: "普通 @State", value: unrelated ? "ON" : "OFF", tint: .purple)
                }

                HStack {
                    Button("修改包装值") {
                        count += 1
                    }
                    .buttonStyle(.borderedProminent)

                    Button("触发另一状态更新") {
                        unrelated.toggle()
                        RuntimeTrace.event(.mutation, source: "unrelated", message: "切换为 \(unrelated)")
                    }
                }
            }

            LabCard("如何阅读时间线", systemImage: "list.bullet.rectangle") {
                Text("每轮求值前应先看到 DynamicProperty.update，再看到 DynamicPropertyLabView.body。具体调用次数是 SwiftUI 实现细节，不应该成为业务正确性的依赖。")
            }

            InlineTimeline(limit: 14)
        }
    }
}

