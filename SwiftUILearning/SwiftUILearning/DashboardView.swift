import SwiftUI

enum LabDestination: String, CaseIterable, Identifiable, Hashable {
    case state
    case identity
    case dynamicProperty
    case observation
    case dependency
    case pipeline
    case diff
    case navigation
    case performance
    case auth
    case inspector

    var id: String { rawValue }

    var title: String {
        switch self {
        case .state: "@State 生命周期"
        case .identity: "View Identity"
        case .dynamicProperty: "DynamicProperty"
        case .observation: "观察粒度对比"
        case .dependency: "依赖关系图"
        case .pipeline: "更新流水线"
        case .diff: "Identity 与 Diff"
        case .navigation: "导航与状态生命周期"
        case .performance: "性能与 body 计数"
        case .auth: "Auth Journey"
        case .inspector: "Runtime Inspector"
        }
    }

    var subtitle: String {
        switch self {
        case .state: "初始值、外部 Storage 与持久化"
        case .identity: "if、.id()、ForEach 如何影响 State"
        case .dynamicProperty: "观察 update() 与 body 的调用次序"
        case .observation: "ObservableObject 对象级 vs Observation 属性级"
        case .dependency: "Property → View 的教学可视化"
        case .pipeline: "Action → Mutation → Diff → Render"
        case .diff: "复用、更新、创建和销毁"
        case .navigation: "Route、Identity 和页面状态"
        case .performance: "定位无效 body 求值与耗时"
        case .auth: "服务端事件驱动的完整认证流程"
        case .inspector: "统一查看 Timeline、依赖和指标"
        }
    }

    var symbol: String {
        switch self {
        case .state: "shippingbox"
        case .identity: "fingerprint"
        case .dynamicProperty: "gearshape.2"
        case .observation: "eye"
        case .dependency: "point.3.connected.trianglepath.dotted"
        case .pipeline: "arrow.down.forward.and.arrow.up.backward"
        case .diff: "arrow.left.arrow.right.square"
        case .navigation: "point.topleft.down.to.point.bottomright.curvepath"
        case .performance: "gauge.with.dots.needle.50percent"
        case .auth: "person.badge.key"
        case .inspector: "waveform.path.ecg.rectangle"
        }
    }
}

struct DashboardView: View {
    @ObservedObject private var recorder = RuntimeRecorder.shared

    private let mechanisms: [LabDestination] = [
        .state, .identity, .dynamicProperty, .observation,
        .dependency, .pipeline, .diff
    ]
    private let engineering: [LabDestination] = [
        .navigation, .performance, .auth, .inspector
    ]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SwiftUI Runtime Lab")
                            .font(.largeTitle.bold())
                        Text("用可重复实验观察 State、Identity、依赖追踪与渲染更新边界。")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 10)
                }

                Section("核心机制") {
                    ForEach(mechanisms) { destination in
                        destinationLink(destination)
                    }
                }

                Section("工程与调试") {
                    ForEach(engineering) { destination in
                        destinationLink(destination)
                    }
                }

                Section("当前会话") {
                    LabeledContent("事件数", value: "\(recorder.events.count)")
                    LabeledContent("已记录 body", value: "\(recorder.bodyMetrics.count)")
                    LabeledContent("依赖边", value: "\(recorder.dependencies.count)")
                    Button("清空所有记录", role: .destructive) {
                        recorder.resetAll()
                    }
                }
            }
            .navigationDestination(for: LabDestination.self) { destination in
                destinationView(destination)
            }
        }
    }

    private func destinationLink(_ destination: LabDestination) -> some View {
        NavigationLink(value: destination) {
            Label {
                VStack(alignment: .leading, spacing: 3) {
                    Text(destination.title)
                        .font(.headline)
                    Text(destination.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: destination.symbol)
                    .frame(width: 28)
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func destinationView(_ destination: LabDestination) -> some View {
        switch destination {
        case .state: StateLifecycleLabView()
        case .identity: IdentityLabView()
        case .dynamicProperty: DynamicPropertyLabView()
        case .observation: ObservationComparisonLabView()
        case .dependency: DependencyGraphLabView()
        case .pipeline: UpdatePipelineLabView()
        case .diff: DiffLabView()
        case .navigation: NavigationRuntimeLabView()
        case .performance: PerformanceLabView()
        case .auth: AuthJourneyLabView()
        case .inspector: RuntimeInspectorView()
        }
    }
}
