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
        case LoginStateAction.loginToGithub:
            return LoginState(isLoading: true, token: state.token, error: state.error)
        case LoginStateAction.loginSuccess(let token):
            return LoginState(isLoading: state.isLoading, token: token, error: state.error)
        case LoginStateAction.loginFailed(let error):
            return LoginState(isLoading: state.isLoading, token: state.token, error: error)
        }
    }
}
