//
//  SwiftUILearningApp.swift
//  SwiftUILearning
//
//  Created by Jun LEI on 2026/7/27.
//

import SwiftUI

@main
struct SwiftUILearningApp: App {
    @StateObject private var recorder = RuntimeRecorder.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(recorder)
        }
    }
}
