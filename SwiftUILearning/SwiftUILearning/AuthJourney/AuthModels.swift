import Foundation
import Observation

enum AuthStep: String, CaseIterable, Codable, Sendable {
    case password
    case otp
    case biometric
    case success

    var title: String {
        switch self {
        case .password: "Password"
        case .otp: "OTP"
        case .biometric: "Biometric"
        case .success: "Success"
        }
    }
}

enum AuthServerEvent: String, Sendable {
    case requirePassword
    case requireOTP
    case requireBiometric
    case authenticated

    var nextStep: AuthStep {
        switch self {
        case .requirePassword: .password
        case .requireOTP: .otp
        case .requireBiometric: .biometric
        case .authenticated: .success
        }
    }
}

@Observable
@MainActor
final class AuthJourneyState {
    var step: AuthStep = .password
    var password = ""
    var otp = ""
    var isLoading = false
    var errorMessage: String?

    let journeyID = UUID()
}

actor MockAuthServer {
    func nextEvent(after step: AuthStep) async throws -> AuthServerEvent {
        try await Task.sleep(for: .milliseconds(550))
        return switch step {
        case .password: AuthServerEvent.requireOTP
        case .otp: AuthServerEvent.requireBiometric
        case .biometric: AuthServerEvent.authenticated
        case .success: AuthServerEvent.requirePassword
        }
    }
}

@MainActor
final class AuthEventCenter {
    private var handlers: [(AuthServerEvent) -> Void] = []

    func observe(_ handler: @escaping (AuthServerEvent) -> Void) {
        handlers.append(handler)
    }

    func publish(_ event: AuthServerEvent) {
        RuntimeRecorder.shared.record(
            .server,
            source: "AuthEventCenter",
            message: event.rawValue
        )
        handlers.forEach { $0(event) }
    }
}

@MainActor
final class AuthFlowController {
    let state: AuthJourneyState

    private let server: MockAuthServer

    private let eventCenter: AuthEventCenter

    init(
        state: AuthJourneyState? = nil,
        server: MockAuthServer? = nil,
        eventCenter: AuthEventCenter? = nil
    ) {
        let resolvedState = state ?? AuthJourneyState()
        let resolvedServer = server ?? MockAuthServer()
        let resolvedEventCenter = eventCenter ?? AuthEventCenter()
        self.state = resolvedState
        self.server = resolvedServer
        self.eventCenter = resolvedEventCenter
        resolvedEventCenter.observe { [weak self] event in
            self?.transition(to: event.nextStep, event: event)
        }
    }

    func submitCurrentStep() async {
        guard !state.isLoading, state.step != .success else { return }

        state.isLoading = true
        state.errorMessage = nil
        RuntimeRecorder.shared.record(
            .action,
            source: "AuthJourney",
            message: "提交 \(state.step.title)"
        )

        do {
            let event = try await server.nextEvent(after: state.step)
            eventCenter.publish(event)
        } catch is CancellationError {
            RuntimeRecorder.shared.record(.flow, source: "AuthJourney", message: "请求已取消")
        } catch {
            state.errorMessage = error.localizedDescription
        }
        state.isLoading = false
    }

    func restart() {
        state.password = ""
        state.otp = ""
        transition(to: .password, event: .requirePassword)
    }

    private func transition(to step: AuthStep, event: AuthServerEvent) {
        let previous = state.step
        state.step = step
        RuntimeRecorder.shared.record(
            .flow,
            source: "AuthFlowController",
            message: "\(previous.title) → \(step.title)（\(event.rawValue)）"
        )
    }
}
