//
//  HomeStateAction.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

enum LoginStateAction: Action {
    case loginToGithub
    case loginSuccess(token: String)
    case loginFailed(error: String)
}
