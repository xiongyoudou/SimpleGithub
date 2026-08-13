import Foundation
import SwiftUI
import Combine

@MainActor
final class RuntimeRecorder: ObservableObject {
    static let shared = RuntimeRecorder()

    @Published private(set) var events: [RuntimeEvent] = []
    @Published private(set) var bodyMetrics: [String: BodyMetric] = [:]
    @Published private(set) var dependencies: Set<DependencyEdge> = []

    private let maximumEventCount = 400

    func record(
        _ kind: RuntimeEventKind,
        source: String,
        message: String
    ) {
        events.append(RuntimeEvent(kind: kind, source: source, message: message))
        if events.count > maximumEventCount {
            events.removeFirst(events.count - maximumEventCount)
        }
    }

    func recordBody(_ name: String, duration: Duration = .zero) {
        var metric = bodyMetrics[name] ?? BodyMetric(
            name: name,
            count: 0,
            totalDuration: .zero
        )
        metric.count += 1
        metric.totalDuration += duration
        bodyMetrics[name] = metric
        record(.body, source: name, message: "第 \(metric.count) 次求值")
    }

    func registerDependency(source: String, target: String) {
        dependencies.insert(DependencyEdge(source: source, target: target))
        record(.dependency, source: target, message: "读取 \(source)")
    }

    func clearEvents() {
        events.removeAll()
    }

    func resetAll() {
        events.removeAll()
        bodyMetrics.removeAll()
        dependencies.removeAll()
    }
}

enum RuntimeTrace {
    static func event(
        _ kind: RuntimeEventKind,
        source: String,
        message: String
    ) {
        Task { @MainActor in
            RuntimeRecorder.shared.record(kind, source: source, message: message)
        }
    }

    static func body(_ name: String, startedAt: ContinuousClock.Instant? = nil) {
        let duration = startedAt.map { ContinuousClock.now - $0 } ?? .zero
        Task { @MainActor in
            RuntimeRecorder.shared.recordBody(name, duration: duration)
        }
    }

    static func dependency(_ property: String, view: String) {
        Task { @MainActor in
            RuntimeRecorder.shared.registerDependency(source: property, target: view)
        }
    }
}

final class LifetimeToken {
    let name: String
    let id = UUID()

    init(_ name: String) {
        self.name = name
        RuntimeTrace.event(.lifecycle, source: name, message: "创建 token \(id.short)")
    }

    deinit {
        let tokenName = name
        let tokenID = id.short
        RuntimeTrace.event(.lifecycle, source: tokenName, message: "释放 token \(tokenID)")
    }
}

extension UUID {
    var short: String {
        uuidString.split(separator: "-").first.map(String.init) ?? uuidString
    }
}
