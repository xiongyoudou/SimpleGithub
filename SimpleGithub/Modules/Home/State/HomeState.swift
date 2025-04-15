//
//  HomeState.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

struct HomeState: Codable {
    let repos: [RepoItem]
    let isLoading: Bool
    let searchText: String
}

extension HomeState {
    init() {
        repos = []
        isLoading = true
        searchText = ""
    }
}
