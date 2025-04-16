//
//  HomeView.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: Store<AppState>
    @StateObject private var authManager = GitHubAuthManager()
    @State private var isLoading = false
    @State private var currentToken: String?
    
    var body: some View {
        VStack {
            if isLoading {
                SpinnerView()
            } else {
                VStack(spacing: 60) {
                    Spacer()
                    Image("logo")
                        .resizable()
                        .frame(width: 140, height: 140)
                    Button(action: {
                        isLoading = true
                        authManager.startGitHubLogin()
                    }) {
                        HStack(spacing: 12) {
                            Text("login with github")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 4)
                    }
                    .padding(.horizontal, 40)
                    Spacer()
                }
            }
            NavigationLink(
                destination: HomeView(),
                isActive: Binding(
                    get: { authManager.isAuthenticated && currentToken != nil },
                    set: { _ in }
                ),
                label: {}
            )
        }
        .onOpenURL { url in
            authManager.handleCallback(url: url)
        }
        .onChange(of: authManager.accessToken) { newToken in
            isLoading = false
            currentToken = newToken
            store.dispatch(HomeStateAction.updateAccessToken(newToken ?? ""))
        }
    }
}
