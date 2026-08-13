//
//  SwiftUILearningTests.swift
//  SwiftUILearningTests
//
//  Created by Jun LEI on 2026/7/27.
//

import Testing
@testable import SwiftUILearning

@MainActor
struct SwiftUILearningTests {
    @Test
    func diffReusesStableIdentity() {
        let old = [LabTreeNode(id: "A", type: "Text", value: "Hello")]
        let new = [LabTreeNode(id: "A", type: "Text", value: "Hello")]

        #expect(TreeDiffEngine.diff(old: old, new: new) == [.reuse(id: "A")])
    }

    @Test
    func diffUpdatesValueWithoutReplacingNode() {
        let old = [LabTreeNode(id: "A", type: "Text", value: "Hello")]
        let new = [LabTreeNode(id: "A", type: "Text", value: "World")]

        #expect(
            TreeDiffEngine.diff(old: old, new: new)
                == [.update(id: "A", from: "Hello", to: "World")]
        )
    }

    @Test
    func diffDestroysAndCreatesWhenTypeChanges() {
        let old = [LabTreeNode(id: "A", type: "Text")]
        let new = [LabTreeNode(id: "A", type: "Image")]

        #expect(
            TreeDiffEngine.diff(old: old, new: new)
                == [.destroy(id: "A"), .create(id: "A")]
        )
    }

    @Test
    func authServerEventsMapToExpectedSteps() {
        #expect(AuthServerEvent.requirePassword.nextStep == .password)
        #expect(AuthServerEvent.requireOTP.nextStep == .otp)
        #expect(AuthServerEvent.requireBiometric.nextStep == .biometric)
        #expect(AuthServerEvent.authenticated.nextStep == .success)
    }

    @Test
    func recorderDeduplicatesDependencyEdges() {
        let recorder = RuntimeRecorder.shared
        recorder.resetAll()

        recorder.registerDependency(source: "Model.name", target: "NameView")
        recorder.registerDependency(source: "Model.name", target: "NameView")

        #expect(recorder.dependencies.count == 1)
    }
}
