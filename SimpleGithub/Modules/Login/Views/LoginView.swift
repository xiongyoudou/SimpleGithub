//
//  HomeView.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: Store<AppState>
    var state: LoginState? { store.state.loginState }
    
    var body: some View {
        VStack {
            if state?.isLoading ?? false {
                SpinnerView()
            } else {
                VStack(spacing: 60) {
                    Spacer()
                    Image("logo")
                        .resizable()
                        .frame(width: 140, height: 140)
                    Button(action: {                        
                        store.dispatch(LoginStateAction.startOAuthLogin)
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
                    get: { state?.accessToken != nil },
                    set: { _ in }
                ),
                label: {}
            )
        }
        .onOpenURL { url in
            store.dispatch(LoginStateAction.handleCallbackURL(url))
        }
    }
}
