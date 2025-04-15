//
//  HomeState.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

struct LoginState: Codable {
    let isLoading: Bool
    let token: String?
    let error: String?
}

extension LoginState {
    init() {
        isLoading = true
        token = nil
        error = nil
    }
}
