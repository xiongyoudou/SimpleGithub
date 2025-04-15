//
//  GithubReposMiddleware.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation
import Combine

extension Middlewares {
    private static let githubRepos = GithubRepos()
    private static let usersRepository = UsersRepository()
    private static var searchDebouncer = CurrentValueSubject<String, Never>("")
    
    static let githubReposMiddleware: Middleware<AppState> = { state, action in
        switch action {
        case HomeStateAction.fetchRepos:
            return githubRepos
                .fetchReposWithKeyword()
                .map { HomeStateAction.didReceiveRepos($0) }
                .ignoreError()
                .eraseToAnyPublisher()
        case HomeStateAction.filterEpisodes(let phrase):
            // Cancelling previous request
            searchDebouncer.send(completion: .finished)
            searchDebouncer = CurrentValueSubject<String, Never>(phrase)
            
            return searchDebouncer
                .debounce(for: phrase == "" ? 0.0 : 0.5, scheduler: RunLoop.main)
                .first()
                .flatMap { githubRepos.fetchReposWithKeyword(phrase: $0) }
                .map { HomeStateAction.didReceiveRepos($0) }
                .ignoreError()
                .eraseToAnyPublisher()
        case UserDetailsStateAction.fetchUserProfile(let userId):
            return usersRepository.fetchUser(id: userId).ignoreError()
                .map { UserDetailsStateAction.didReceiveUserProfile(user: $0) }
                .eraseToAnyPublisher()
        default:
            return Empty().eraseToAnyPublisher()
        }
    }
}
