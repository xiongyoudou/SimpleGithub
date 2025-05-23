//
//  ContentView.swift
//  Shared
//
//  Created by xiong有都 on 2025/4/15.
//

import SwiftUI

let store = Store(
    initial: AppState(),
    reducer: AppState.reducer,
    middlewares: [Middlewares.authMidleware, Middlewares.githubReposMiddleware, Middlewares.logger]
)

struct AppView: View {
    @EnvironmentObject var store: Store<AppState>

    var body: some View {
        NavigationView {
            LoginView()
        }
        .navigationViewStyle(.stack)
    }
}

@main
struct SimpleGithubApp: App {
    var body: some Scene {
        UINavigationBar.appearance().tintColor = .systemBlue
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .systemBlue

        return WindowGroup {
            AppView()
                .tint(.blue)
                .foregroundColor(.primary)
                .environmentObject(store)
        }
    }
}
