//
//  LoginMiddleware.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Combine
import Dispatch

extension Middlewares {
    static let loginMiddleware: Middleware<AppState> = { state, action, dispatch in
        if let action = action as? LoginStateAction, case .loginToGithub = action {
            // mock networking data
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                let success = true
                if success {
                    let mockToken = "github_token_12345"
                    dispatch(LoginStateAction.loginSuccess(token: mockToken))
                } else {
                    dispatch(LoginStateAction.loginFailed(error: "failed"))
                }
            }
        }
        return Empty().eraseToAnyPublisher()
    }
}
