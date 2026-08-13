import SwiftUI

struct RuntimeInspectorView: View {
    @ObservedObject private var recorder = RuntimeRecorder.shared
    @State private var selection: InspectorSection = .timeline
    @State private var filter: RuntimeEventKind?

    var body: some View {
        VStack(spacing: 0) {
            Picker("Inspector", selection: $selection) {
                ForEach(InspectorSection.allCases) { section in
                    Label(section.title, systemImage: section.symbol)
                        .tag(section)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            Divider()

            Group {
                switch selection {
                case .timeline: timeline
                case .bodies: bodyMetrics
                case .dependencies: dependencyGraph
                case .guide: debugGuide
                }
            }
        }
        .navigationTitle("Runtime Inspector")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("清空事件") { recorder.clearEvents() }
                    Button("重置全部", role: .destructive) { recorder.resetAll() }
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }

    private var timeline: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack {
                    Button("全部") { filter = nil }
                        .buttonStyle(.borderedProminent)
                        .tint(filter == nil ? .accentColor : .secondary)

                    ForEach(RuntimeEventKind.allCases, id: \.self) { kind in
                        Button(kind.rawValue) { filter = kind }
                            .buttonStyle(.bordered)
                            .tint(filter == kind ? .accentColor : .secondary)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)

            List(filteredEvents.reversed()) { event in
                RuntimeEventRow(event: event)
            }
            .overlay {
                if filteredEvents.isEmpty {
                    ContentUnavailableView(
                        "没有匹配事件",
                        systemImage: "line.3.horizontal.decrease.circle",
                        description: Text("进入任意 Lab 操作后再回来查看。")
                    )
                }
            }
        }
    }

    private var filteredEvents: [RuntimeEvent] {
        guard let filter else { return recorder.events }
        return recorder.events.filter { $0.kind == filter }
    }

    private var bodyMetrics: some View {
        List {
            Section {
                Text("body 计数用于定位更新入口；它不等于真实 UIKit/渲染对象被重建。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("指标") {
                ForEach(
                    recorder.bodyMetrics.values.sorted { $0.count > $1.count }
                ) { metric in
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(metric.name)
                                .font(.subheadline.monospaced())
                            Spacer()
                            Text("\(metric.count) 次")
                                .bold()
                        }
                        ProgressView(value: Double(metric.count), total: maxBodyCount)
                        Text("探针平均 \(metric.averageMilliseconds, format: .number.precision(.fractionLength(3))) ms")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .overlay {
            if recorder.bodyMetrics.isEmpty {
                ContentUnavailableView("还没有 body 指标", systemImage: "gauge")
            }
        }
    }

    private var maxBodyCount: Double {
        Double(max(recorder.bodyMetrics.values.map(\.count).max() ?? 1, 1))
    }

    private var dependencyGraph: some View {
        List {
            Section {
                Text("这些边由 Lab 显式登记，用于教学和验证；并非读取私有 AttributeGraph。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("Property → View") {
                ForEach(recorder.dependencies.sorted { $0.id < $1.id }) { edge in
                    HStack {
                        Text(edge.source).font(.caption.monospaced())
                        Spacer()
                        Image(systemName: "arrow.right")
                        Text(edge.target).font(.caption.bold())
                    }
                }
            }
        }
        .overlay {
            if recorder.dependencies.isEmpty {
                ContentUnavailableView(
                    "还没有依赖边",
                    systemImage: "point.3.connected.trianglepath.dotted",
                    description: Text("先打开 Observation 或 Dependency Lab。")
                )
            }
        }
    }

    private var debugGuide: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                debugCard(
                    "State 为什么丢？",
                    steps: ["检查 View 是否从树中移除", "检查 `.id()` 与 ForEach ID", "确认状态所有者的 Identity 生命周期"]
                )
                debugCard(
                    "为什么 body 很频繁？",
                    steps: ["找到状态通知入口", "检查 ObservableObject 观察范围", "把属性读取下推到最小 View", "用 Instruments 验证成本"]
                )
                debugCard(
                    "为什么 UI 没更新？",
                    steps: ["确认变化来自可观察状态", "普通 class 内部字段不会自动被 @State 观察", "检查写入是否发生在正确 Actor"]
                )
            }
            .padding()
        }
    }

    private func debugCard(_ title: String, steps: [String]) -> some View {
        LabCard(title, systemImage: "stethoscope") {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                Text("\(index + 1). \(step)")
            }
        }
    }
}

private enum InspectorSection: String, CaseIterable, Identifiable {
    case timeline
    case bodies
    case dependencies
    case guide

    var id: String { rawValue }

    var title: String {
        switch self {
        case .timeline: "Timeline"
        case .bodies: "Body"
        case .dependencies: "依赖"
        case .guide: "指南"
        }
    }

    var symbol: String {
        switch self {
        case .timeline: "clock"
        case .bodies: "gauge"
        case .dependencies: "point.3.connected.trianglepath.dotted"
        case .guide: "book"
        }
    }
}

