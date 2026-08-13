# Changelog

本项目遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 的组织方式。

## [Unreleased]

### Added

- 新增 `Documentation/RuntimeLabLearningGuide.md`，按 App 顺序完整讲解 `@State` 生命周期、Identity、DynamicProperty、观察粒度、依赖关系图、更新流水线及 Identity/Diff。
- README 增加配套学习文档入口。

## [1.0.0] - 2026-07-27

### Added

- 可直接运行的 Xcode SwiftUI App target 与 Dashboard。
- `RuntimeRecorder`、Timeline、body 指标、依赖边和生命周期探针。
- `@State`、Identity、`.id()`、`ForEach`、DynamicProperty 实验。
- `ObservableObject` 与 Observation 更新粒度对比。
- Dependency Graph、Update Pipeline 和纯 Swift Diff 教学模拟器。
- Navigation 生命周期和性能 Lab。
- 完整 Auth Journey：Mock Server → Event Center → Flow Controller → Observable State → SwiftUI。
- Runtime Inspector 的 Timeline、Body、Dependency 和 Debug Guide 面板。
- Swift Testing 单元测试。
- 中文 README、架构说明、调试指南和 MIT License。

### Changed

- 将原来的单一 `ContentView` 条件 State 示例整合进 Identity Lab。
