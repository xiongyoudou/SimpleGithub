import SwiftUI

struct RuntimeLifecycleModifier: ViewModifier {
    let name: String
    @State private var identity = UUID()

    func body(content: Content) -> some View {
        let started = ContinuousClock.now
        defer { RuntimeTrace.body("\(name).modifier", startedAt: started) }

        return content
            .onAppear {
                RuntimeTrace.event(
                    .lifecycle,
                    source: name,
                    message: "appear；探针 identity = \(identity.short)"
                )
            }
            .onDisappear {
                RuntimeTrace.event(
                    .lifecycle,
                    source: name,
                    message: "disappear；探针 identity = \(identity.short)"
                )
            }
    }
}

extension View {
    func runtimeLifecycle(_ name: String) -> some View {
        modifier(RuntimeLifecycleModifier(name: name))
    }
}

@propertyWrapper
struct DebugDynamicProperty<Value>: DynamicProperty {
    @State private var value: Value
    private let name: String

    init(wrappedValue: Value, _ name: String) {
        _value = State(initialValue: wrappedValue)
        self.name = name
    }

    var wrappedValue: Value {
        get { value }
        nonmutating set {
            RuntimeTrace.event(.mutation, source: name, message: "wrappedValue setter")
            value = newValue
        }
    }

    var projectedValue: Binding<Value> {
        $value
    }

    mutating func update() {
        RuntimeTrace.event(
            .dynamicUpdate,
            source: name,
            message: "SwiftUI 在 body 前调用 update()"
        )
    }
}

