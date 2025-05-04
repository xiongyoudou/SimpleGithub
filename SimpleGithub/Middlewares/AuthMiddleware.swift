//
//  LoggerMiddleware.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Combine

extension Middlewares {
    private static let githubRepos = GithubReposNetworking()
    
    static let authMidleware: Middleware<AppState> = { state, action, dispatch in
        switch action {
        case LoginStateAction.startOAuthLogin:
            githubRepos.startGitHubLogin()
        case LoginStateAction.handleCallbackURL(let url):
            githubRepos.handleCallback(url: url) { result in
                switch result {
                case .success(let accessToken):
                    dispatch(LoginStateAction.loginSucessWithToken(accessToken))
                case .failure(let error):
                    var errStr = ""
                    switch error {
                    case .noData:
                        errStr = "No data"
                    case .missingCode:
                        errStr = "Missing code"
                    case .error(let errString):
                        errStr = errString
                    }
                    dispatch(LoginStateAction.loginFailed(errStr))
                }
            }
        default:
            return Empty().eraseToAnyPublisher()
        }
        return Empty().eraseToAnyPublisher()
    }
}
