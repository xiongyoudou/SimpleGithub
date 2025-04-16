//
//  HomeState.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

struct LoginState: Codable {
//    let userName: String
//    let password: String
//    let showingAlert: Bool
//    let alertMessage: String
    let isLoading: Bool
    let token: String?
    let error: String?
}

extension LoginState {
    init() {
//        userName = ""
//        password = ""
//        showingAlert = false
//        alertMessage = ""
        isLoading = false
        token = nil
        error = nil
    }
}
