import SwiftUI

struct PerformanceLabView: View {
    @State private var workload = 10_000
    @State private var trigger = 0
    @ObservedObject private var recorder = RuntimeRecorder.shared

    var body: some View {
        let started = ContinuousClock.now
        let checksum = performWorkload(workload)
        defer { RuntimeTrace.body("PerformanceLabView.body", startedAt: started) }

        return LabPage(
            "性能与 body 计数",
            subtitle: "用可控工作量观察 body 求值成本；生产问题请再用 SwiftUI Instruments 验证。"
        ) {
            LabCard("可控工作量", systemImage: "gauge.with.dots.needle.50percent") {
                Stepper("循环次数：\(workload)", value: $workload, in: 1_000...200_000, step: 10_000)
                LabeledContent("Checksum", value: "\(checksum)")
                Button("触发一次本地状态更新（\(trigger)）") {
                    trigger += 1
                    RuntimeTrace.event(.performance, source: "PerformanceLab", message: "触发第 \(trigger) 次更新")
                }
                .buttonStyle(.borderedProminent)
            }

            LabCard("当前指标", systemImage: "chart.bar") {
                let metric = recorder.bodyMetrics["PerformanceLabView.body"]
                LabeledContent("body 次数", value: "\(metric?.count ?? 0)")
                LabeledContent(
                    "探针平均耗时",
                    value: String(format: "%.3f ms", metric?.averageMilliseconds ?? 0)
                )
            }

            LabCard("正确调试顺序", systemImage: "list.number") {
                Text("1. 先确认谁成为 invalidation 入口。")
                Text("2. 再统计 body 次数和耗时。")
                Text("3. 最后用 Instruments 检查 View Body、布局和渲染热点。")
                Text("本 Lab 的计时会包含探针开销，只适合比较趋势。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            InlineTimeline(limit: 8)
        }
    }

    private func performWorkload(_ iterations: Int) -> Int {
        var result = 0
        for value in 0..<iterations {
            result = (result &+ value) % 97_409
        }
        return result
    }
}

