# SwiftUI Runtime Lab 配套学习指南

这份文档配合 App 中的交互实验和工程源码使用。建议不要只阅读结论：先按每章的步骤操作页面，观察数值与 Timeline，再回到对应代码确认事件由谁产生。

> 重要边界：SwiftUI 的 AttributeGraph、内部 Diff Engine 和 Render Tree 没有公开实现。本工程只把公开可观察的行为称为“真实记录”；依赖图、更新流水线和树 Diff 中无法监听的部分，都明确作为教学模型展示。

## 如何使用

1. 按根目录 [README](../README.md#如何运行) 的步骤运行 App。
2. 从首页进入 **Runtime Inspector**，点击“重置全部”，避免上一实验的统计干扰当前实验。
3. 回到首页，按本文章节顺序进入 Lab。
4. 每次只操作一个按钮，先观察页面，再观察“最近事件”。
5. 打开本章列出的源码，找到日志、状态写入和 View 读取分别发生在哪里。
6. 不要把 `body` 次数等同于底层 UI 对象重建次数，也不要把教学 Timeline 当作 Apple 私有实现的逐行跟踪。

## 推荐顺序与源码

| 章节 | Lab | 主要源码 |
|---|---|---|
| 1 | `@State` 生命周期 | [`StateLifecycleLabView.swift`](../SwiftUILearning/Labs/StateLifecycleLabView.swift) |
| 2 | View Identity | [`IdentityLabView.swift`](../SwiftUILearning/Labs/IdentityLabView.swift) |
| 3 | DynamicProperty | [`DynamicPropertyLabView.swift`](../SwiftUILearning/Labs/DynamicPropertyLabView.swift)、[`ViewProbes.swift`](../SwiftUILearning/RuntimeCore/ViewProbes.swift) |
| 4 | 观察粒度对比 | [`ObservationComparisonLabView.swift`](../SwiftUILearning/Labs/ObservationComparisonLabView.swift) |
| 5 | 依赖关系图 | [`DependencyGraphLabView.swift`](../SwiftUILearning/Labs/DependencyGraphLabView.swift)、[`RuntimeRecorder.swift`](../SwiftUILearning/RuntimeCore/RuntimeRecorder.swift) |
| 6 | 更新流水线 | [`UpdatePipelineLabView.swift`](../SwiftUILearning/Labs/UpdatePipelineLabView.swift) |
| 7 | Identity 与 Diff | [`DiffLabView.swift`](../SwiftUILearning/Labs/DiffLabView.swift)、[`TreeDiffEngine.swift`](../SwiftUILearning/RuntimeCore/TreeDiffEngine.swift) |

---

# 第一章：`@State` 生命周期

## 本章回答什么

- `View` 是 struct，为什么状态不会随 View value 重建而丢失？
- `@State` 初始值什么时候真正生效？
- `@State` 保存引用类型时，为什么会看到临时对象创建又释放？

## 关键代码

```swift
struct StateLifecycleLabView: View {
    @State private var count = 0
    @State private var unrelatedToggle = false
    @State private var model = StateReferenceModel()
}
```

近似理解：

```text
StateLifecycleLabView value
        │
        ├── _count: State<Int>
        ├── _unrelatedToggle: State<Bool>
        └── _model: State<StateReferenceModel>
                         │
                         ▼
              SwiftUI 管理的 State Storage
```

`View` value 可以反复生成；只要该逻辑节点的 Identity 不变，SwiftUI 就会继续使用与它关联的 State Storage。

## 实验一：值类型 State

操作：

1. 连续点击几次“count + 1”。
2. 点击“切换无关状态”。
3. 观察 `count` 是否保持。

预期：

```text
count: 0 → 1 → 2
切换 unrelatedToggle
count 仍然为 2
```

这说明：

```text
body 重新求值
    ≠
State Storage 重新创建
```

`body` 根据最新状态生成新的 View 描述，但 `count` 继续来自当前 Identity 的 Storage。

## 初始值什么时候生效

```swift
@State private var count = 0
```

近似展开：

```swift
private var _count = State(initialValue: 0)
```

`0` 是 Storage 的初始值候选：

```text
当前 Identity 没有 Storage
        → 创建 Storage，采用 0

当前 Identity 已有 Storage
        → 复用旧值，不用新的初始值覆盖
```

所以 `@State` 的初始值是在对应 Storage 第一次建立时采用，而不是每次 View value 初始化时都覆盖状态。

## 实验二：`@State` 保存引用

```swift
@State private var model = StateReferenceModel()
```

页面显示：

```swift
model.token.id.short
```

只要 Identity 不变，页面读取到的 `model` 引用就应保持稳定。点击“替换引用”才会显式把新的对象写入 Storage：

```swift
model = StateReferenceModel()
```

## 为什么 Timeline 反复出现 token 创建和释放

这是本 Lab 最容易误解的现象。

当新的 View value 被构造时，属性初始化表达式可能先生成一个候选对象：

```text
构造新的 View value
        ↓
执行 StateReferenceModel()
        ↓
生成候选对象 B
```

随后 SwiftUI 根据稳定 Identity 找到已有 Storage，其中已经保存对象 A：

```text
候选对象 B
        ↓
SwiftUI 发现旧 Storage 中已有 A
        ↓
body 读取 A
        ↓
B 没有成为当前 State，随后释放
```

因此 Timeline 可能显示：

```text
创建 token B
释放 token B
```

而页面仍显示：

```text
当前 Storage 持有的 token A
```

两者不矛盾：

- “最近创建的 token”可能只是初始化候选值。
- 页面中 `model.token` 才是当前 State Storage 实际保存的引用。

点击“替换引用”后，新的对象 C 被写入 Storage，旧对象 A 才会因失去持有而释放。

## 本章结论

```text
View value 是临时描述
Identity 决定逻辑节点是否延续
State Storage 跟随稳定 Identity
initialValue 只在 Storage 首次建立时采用
```

---

# 第二章：View Identity

## 四个概念

| 概念 | 含义 |
|---|---|
| View value | `body` 产生的临时 struct 描述 |
| Structural Identity | 类型、结构位置、条件分支等形成的身份 |
| Explicit Identity | `.id(value)` 或 `ForEach` 业务 ID |
| Realized node lifetime | 逻辑节点实际存在于 View Tree 中的时间 |

Identity 回答：

> 这一轮产生的 View value，是否延续上一轮的逻辑节点？

它进一步决定 State Storage 是否复用。

## 实验一：`if` 移除节点

关键代码：

```swift
if showsConditionalChild {
    IdentityCounterView(name: "ConditionalChild")
} else {
    Text("子节点已经从 View Tree 移除")
}
```

操作：

1. 把 Child 的内部 `count` 加到 2。
2. 点击“隐藏 Child”。
3. 再点击“重新显示 Child”。

流程：

```text
Child 在树中
    ↓
内部 State Storage：count = 2

隐藏 Child
    ↓
Child 从树中移除
    ↓
旧逻辑节点及其 Storage 生命周期结束

重新显示
    ↓
产生新的 Child 节点
    ↓
创建新的 Storage
    ↓
count 使用初始值 0
```

`.transition(.opacity)` 只描述插入/移除动画，不会让已移除节点的 `@State` 永久保存。

## 实验二：显式 `.id()`

```swift
IdentityCounterView(name: "ExplicitIDChild")
    .id(explicitID)
```

操作：

1. 先增加 Child 内部 count。
2. 点击“更换 `.id()`”。

即使 View 类型和结构位置没变，显式 ID 改变仍表示新的逻辑身份：

```text
旧节点：ExplicitIDChild + ID-1
新节点：ExplicitIDChild + ID-2
        ↓
旧节点被替换
        ↓
旧 Storage 结束，新 Storage 建立
```

不要在 `body` 中随意写：

```swift
SomeView().id(UUID())
```

因为每轮求值都会得到新的 ID，State、焦点和动画上下文都可能不断重置。

## 实验三：`ForEach` 稳定 ID

```swift
ForEach(stableItems) { item in
    IdentityRow(item: item)
}
```

每个 `IdentityItem` 使用稳定业务 ID：A、B、C。每行又有自己的：

```swift
@State private var taps = 0
```

先增加 B 行的本地状态，再反转数组：

```text
旧顺序：A B C
新顺序：C B A
```

因为业务 ID 不变：

```text
Row[B] 仍匹配 Row[B]
```

所以状态跟随 B，而不是跟随旧索引。

删除某个业务 ID 时，该行的逻辑节点消失，其本地 State 生命周期结束。

## 生命周期探针的边界

`RuntimeLifecycleModifier` 内部使用一个 UUID 显示节点出现/消失时的探针值。这个 UUID 是教学用的生命周期见证：

```swift
@State private var identity = UUID()
```

它不是 SwiftUI 对外公开的真实内部 Identity。我们用它确认“这份探针 State 是否继续存在”，不能把它当成 AttributeGraph 节点 ID。

## 本章结论

```text
Identity 相同且节点仍存续
        → State Storage 可复用

节点从树中移除、显式 ID 改变或结构/类型不兼容
        → 旧节点结束，新节点建立
```

---

# 第三章：DynamicProperty

## 自定义包装器的两重身份

```swift
@propertyWrapper
struct DebugDynamicProperty<Value>: DynamicProperty {
    @State private var value: Value
    private let name: String
}
```

`@propertyWrapper` 解决：

> `count` 如何变成 `_count.wrappedValue`？

`DynamicProperty` 解决：

> 这个动态属性如何参与 SwiftUI 的 View 更新周期？

页面中：

```swift
@DebugDynamicProperty("DynamicPropertyLab.count")
private var count = 0
```

近似层次：

```text
DynamicPropertyLabView
        ↓
DebugDynamicProperty<Int>
        ↓
内部 @State<Int>
        ↓
SwiftUI State Storage
```

## `wrappedValue`

```swift
var wrappedValue: Value {
    get { value }
    nonmutating set {
        RuntimeTrace.event(.mutation, source: name, message: "wrappedValue setter")
        value = newValue
    }
}
```

读取 `count` 最终读取内部 `@State` 的 Storage。

`nonmutating set` 表示 setter 不需要改变包装器 struct 自身，而是通过内部 `@State` 修改外部 Storage。因此 View 闭包中可以执行：

```swift
count += 1
```

## `projectedValue`

```swift
var projectedValue: Binding<Value> {
    $value
}
```

它让 `$count` 可以取得内部 State 的 `Binding<Value>`。当前页面没有使用 `$count`，但这说明组合型包装器如何向子 View 暴露双向绑定。

## `update()` 到底做什么

```swift
mutating func update() {
    RuntimeTrace.event(
        .dynamicUpdate,
        source: name,
        message: "SwiftUI 在 body 前调用 update()"
    )
}
```

我们的 `update()` 只写日志。真正的持久值由内部 `@State` 提供。因此本实验验证的是公开调用时机，不是在复刻 Apple 私有 `State.update()`。

正确模型：

```text
当前 View 节点即将求值
        ↓
SwiftUI 准备该节点的动态属性
        ↓
调用 DynamicProperty.update()
        ↓
执行 body
```

`update()` 不是：

- 修改 State 的入口；
- 把新值再次复制给 View；
- 保证只在包装值自己变化时调用。

## 两个按钮如何验证

### 修改包装值

```text
count += 1
    ↓
wrappedValue setter
    ↓
内部 State Storage 改变
    ↓
节点进入下一轮更新
    ↓
DynamicProperty.update()
    ↓
body
```

### 只修改无关 State

```swift
unrelated.toggle()
```

`count` 没变，但同一个 `DynamicPropertyLabView` 需要重新求值，所以 SwiftUI仍会准备该 View 中的 DynamicProperty：

```text
unrelated 改变
    ↓
当前 View 需要求值
    ↓
DebugDynamicProperty.update()
    ↓
body
```

这说明 `update()` 属于 View 求值准备阶段，而不是某一个属性 setter 的后续步骤。

## 日志顺序说明

`RuntimeTrace` 使用 `Task { @MainActor in ... }` 写入 Recorder，所以 Timeline 适合判断事件是否发生和大致因果关系，不应作为纳秒级严格顺序证明。

## 本章结论

> `DynamicProperty.update()` 是 SwiftUI 在执行 `body` 前，为当前逻辑节点准备动态输入的公开生命周期入口。

---

# 第四章：观察粒度

## 经典对象级通知

```swift
final class ClassicUserModel: ObservableObject {
    @Published var name = "Taylor"
    @Published var age = 30
}
```

消费者：

```swift
struct ClassicNameView: View {
    @ObservedObject var model: ClassicUserModel

    var body: some View {
        Text(model.name)
    }
}
```

虽然它只显示 `name`，`name` 和 `age` 都通过同一个对象通知入口：

```text
name 改变 ─┐
           ├── objectWillChange ──→ ClassicNameView
age 改变 ──┘
```

所以只修改 `age` 时，`ClassicNameView.body` 仍可能重新求值。新旧 `Text(model.name)` 相同，因此 body 求值不代表屏幕内容一定发生变化。

## Observation 属性级追踪

```swift
@Observable
final class FineUserModel {
    var name = "Taylor"
    var age = 30
}
```

消费者：

```swift
struct FineNameView: View {
    let model: FineUserModel

    var body: some View {
        Text(model.name)
    }
}
```

`body` 实际读取 `model.name`，形成：

```text
FineUserModel.name → FineNameView.body
```

它没有读取 `age`，所以不会建立：

```text
FineUserModel.age → FineNameView.body
```

因此只修改 `age` 不会因为 `age` 的属性依赖直接使 `FineNameView` 失效。

## 操作步骤

1. 在 Inspector 重置统计。
2. 点击经典模型的“只修改 age”，查看 `ClassicNameView.body` 次数。
3. 点击现代模型的“只修改 age”，查看 `FineNameView.body` 次数。
4. 再点击现代模型的“修改 name”，确认 `FineNameView.body` 增加。

预期对比：

| 操作 | ClassicNameView | FineNameView |
|---|---:|---:|
| 修改 name | 重新求值 | 重新求值 |
| 只修改 age | 收到对象级变化，可能重新求值 | 不因 age 属性直接失效 |

## 不要过度解读

属性级追踪缩小的是由某个属性变化直接引发的失效范围，不保证某个 `body` 只会因为该属性而执行。父结构、Environment、Identity 和其他更新仍可能使它重新求值。

`@Bindable` 主要用于获得 `$model.name` 一类 Binding；只读 Observation 并不要求给子 View 强行加 `@Bindable`。

## 本章结论

```text
ObservableObject：
“这个对象变了”

Observation：
“本轮 body 读取了这个具体属性”
```

---

# 第五章：依赖关系图

## 节点和边

模型：

```swift
@Observable
final class DependencyDemoModel {
    var name = "Ada"
    var age = 36
}
```

两个消费者分别读取一个属性：

```text
DependencyDemoModel.name ──→ DependencyNameView.body
DependencyDemoModel.age  ──→ DependencyAgeView.body
```

左边是数据源节点，右边是读取该数据的计算节点，箭头表示变化传播的可能方向。

## 依赖边什么时候形成

当 SwiftUI 执行 `DependencyNameView.body` 并读取 `model.name` 时，Observation 在运行时发现：

```text
当前正在计算 DependencyNameView.body
            +
读取 DependencyDemoModel.name
```

于是形成依赖。它不是 SwiftUI 静态分析源码字符串得到的。

## 为什么拆成两个子 View

如果同一个 `CombinedView.body` 同时读取 `name` 和 `age`：

```text
name ─┐
      ├──→ CombinedView.body
age ──┘
```

任意一个属性变化都可能使这个较大的计算节点失效。

拆开后：

```text
name ──→ NameView.body
age  ──→ AgeView.body
```

依赖和失效边界更小。拆分的价值不仅是文件更短，也可能是缩小属性读取范围；但是否需要优化仍要用 Instruments 测量。

## Lab 如何显示依赖图

消费者中显式调用：

```swift
RuntimeTrace.dependency(
    "DependencyDemoModel.name",
    view: "DependencyNameView"
)
```

Recorder 把它保存为：

```swift
DependencyEdge(source: property, target: view)
```

然后 `recordMutation()` 根据被修改的属性过滤边，输出“教学图预测受影响 View”。

这不是从 Apple 私有 AttributeGraph 抓取的真实边，而是根据本 Lab 明确发生的属性读取登记的教学图。

## 依赖图与 View Tree 不同

View Tree 表示结构：

```text
DependencyGraphLabView
├── DependencyNameView
└── DependencyAgeView
```

Dependency Graph 表示数据读取：

```text
model.name → DependencyNameView
model.age  → DependencyAgeView
```

一个属性可以被多个 View 读取，一个 View 也可以读取多个属性，所以依赖关系是 Graph，不一定是树。

## 依赖是动态的

```swift
if model.showAge {
    Text("\(model.age)")
}
```

当 `showAge` 为 true，本轮读取 `showAge` 和 `age`；为 false 时不读取 `age`。真实依赖应随执行路径更新。

当前 Recorder 用一个 `Set` 保存本次会话中曾登记过的边，直到重置全部。它不是 SwiftUI 当前依赖关系的完整实时快照。

## 本章结论

> Dependency Tracking 是执行 `body` 时发现并建立依赖边的过程；依赖关系图是保存节点与边，并在数据改变时推导影响范围的模型。

---

# 第六章：更新流水线

## 先看清本页性质

```swift
private let phases: [RuntimeEventKind] = [
    .action,
    .mutation,
    .dependency,
    .invalidation,
    .dynamicUpdate,
    .body,
    .diff,
    .render
]
```

这些枚举值只是阶段标签。除了 `count += 1` 是真实状态写入之外，本页主要是人为播放的教学动画，不是 SwiftUI 自动逐阶段回调我们的代码。

## phase 到底如何“触发”

按钮调用：

```swift
runPipeline()
```

方法先清空点亮状态，然后立即创建八个 Task：

```swift
for (index, phase) in phases.enumerated() {
    Task { @MainActor in
        try? await Task.sleep(for: .milliseconds(index * 90))
        ...
    }
}
```

近似展开：

```text
Task 1：等待   0ms → action
Task 2：等待  90ms → mutation
Task 3：等待 180ms → dependency
Task 4：等待 270ms → invalidation
Task 5：等待 360ms → dynamicUpdate
Task 6：等待 450ms → body
Task 7：等待 540ms → diff
Task 8：等待 630ms → render
```

不是 Action 调用 Mutation，也不是 Mutation 调用 Dependency。八个 Task 已经全部安排，分别在等待结束后点亮自己的阶段。

每个 Task 执行：

```swift
if phase == .mutation {
    count += 1
}
lastRun.append(phase)
RuntimeRecorder.shared.record(...)
```

- 只有 `.mutation` 真正修改 `count`。
- `lastRun.append` 让对应行变蓝。
- `record` 把教学阶段写入 Timeline。

`lastRun` 本身也是 `@State`，所以逐步点亮八行会制造多次真实页面更新。不能据此推断一次 `count += 1` 在真实 SwiftUI 中必然产生八次 body。

## 八个阶段的职责

| 阶段 | 概念职责 |
|---|---|
| Action | 用户、网络或系统等变化来源 |
| Mutation | 写入 State/Observable Storage |
| Dependency Lookup | 找到读取该数据的计算节点 |
| Invalidation | 标记旧计算结果需要更新 |
| DynamicProperty.update | 在 body 前准备动态输入 |
| body | 根据当前状态产生新的 View value，并重新形成依赖 |
| Diff/Reconciliation | 根据 Identity 协调新旧描述 |
| Render | 提交必要的布局、显示和动画变化 |

真实 SwiftUI 可以批处理和合并同一 Transaction 内的变化；State setter 次数不等于 Render 次数。

## 哪些是本页真实发生的

| 内容 | 本页性质 |
|---|---|
| Button action | 真实用户操作 |
| `count += 1` | 真实 `@State` mutation |
| `lastRun.append` | 用于动画的真实 `@State` mutation |
| Dependency / Invalidation | 教学模拟 |
| DynamicProperty.update 阶段 | 本页模拟，可到 DynamicProperty Lab 交叉验证 |
| body 阶段日志 | 本页模拟；页面本身确实会真实求值 |
| Diff / Render | 教学模拟 |

## Timeline 为什么看起来倒序

`InlineTimeline` 把最近事件反转显示，最新事件在最上面。因此要按时间戳或从下往上阅读 Action → Render。

## 操作提示

一轮动画约 630ms。当前代码没有取消上一轮 Task，连续快速点击会让两轮阶段交错。等待一轮完成再点下一次。

## 本章结论

```text
Mutation
    ↓
相关计算失效
    ↓
准备动态输入并重算 body
    ↓
协调新旧描述
    ↓
只提交必要变化
```

Pipeline Lab 用动画串起概念；真实行为证据应分别到 DynamicProperty、Observation、Dependency 和 Diff Lab 交叉验证。

---

# 第七章：Identity 与 Diff

## 教学节点

```swift
struct LabTreeNode: Identifiable, Equatable {
    let id: String
    let type: String
    let value: String
}
```

- `id`：模拟显式身份。
- `type`：判断结构类型是否兼容。
- `value`：模拟节点配置。

例如：

```text
A · Text(Hello)
```

表示 ID 为 A、类型为 Text、配置为 Hello。

## Old Tree 与 New Tree

页面用两份 `@State` 保存比较输入：

```swift
@State private var oldTree: [LabTreeNode]
@State private var newTree: [LabTreeNode]
```

`operations` 是计算属性：

```swift
private var operations: [TreeDiffOperation] {
    TreeDiffEngine.diff(old: oldTree, new: newTree)
}
```

每次页面求值读取 `operations` 时，都会重新计算 Diff。

## 算法步骤

### 1. 按 ID 建立字典

```swift
let oldByID = Dictionary(uniqueKeysWithValues: old.map { ($0.id, $0) })
let newByID = Dictionary(uniqueKeysWithValues: new.map { ($0.id, $0) })
```

因此同一数组中的 ID 必须稳定且唯一；重复 ID 会使该教学算法创建字典时失败。

### 2. 找出旧树中消失的节点

```swift
for oldNode in old where newByID[oldNode.id] == nil {
    operations.append(.destroy(id: oldNode.id))
}
```

### 3. 遍历新树决定操作

```text
旧树找不到相同 ID
        → create

ID 相同但 type 不同
        → destroy + create

ID、type 相同但 value 不同
        → update

ID、type、value 都相同
        → reuse
```

## 三个按钮的结果

### 只改 Text 值

```text
Old                     New
A · Text(Hello)         A · Text(World)
B · Image(star)         B · Image(star)
```

结果：

```text
更新 A：Hello → World
复用 B
```

Identity 与类型兼容，A 只是配置变化，对应的逻辑节点和 State 可以延续。

### 换类型

```text
Old                     New
A · Text(Hello)         A · Image(photo)
B · Image(star)         B · Image(star)
```

结果：

```text
销毁 A
创建 A
复用 B
```

相同 ID 不能让完全不同类型无条件复用。结构/类型不兼容意味着旧节点结束、新节点建立。

### 增删节点

```text
Old                     New
A · Text(Hello)         B · Image(star)
B · Image(star)         C · Button(Tap)
```

结果：

```text
销毁 A
复用 B
创建 C
```

B 从索引 1 移到索引 0，但稳定 ID 仍为 B，所以逻辑身份继续匹配。这对应 `ForEach` 状态跟随业务 ID，而不是数组索引。

## 为什么没有 Move

当前 `TreeDiffOperation` 只有：

```text
reuse / update / create / destroy
```

算法没有比较新旧索引，所以 B 的换位只显示为 `reuse`。若要展示移动，需要增加：

```text
move(id: B, from: 1, to: 0)
```

这是简化算法与真实列表协调逻辑之间的边界。

## “将 New 提交为 Old”

```swift
oldTree = newTree
```

它模拟把本轮新描述作为下一轮基准：

```text
Old 与 New 有差异
        ↓
计算并显示操作
        ↓
提交 New
        ↓
New 成为下一轮 Old
```

提交后两棵树相同，结果会变成全部复用。这里的 Render 日志仍是教学事件，不是 SwiftUI 私有 Render Commit 回调。

## 与真实 SwiftUI 的差异

真实 Identity 还会综合：

- 父节点 Identity；
- 结构位置和 ViewBuilder 类型结构；
- `if/switch` 分支；
- View 类型；
- `.id()` 或 `ForEach` 显式 ID；
- 容器自己的协调策略。

本引擎不处理嵌套树、Modifier、Move、Animation、Layout、Environment 或真实 State Storage，只用最小算法演示 Identity 如何决定 `reuse/update/create/destroy`。

## Diff 与 State 生命周期

```text
reuse / update
    ↓
逻辑 Identity 延续
    ↓
State Storage 可继续复用

destroy + create
    ↓
旧逻辑节点结束
    ↓
旧 Storage 结束
    ↓
新 Storage 采用初始值
```

---

# 完整运行模型

把七个 Lab 串起来：

```text
用户或外部事件
        ↓
@State / Observable 属性发生 Mutation
        ↓
状态存储获得新值
        ↓
Dependency Graph 找到相关计算节点
        ↓
观察颗粒度决定失效范围
        ↓
根据 Identity 定位逻辑节点
        ↓
DynamicProperty.update() 准备动态输入
        ↓
body 读取状态并产生新的 View value
        ↓
本轮读取重新形成依赖
        ↓
Identity 匹配与 Diff/Reconciliation
        ↓
reuse / update / create / destroy
        ↓
必要的布局与渲染变化
```

## 核心概念速查

| 概念 | 回答的问题 |
|---|---|
| View value | 当前状态下界面被描述成什么？ |
| Identity | 这一轮节点是不是上一轮的逻辑节点？ |
| State Storage | 跨 View value 求值持续保存什么？ |
| DynamicProperty | body 前如何准备状态、环境等动态输入？ |
| Observation | 哪个具体属性被当前计算读取？ |
| Dependency Graph | 哪个数据变化可能影响哪些计算节点？ |
| Invalidation | 哪些旧计算结果需要重新求值？ |
| Diff/Reconciliation | 新旧描述需要复用、更新、创建还是销毁？ |
| Render | 哪些布局和显示变化最终需要提交？ |

## 阅读日志时牢记

1. `body` 重新求值不等于底层 UI 对象全部重建。
2. State 初始候选对象可以创建后被丢弃，页面显示的 Storage token 才代表当前持有。
3. 生命周期探针 UUID 不是 SwiftUI 私有 Identity。
4. 手动登记的 Property → View 边不是 AttributeGraph 抓取结果。
5. Pipeline 的 phase 是定时教学动画，不是私有回调。
6. TreeDiffEngine 是纯 Swift 教学算法，不是 SwiftUI Diff 源码。
7. Recorder 自己也是 ObservableObject，Inspector 和 Timeline 更新可能带来额外的页面求值与日志。
8. 性能结论最终应使用 Xcode SwiftUI Instruments 验证。

## 学完后的排查顺序

### State 为什么重置

```text
View 是否被移出树？
    ↓
结构位置或类型是否变化？
    ↓
.id() 是否变化？
    ↓
ForEach ID 是否稳定？
    ↓
State 所有者是否应该提升到更长生命周期？
```

### body 为什么频繁

```text
哪个 mutation 是入口？
    ↓
ObservableObject 是否造成对象级通知？
    ↓
哪个 View 实际读取了该属性？
    ↓
依赖边界是否过大？
    ↓
真实计算成本是否值得优化？
```

### 状态变了为什么 UI 没更新

```text
变化是否来自 @State / @Observable / @Published 等可观察来源？
    ↓
View 的 body 是否真正读取该属性？
    ↓
写入是否发生在正确的 Actor？
    ↓
新旧描述是否实际有差异？
```

---

# 下一步

完成本文后，可继续使用：

- [架构说明](Architecture.md)：查看真实记录与教学模拟的整体边界。
- [调试指南](DebuggingGuide.md)：按症状快速排查 Identity、State Ownership 和更新范围。
- App 中的 **Navigation Runtime**：观察导航栈与页面本地 State 生命周期。
- App 中的 **Auth Journey**：观察业务状态所有权如何跨短生命周期 Screen 保持。
- App 中的 **Performance Lab** 与 **Runtime Inspector**：寻找更新热点，再用 Instruments 验证。

