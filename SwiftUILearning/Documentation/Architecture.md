# 架构说明

## 真实记录与教学模拟的边界

项目真实记录：

- SwiftUI `body` 中插入探针时的求值次数和相对耗时
- `onAppear` / `onDisappear`
- 自定义 `DynamicProperty.update()`
- `ObservableObject` 与 `@Observable` 的公开行为
- 应用自己产生的 State、Navigation、Server Event 和 Flow 事件

项目不尝试读取：

- Apple 私有 AttributeGraph 节点
- SwiftUI 私有 View Tree / Render Tree
- 私有 Diff 操作
- UIKit/Core Animation 的内部提交细节

`DependencyGraphLab`、`UpdatePipelineLab` 与 `TreeDiffEngine` 是教学模型，UI 和 README 中均保留这一说明。

## 数据流

```text
用户或服务端事件
       ↓
应用状态发生 mutation
       ↓
SwiftUI/Observation 决定 invalidation 入口
       ↓
DynamicProperty 准备
       ↓
View body 重新求值
       ↓
Identity 匹配与描述差异判断
       ↓
必要的布局和渲染更新
```

## Runtime Recorder

所有 Lab 把可观察事件写入共享 `RuntimeRecorder`。Recorder 只用于 Debug/教学，不参与业务状态决策，避免调试工具反向控制实验逻辑。

## Auth Journey

```text
MockAuthServer
      ↓ AuthServerEvent
AuthEventCenter
      ↓
AuthFlowController
      ↓
AuthJourneyState (@Observable)
      ↓
AuthJourneyLabView
```

Screen 的结构 Identity 随步骤改变；Journey State 的所有权位于更高层，因此跨 Screen 的输入和流程状态得以保持。

