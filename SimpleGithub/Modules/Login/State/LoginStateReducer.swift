//
//  HomeStateReducer.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

extension LoginState {
    static let reducer: Reducer<Self> = { state, action in
        guard let action = action as? LoginStateAction else { return state }

        switch action {
        case .startOAuthLogin:
            return LoginState(authUrl:nil, isLoading: true, isLogined: true, accessToken: nil, error: nil)
        case .handleCallbackURL(let url):
            return state
        case .loginSucessWithToken(let accessToken):
//            return LoginState(authUrl:nil, isLoading: false, isLogined: true, accessToken: accessToken, error: nil)
            return LoginState(authUrl:nil, isLoading: false, isLogined: true, accessToken: nil, error: "error")
        case .loginFailed(let error):
            return LoginState(authUrl:nil, isLoading: false, isLogined: true, accessToken: nil, error: error)
        }
    }
}
