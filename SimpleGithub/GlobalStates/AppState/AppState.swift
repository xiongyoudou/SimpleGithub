//
//  AppState.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

struct AppState: Codable {
    var loginState = LoginState()
    var homeState = HomeState()
    var userDetailsState = UserDetailsState()
}
