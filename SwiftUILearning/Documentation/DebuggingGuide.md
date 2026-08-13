# SwiftUI 调试指南

## 三个不要混淆的层次

1. View 的 `body` 被重新求值。
2. 新的 View value 被生成和比较。
3. 底层 UI/布局/像素发生实际更新。

前一层发生不代表后一层一定发生。

## Identity 检查

- View 是否仍在同一结构位置？
- 类型是否一致？
- 是否更换了 `.id()`？
- `ForEach` ID 是否稳定？
- 导航或 Sheet 是否把节点从树中移除？

## State 所有权检查

- 纯 UI 临时状态：放在最低的 View。
- 多个兄弟共享：提升到最低公共祖先。
- 跨页面/流程业务状态：放到 Feature/Flow 层。
- 子 View 修改父状态：传 `Binding`，不要复制第二份事实来源。

## 更新范围检查

- 经典 `ObservableObject`：观察者订阅整个 `objectWillChange`。
- Observation：body 实际读取哪个属性，就跟踪哪个属性。
- 即使父 body 重算，子 body 和真实渲染也不必无条件全部进行。

## 性能检查

1. 用 Lab 找出潜在更新入口。
2. 在 Xcode Instruments 使用 SwiftUI 模板。
3. 分开查看 View Body、布局、图片解码、网络与 Main Actor 阻塞。
4. 不要为了减少打印次数而牺牲正确的状态所有权。

