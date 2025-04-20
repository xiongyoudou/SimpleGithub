//
//  HomeState.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

struct LoginState: Codable {
    let authUrl: String?
    let isLoading: Bool
    let isLogined: Bool
    let accessToken: String?
    let error: String?
}

extension LoginState {
    init() {
        authUrl = nil
        isLoading = false
        isLogined = false
        accessToken = nil
        error = nil
    }
}
