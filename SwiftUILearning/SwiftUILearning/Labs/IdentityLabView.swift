import SwiftUI

struct IdentityLabView: View {
    @State private var showsConditionalChild = true
    @State private var explicitID = UUID()
    @State private var stableItems = [
        IdentityItem(id: "A", title: "Alpha"),
        IdentityItem(id: "B", title: "Beta"),
        IdentityItem(id: "C", title: "Gamma")
    ]

    var body: some View {
        let started = ContinuousClock.now
        defer { RuntimeTrace.body("IdentityLabView.body", startedAt: started) }

        return LabPage(
            "View Identity",
            subtitle: "分别观察结构 Identity、显式 .id() 与 ForEach 稳定 ID。"
        ) {
            LabCard("实验一：if 移除节点", systemImage: "switch.2") {
                Text("先把子 View 的 count 加到 2，再隐藏并重新显示。")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if showsConditionalChild {
                    IdentityCounterView(name: "ConditionalChild")
                        .transition(.opacity)
                } else {
                    Text("子节点已经从 View Tree 移除")
                        .foregroundStyle(.secondary)
                }

                Button(showsConditionalChild ? "隐藏 Child" : "重新显示 Child") {
                    showsConditionalChild.toggle()
                    RuntimeTrace.event(
                        .identity,
                        source: "ConditionalChild",
                        message: showsConditionalChild ? "重新加入树，新 Storage 从初始值建立" : "从树中移除，旧 Storage 生命周期结束"
                    )
                }
                .buttonStyle(.borderedProminent)
            }

            LabCard("实验二：显式 .id()", systemImage: "tag") {
                Text("当前显式 ID：\(explicitID.short)")
                    .font(.system(.caption, design: .monospaced))

                IdentityCounterView(name: "ExplicitIDChild")
                    .id(explicitID)

                Button("更换 .id()") {
                    let old = explicitID.short
                    explicitID = UUID()
                    RuntimeTrace.event(
                        .identity,
                        source: "ExplicitIDChild",
                        message: "\(old) → \(explicitID.short)，旧节点被替换"
                    )
                }
                .buttonStyle(.borderedProminent)
            }

            LabCard("实验三：ForEach 稳定 ID", systemImage: "list.number") {
                Text("每行有独立 @State。先增加某一行，再反转顺序；状态应跟随业务 ID。")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(stableItems) { item in
                    IdentityRow(item: item)
                }

                HStack {
                    Button("反转顺序") {
                        stableItems.reverse()
                        RuntimeTrace.event(.diff, source: "ForEach", message: "顺序反转，业务 ID A/B/C 不变")
                    }
                    Button("删除首项", role: .destructive) {
                        guard let first = stableItems.first else { return }
                        stableItems.removeFirst()
                        RuntimeTrace.event(.identity, source: "ForEach", message: "删除 \(first.id)")
                    }
                    .disabled(stableItems.isEmpty)
                }
            }

            InlineTimeline(limit: 10)
        }
    }
}

private struct IdentityCounterView: View {
    let name: String
    @State private var count = 0
    @State private var token = LifetimeToken("IdentityCounterView")

    var body: some View {
        let started = ContinuousClock.now
        defer { RuntimeTrace.body("\(name).body", startedAt: started) }

        return HStack {
            VStack(alignment: .leading) {
                Text("\(name)：\(count)")
                    .font(.headline)
                Text("Storage token \(token.id.short)")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("+1") {
                count += 1
                RuntimeTrace.event(.mutation, source: name, message: "内部 @State count = \(count)")
            }
            .buttonStyle(.bordered)
        }
        .padding(12)
        .background(.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .runtimeLifecycle(name)
    }
}

private struct IdentityItem: Identifiable {
    let id: String
    let title: String
}

private struct IdentityRow: View {
    let item: IdentityItem
    @State private var taps = 0

    var body: some View {
        HStack {
            Text("\(item.id) · \(item.title)")
            Spacer()
            Button("本地状态 \(taps)") {
                taps += 1
            }
            .buttonStyle(.bordered)
        }
        .runtimeLifecycle("Row[\(item.id)]")
    }
}

