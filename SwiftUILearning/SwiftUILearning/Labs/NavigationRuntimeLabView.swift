import SwiftUI

enum DemoRoute: String, CaseIterable, Identifiable {
    case login
    case otp
    case profile

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

struct NavigationRuntimeLabView: View {
    @State private var path: [DemoRoute] = [.login]

    private var current: DemoRoute {
        path.last ?? .login
    }

    var body: some View {
        LabPage(
            "导航与状态生命周期",
            subtitle: "导航本质上也是状态。比较 push、pop 与 replace 对页面 Identity/本地 State 的影响。"
        ) {
            LabCard("Route Stack", systemImage: "square.stack.3d.up") {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(Array(path.enumerated()), id: \.offset) { index, route in
                            Text(route.title)
                                .font(.caption.bold())
                                .padding(8)
                                .background(
                                    index == path.indices.last
                                        ? Color.accentColor.opacity(0.18)
                                        : Color.secondary.opacity(0.12),
                                    in: Capsule()
                                )
                            if index < path.count - 1 {
                                Image(systemName: "chevron.right")
                            }
                        }
                    }
                }
            }

            RouteScreen(route: current)
                .id(routeIdentity)

            LabCard("导航操作", systemImage: "arrow.triangle.branch") {
                HStack {
                    Button("Push 下一页") {
                        let next = nextRoute(after: current)
                        path.append(next)
                        RuntimeTrace.event(.navigation, source: "RouteStack", message: "push \(next.title)")
                    }
                    Button("Pop") {
                        guard path.count > 1 else { return }
                        let removed = path.removeLast()
                        RuntimeTrace.event(.navigation, source: "RouteStack", message: "pop \(removed.title)")
                    }
                    .disabled(path.count <= 1)
                    Button("Replace 为 Profile") {
                        path = [.profile]
                        RuntimeTrace.event(
                            .navigation,
                            source: "RouteStack",
                            message: "replace 整个栈；旧页面 Identity 生命周期结束"
                        )
                    }
                }
                .buttonStyle(.bordered)
            }

            LabCard("观察重点", systemImage: "eye") {
                Text("页面本地 @State 属于 route 对应的 View Identity。replace 后旧 route 被移除；如果业务状态需要跨页面保留，所有权应提升到仍然存在的 Flow/Feature 层。")
            }

            InlineTimeline(limit: 12)
        }
    }

    private var routeIdentity: String {
        "\(path.count)-\(current.rawValue)"
    }

    private func nextRoute(after route: DemoRoute) -> DemoRoute {
        switch route {
        case .login: .otp
        case .otp: .profile
        case .profile: .login
        }
    }
}

private struct RouteScreen: View {
    let route: DemoRoute
    @State private var localCount = 0
    @State private var token = LifetimeToken("RouteScreen")

    var body: some View {
        let started = ContinuousClock.now
        defer { RuntimeTrace.body("RouteScreen[\(route.rawValue)].body", startedAt: started) }

        return LabCard("当前页面：\(route.title)", systemImage: "rectangle.portrait") {
            LabeledContent("页面本地状态", value: "\(localCount)")
            LabeledContent("Storage token", value: token.id.short)
            Button("页面本地 +1") {
                localCount += 1
            }
            .buttonStyle(.borderedProminent)
        }
        .runtimeLifecycle("RouteScreen[\(route.rawValue)]")
    }
}

