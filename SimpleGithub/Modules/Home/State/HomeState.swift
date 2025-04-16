//
//  HomeState.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

struct HomeState: Codable {
    let repos: [GitHubRepo]
    let isLoading: Bool
    let searchText: String
    let accessToken: String?
}

extension HomeState {
    init() {
        repos = []
        isLoading = true
        searchText = ""
        accessToken = nil
    }
}
