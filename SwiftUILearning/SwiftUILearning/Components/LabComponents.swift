import SwiftUI

struct LabPage<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    init(
        _ title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.largeTitle.bold())
                    Text(subtitle)
                        .foregroundStyle(.secondary)
                }

                content
            }
            .frame(maxWidth: 760, alignment: .leading)
            .padding(20)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LabCard<Content: View>: View {
    let title: String
    let systemImage: String?
    @ViewBuilder let content: Content

    init(
        _ title: String,
        systemImage: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label {
                Text(title).font(.headline)
            } icon: {
                if let systemImage {
                    Image(systemName: systemImage)
                }
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.separator.opacity(0.35), lineWidth: 0.5)
        }
    }
}

struct MetricBadge: View {
    let title: String
    let value: String
    var tint: Color = .accentColor

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.monospacedDigit().bold())
                .foregroundStyle(tint)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct RuntimeEventRow: View {
    let event: RuntimeEvent

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: event.kind.symbol)
                .frame(width: 24)
                .foregroundStyle(.tint)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(event.kind.rawValue)
                        .font(.caption.bold())
                    Spacer()
                    Text(Self.formatter.string(from: event.timestamp))
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.tertiary)
                }
                Text(event.source)
                    .font(.subheadline.weight(.semibold))
                Text(event.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct InlineTimeline: View {
    @ObservedObject private var recorder = RuntimeRecorder.shared
    var limit = 8

    var body: some View {
        LabCard("最近事件", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90") {
            if recorder.events.isEmpty {
                ContentUnavailableView(
                    "还没有事件",
                    systemImage: "waveform.path",
                    description: Text("操作上方实验控件后，这里会出现时间线。")
                )
            } else {
                ForEach(recorder.events.suffix(limit).reversed()) { event in
                    RuntimeEventRow(event: event)
                    if event.id != recorder.events.suffix(limit).first?.id {
                        Divider()
                    }
                }
            }
        }
    }
}

struct FlowArrow: View {
    let label: String

    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: "arrow.down")
                .foregroundStyle(.tint)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

