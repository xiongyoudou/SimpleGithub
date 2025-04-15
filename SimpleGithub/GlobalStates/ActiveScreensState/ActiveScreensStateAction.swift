//
//  ActiveScreensStateAction.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

enum AppScreen {
    case login
    case home
    case userProfile(id: UUID)
    case error
}

enum ActiveScreensStateAction: Action {
    case showScreen(AppScreen)
    case dismissScreen(AppScreen)
}
