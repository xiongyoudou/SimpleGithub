//
//  UserDetailsStateAction.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

enum UserDetailsStateAction: Action {
    case fetchUserProfile(accessToken: String)
    case didReceiveUserProfile(user: GitHubUser)
}
