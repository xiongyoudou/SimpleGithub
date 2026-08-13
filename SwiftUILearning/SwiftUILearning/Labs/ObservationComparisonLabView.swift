import Observation
import SwiftUI
import Combine

struct ObservationComparisonLabView: View {
    @StateObject private var classic = ClassicUserModel()
    @State private var modern = FineUserModel()

    var body: some View {
        LabPage(
            "观察粒度对比",
            subtitle: "经典 ObservableObject 通过 objectWillChange 做对象级失效；Observation 按 body 实际读取的属性追踪。"
        ) {
            LabCard("ObservableObject + @ObservedObject", systemImage: "shippingbox.fill") {
                ClassicNameView(model: classic)

                HStack {
                    Button("修改 name") {
                        classic.name = classic.name == "Taylor" ? "Jordan" : "Taylor"
                        RuntimeTrace.event(.mutation, source: "Classic.name", message: classic.name)
                    }
                    Button("只修改 age") {
                        classic.age += 1
                        RuntimeTrace.event(
                            .mutation,
                            source: "Classic.age",
                            message: "age = \(classic.age)；NameView 仍收到对象级通知"
                        )
                    }
                }
                .buttonStyle(.bordered)
            }

            LabCard("@Observable 属性级追踪", systemImage: "scope") {
                FineNameView(model: modern)

                HStack {
                    Button("修改 name") {
                        modern.name = modern.name == "Taylor" ? "Jordan" : "Taylor"
                        RuntimeTrace.event(.mutation, source: "Modern.name", message: modern.name)
                    }
                    Button("只修改 age") {
                        modern.age += 1
                        RuntimeTrace.event(
                            .mutation,
                            source: "Modern.age",
                            message: "age = \(modern.age)；FineNameView 没读取 age"
                        )
                    }
                }
                .buttonStyle(.bordered)
            }

            LabCard("验证方法", systemImage: "checklist") {
                Text("先在 Inspector 清空统计，然后分别点两个“只修改 age”。比较 ClassicNameView.body 与 FineNameView.body 的次数。")
            }

            BodyMetricSummary(names: ["ClassicNameView.body", "FineNameView.body"])
            InlineTimeline(limit: 12)
        }
    }
}

@MainActor
private final class ClassicUserModel: ObservableObject {
    @Published var name = "Taylor"
    @Published var age = 30
}

@Observable
@MainActor
private final class FineUserModel {
    var name = "Taylor"
    var age = 30
}

private struct ClassicNameView: View {
    @ObservedObject var model: ClassicUserModel

    var body: some View {
        let started = ContinuousClock.now
        defer { RuntimeTrace.body("ClassicNameView.body", startedAt: started) }

        return HStack {
            Text("只显示 name：")
            Text(model.name).bold()
            Spacer()
            Text("对象级")
                .font(.caption)
                .foregroundStyle(.orange)
        }
    }
}

private struct FineNameView: View {
    let model: FineUserModel

    var body: some View {
        let started = ContinuousClock.now
        defer { RuntimeTrace.body("FineNameView.body", startedAt: started) }
        RuntimeTrace.dependency("FineUserModel.name", view: "FineNameView")

        return HStack {
            Text("只显示 name：")
            Text(model.name).bold()
            Spacer()
            Text("属性级")
                .font(.caption)
                .foregroundStyle(.green)
        }
    }
}

struct BodyMetricSummary: View {
    @ObservedObject private var recorder = RuntimeRecorder.shared
    let names: [String]

    var body: some View {
        HStack {
            ForEach(names, id: \.self) { name in
                MetricBadge(
                    title: name,
                    value: "\(recorder.bodyMetrics[name]?.count ?? 0)",
                    tint: name.contains("Fine") ? .green : .orange
                )
            }
        }
    }
}
