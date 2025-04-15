//
//  ActiveScreensState.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

struct ActiveScreensState: Codable {
    let screens: [AppScreenState]
}

extension ActiveScreensState {
    init() {
        screens = [.login(LoginState())]
    }
}
