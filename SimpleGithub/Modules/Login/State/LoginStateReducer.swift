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
            print("")
        case LoginStateAction.loginSuccess(let token):
            print(token)
        case LoginStateAction.loginFailed(let error):
            print(error)
        }
        return state
    }
}
