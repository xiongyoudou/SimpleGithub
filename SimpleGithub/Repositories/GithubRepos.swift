//
//  GithubRepos.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation
import Combine

enum GithubReposError: Error {
    case unknown
    case couldNotFind
}

final class GithubRepos: ObservableObject {
    private let simulatedDelay: RunLoop.SchedulerTimeType.Stride = 1.0

    func fetchReposWithKeyword(phrase: String? = nil) -> AnyPublisher<[RepoItem], GithubReposError> {
        let isFiltering = phrase != nil
        let phrase = phrase?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let repos = [RepoItem.repoItem, RepoItem.repoItem2]
            .filter { phrase == "" || $0.name.lowercased().contains(phrase) }

        return Just(repos)
            .delay(for: isFiltering ? 0.0 : simulatedDelay, scheduler: RunLoop.main)
            .setFailureType(to: GithubReposError.self)
            .eraseToAnyPublisher()
    }
}
