//
//  HomeStateAction.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

enum HomeStateAction: Action {
    case updateAccessToken(String)
    case fetchRepos(accessToken: String)
    case didReceiveRepos([GitHubRepo])
    case updateSearchText(String)
    case filterRepos(accessToken: String, phrase: String)
}
