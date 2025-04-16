//
//  UserDetailsState.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

struct UserDetailsState: Codable {
    let details: GitHubUser?
    let isLoading: Bool
}

extension UserDetailsState {
    init() {
        details = nil
        isLoading = true
    }
}
