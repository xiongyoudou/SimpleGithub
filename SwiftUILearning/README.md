# SwiftUI Runtime Lab

一个可直接运行的 SwiftUI 实验工程，用交互式 Demo 观察：

- `@State` 的外部 Storage、初始值和生命周期
- View 的结构 Identity、显式 `.id()` 与 `ForEach` 稳定 ID
- `DynamicProperty.update()` 和 `body` 的调用顺序
- `ObservableObject` 对象级通知与 `@Observable` 属性级追踪
- Dependency Tracking 的 `Property → View` 关系
- 从 Action 到 Render 的更新流水线
- Identity/Diff 的复用、更新、创建和销毁模型
- Navigation 对页面本地状态生命周期的影响
- body 次数与耗时探针
- 服务端事件驱动的 Auth Journey 参考实现

> 边界说明：AttributeGraph、SwiftUI Diff Engine 和 Render Tree 是 Apple 的非公开实现。本项目不会访问私有 API。相关页面是明确标注的教学模拟器；`body`、生命周期、`DynamicProperty.update()` 和 Observation 行为则由真实 SwiftUI 代码产生。

## 配套学习文档

运行工程后，建议打开 [SwiftUI Runtime Lab 配套学习指南](Documentation/RuntimeLabLearningGuide.md)，按照页面顺序边操作、边阅读源码：

```text
@State 生命周期
    ↓
View Identity
    ↓
DynamicProperty
    ↓
观察粒度
    ↓
依赖关系图
    ↓
更新流水线
    ↓
Identity 与 Diff
```

指南包含每个按钮的操作步骤、对应源码、预期现象、日志解读和教学模型边界。

## 环境要求

- macOS + Xcode 26.6（项目当前创建版本）
- iOS 26.5+ Simulator 或真机（以当前项目 Deployment Target 为准）
- 无第三方依赖，无需执行 `pod install` 或 `swift package resolve`

## 如何运行

1. 在 Finder 中双击 `SwiftUILearning.xcodeproj`，或在 Xcode 选择 **File → Open** 并打开该文件。
2. Xcode 顶部 Scheme 选择 **SwiftUILearning**。
3. 选择一个 iPhone Simulator。
4. 按 `⌘R`，或点击工具栏的 Run ▶。
5. App 启动后，从首页依次进入各个 Lab。

如果 Scheme 没出现：

1. 选择 **Product → Scheme → Manage Schemes…**
2. 确认 `SwiftUILearning` 已勾选并可见。
3. 仍有问题时关闭 Xcode，重新双击 `.xcodeproj`，不要单独打开某个 Swift 文件。

## 推荐学习顺序

1. **@State 生命周期**：建立“View value ≠ State Storage”的模型。
2. **View Identity**：观察 `if`、`.id()` 和 `ForEach` 如何决定 Storage 是否复用。
3. **DynamicProperty**：从真实日志确认 `update()` 是 body 前的准备入口。
4. **观察粒度对比**：比较 `ObservableObject` 与 Observation。
5. **依赖关系图**：理解实际属性读取如何形成依赖。
6. **更新流水线**：把所有阶段串起来。
7. **Identity 与 Diff**：用可测试的教学引擎观察节点操作。
8. **导航与 Auth Journey**：把机制落到真实工程边界。
9. **Runtime Inspector**：集中分析 Timeline、body 指标和依赖边。

## 各部件做什么

### `SwiftUILearning/RuntimeCore`

- `RuntimeEvent.swift`：统一事件、body 指标和依赖边模型。
- `RuntimeRecorder.swift`：会话内 Timeline、body 次数/耗时与依赖记录中心。
- `ViewProbes.swift`：生命周期探针和真正的自定义 `DynamicProperty`。
- `TreeDiffEngine.swift`：纯 Swift、可测试的教学 Diff Engine。

### `SwiftUILearning/Labs`

- `StateLifecycleLabView`：值状态和引用状态的持久化实验。
- `IdentityLabView`：条件节点、`.id()`、稳定列表 ID。
- `DynamicPropertyLabView`：`update()`/`body` 顺序。
- `ObservationComparisonLabView`：对象级与属性级失效范围。
- `DependencyGraphLabView`：显式登记并显示依赖边。
- `UpdatePipelineLabView`：更新阶段可视化。
- `DiffLabView`：树节点 reconciliation 模拟。
- `NavigationRuntimeLabView`：route、Identity 与页面本地 State。
- `PerformanceLabView`：body 次数和相对耗时趋势。

### `SwiftUILearning/AuthJourney`

- `AuthModels.swift`：Mock Server、Event Center、Flow Controller 和 Observable Journey State。
- `AuthJourneyLabView.swift`：Password → OTP → Biometric → Success 的可运行流程。

业务状态由 `AuthJourneyState` 持有，Screen 可以因步骤切换而销毁；这演示了为什么复杂流程状态不应放在短生命周期页面里。

### `SwiftUILearning/Inspector`

`RuntimeInspectorView` 提供四个面板：

- Timeline：按事件类型筛选。
- Body：调用次数和探针平均耗时。
- 依赖：教学记录的 `Property → View` 边。
- 指南：常见 SwiftUI 问题的排查顺序。

## 常见问题怎么调

### `@State` 突然重置

1. 在 Identity Lab 复现相同行为。
2. 检查 View 是否被 `if/switch` 从树中移除。
3. 检查 `.id()` 是否变化。
4. 检查 `ForEach` ID 是否稳定并真正代表业务实体。
5. 如果状态应跨页面存在，把所有权提升到更长寿的 Feature/Flow。

### body 调用过多

1. 打开 Inspector 的 Body 面板找更新热点。
2. 确认哪些 View 声明了 `@ObservedObject`。
3. 检查父 View 是否读取了过多 Observable 属性。
4. 把属性访问下推到最小消费 View。
5. 最终用 SwiftUI Instruments 验证，不把本 Lab 的轻量计时当作生产 profiler。

### 修改普通 class 字段后 UI 不更新

`@State` 保存普通 class 时，修改对象内部字段不会自动产生 Observation 通知。使用 `@Observable`（现代体系）或 `ObservableObject + @Published`（经典体系）。

## 构建和测试

命令行构建（不签名）：

```bash
xcodebuild \
  -project SwiftUILearning.xcodeproj \
  -scheme SwiftUILearning \
  -destination 'generic/platform=iOS' \
  -derivedDataPath /tmp/SwiftUILearningDerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
```

在可用的 Simulator 上运行测试：

```bash
xcodebuild \
  -project SwiftUILearning.xcodeproj \
  -scheme SwiftUILearning \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  test
```

也可以直接在 Xcode 按 `⌘U`。

## 工程结构

```text
SwiftUILearning.xcodeproj        真实 App / Test targets
SwiftUILearning/
├── SwiftUILearningApp.swift     App 入口
├── ContentView.swift            Dashboard 入口
├── DashboardView.swift
├── RuntimeCore/
├── Components/
├── Labs/
├── Inspector/
└── AuthJourney/
SwiftUILearningTests/            Swift Testing 单元测试
SwiftUILearningUITests/          XCUITest target
Documentation/                   架构、教程与调试说明
├── RuntimeLabLearningGuide.md   七个核心 Lab 配套教程
├── Architecture.md              真实记录与教学模拟边界
└── DebuggingGuide.md            常见问题排查指南
README.md
CHANGELOG.md
LICENSE
```

项目使用 Xcode 的 File System Synchronized Groups；新增到上述目录的源文件会自动进入对应 target，无需手工维护文件引用。

## 设计原则

- 只把可观察到的事实称为真实记录。
- 私有实现一律标记为教学模型。
- View Identity、View value、Dependency 和最终 Render 分开讨论。
- body 次数不等于真实 UI 对象重建次数。
- Runtime Lab 是理解和缩小问题范围的工具，不替代 Instruments。

## License

MIT，见 [LICENSE](LICENSE)。
