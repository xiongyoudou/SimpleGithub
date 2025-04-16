//
//  User.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

struct GitHubUser: Codable {
    let login: String
    let id: Int
    let avatar_url: String
    let name: String?
    let email: String?
}
