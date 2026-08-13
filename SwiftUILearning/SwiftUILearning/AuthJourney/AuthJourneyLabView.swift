import SwiftUI

struct AuthJourneyLabView: View {
    @State private var controller = AuthFlowController()

    var body: some View {
        let started = ContinuousClock.now
        defer { RuntimeTrace.body("AuthJourneyLabView.body", startedAt: started) }

        return LabPage(
            "Auth Journey",
            subtitle: "可运行的服务端事件 → Event Center → Flow Controller → Observable State → SwiftUI 示例。"
        ) {
            LabCard("Journey", systemImage: "person.badge.key") {
                LabeledContent("Journey ID", value: controller.state.journeyID.short)
                stepIndicator
            }

            authScreen
                .id(controller.state.step)
                .runtimeLifecycle("AuthScreen[\(controller.state.step.rawValue)]")

            LabCard("状态所有权", systemImage: "building.columns") {
                Text("密码、OTP 与当前步骤由仍然存在的 AuthJourneyState 持有；具体 Screen 切换 Identity 后，业务流程状态不会意外丢失。")
                    .font(.caption)
            }

            InlineTimeline(limit: 14)
        }
    }

    private var stepIndicator: some View {
        HStack(spacing: 4) {
            ForEach(AuthStep.allCases, id: \.self) { step in
                VStack(spacing: 5) {
                    Circle()
                        .fill(step == controller.state.step ? Color.accentColor : .secondary.opacity(0.25))
                        .frame(width: 12, height: 12)
                    Text(step.title)
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private var authScreen: some View {
        @Bindable var state = controller.state

        LabCard(controller.state.step.title, systemImage: screenSymbol) {
            switch controller.state.step {
            case .password:
                SecureField("输入任意密码", text: $state.password)
                    .textFieldStyle(.roundedBorder)
                submitButton("Mock Server：要求 OTP")
                    .disabled(controller.state.password.isEmpty)

            case .otp:
                TextField("输入任意 OTP", text: $state.otp)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                submitButton("Mock Server：要求生物识别")
                    .disabled(controller.state.otp.isEmpty)

            case .biometric:
                Text("这里明确模拟系统生物识别成功，不调用真实 LocalAuthentication。")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                submitButton("模拟认证成功")

            case .success:
                ContentUnavailableView(
                    "认证成功",
                    systemImage: "checkmark.seal.fill",
                    description: Text("完整 Journey 已走通。")
                )
                Button("重新开始") {
                    controller.restart()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var screenSymbol: String {
        switch controller.state.step {
        case .password: "lock"
        case .otp: "number.square"
        case .biometric: "faceid"
        case .success: "checkmark.seal"
        }
    }

    private func submitButton(_ title: String) -> some View {
        Button {
            Task {
                await controller.submitCurrentStep()
            }
        } label: {
            HStack {
                if controller.state.isLoading {
                    ProgressView()
                }
                Text(title)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(controller.state.isLoading)
    }
}

