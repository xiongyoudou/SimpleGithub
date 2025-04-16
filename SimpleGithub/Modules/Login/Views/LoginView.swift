//
//  HomeView.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var store: Store<AppState>
    var state: LoginState? { store.state.screenState(for: .login) }
    
    @State private var username: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            if let state = state, !state.isLoading {
                
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 40)
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal)
                
                SecureField("password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: login) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(username.isEmpty || password.isEmpty)
                Spacer()
                    .padding(.top, 50)
            }
            else {
                SpinnerView()
            }
        }
    }
    
    private func login() {
        store.dispatch(LoginStateAction.loginToGithub)
    }
}
