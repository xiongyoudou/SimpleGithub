//
//  GithubReposMiddleware.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation
import Combine

extension Middlewares {
    private static let githubRepos = GithubReposNetworking()
    private static let usersRepository = UserInfoNetworking()
    private static var searchDebouncer = CurrentValueSubject<String, Never>("")
    
    static let githubReposMiddleware: Middleware<AppState> = { state, action, dispatch in
        switch action {
        case HomeStateAction.fetchRepos(let accessToken):
            return githubRepos
                .fetchReposWithKeyword(accessToken: accessToken)
                .flatMap { repos -> AnyPublisher<Action, Never> in
                    dispatch(HomeStateAction.didReceiveRepos(repos))
                    return Empty().eraseToAnyPublisher()
                }
                .ignoreError()
                .eraseToAnyPublisher()
        case UserDetailsStateAction.fetchUserProfile(let accessToken):
            usersRepository.requestUserInfo(accessToken: accessToken, completion: { result in
                switch result {
                    case .success(let user):
                    dispatch(UserDetailsStateAction.didReceiveUserProfile(user: user))
                    case .failure(let error):
                        print("ss")
                    }
            })
            return Empty().eraseToAnyPublisher()
        default:
            return Empty().eraseToAnyPublisher()
        }
    }
}
