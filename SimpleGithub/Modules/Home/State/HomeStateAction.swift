//
//  HomeStateAction.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

enum HomeStateAction: Action {
    case fetchRepos
    case didReceiveRepos([RepoItem])
    case updateSearchText(String)
    case filterEpisodes(phrase: String)
}
