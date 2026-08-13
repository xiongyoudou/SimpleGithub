import Foundation

enum RuntimeEventKind: String, CaseIterable, Codable, Sendable {
    case action = "用户操作"
    case mutation = "状态变更"
    case dependency = "依赖查找"
    case invalidation = "节点失效"
    case dynamicUpdate = "DynamicProperty.update"
    case body = "body 求值"
    case identity = "Identity"
    case lifecycle = "生命周期"
    case diff = "View Diff"
    case render = "渲染提交"
    case navigation = "导航"
    case server = "服务端事件"
    case flow = "流程转换"
    case performance = "性能"

    var symbol: String {
        switch self {
        case .action: "hand.tap"
        case .mutation: "pencil.and.list.clipboard"
        case .dependency: "point.3.connected.trianglepath.dotted"
        case .invalidation: "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90"
        case .dynamicUpdate: "gearshape.2"
        case .body: "curlybraces"
        case .identity: "fingerprint"
        case .lifecycle: "arrow.triangle.2.circlepath"
        case .diff: "arrow.left.arrow.right"
        case .render: "paintbrush"
        case .navigation: "point.topleft.down.to.point.bottomright.curvepath"
        case .server: "server.rack"
        case .flow: "arrow.triangle.branch"
        case .performance: "gauge.with.dots.needle.50percent"
        }
    }
}

struct RuntimeEvent: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let timestamp: Date
    let kind: RuntimeEventKind
    let source: String
    let message: String

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        kind: RuntimeEventKind,
        source: String,
        message: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.kind = kind
        self.source = source
        self.message = message
    }
}

struct BodyMetric: Identifiable, Equatable, Sendable {
    var id: String { name }
    let name: String
    var count: Int
    var totalDuration: Duration

    var averageMilliseconds: Double {
        guard count > 0 else { return 0 }
        let components = totalDuration.components
        let seconds = Double(components.seconds)
        let attoseconds = Double(components.attoseconds) / 1_000_000_000_000_000_000
        return (seconds + attoseconds) * 1_000 / Double(count)
    }
}

struct DependencyEdge: Identifiable, Hashable, Sendable {
    var id: String { "\(source)→\(target)" }
    let source: String
    let target: String
}

