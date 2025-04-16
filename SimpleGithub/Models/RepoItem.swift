//
//  RepoItem.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

struct GitHubRepo: Codable, Identifiable {
    let id: Int
    let name: String
    let full_name: String
    let `private`: Bool
    let html_url: String
    let description: String?
    let fork: Bool
    let created_at: String
    let updated_at: String
    let pushed_at: String
    let stargazers_count: Int
    let watchers_count: Int
    let forks_count: Int
    let language: String?
}

// 错误类型
enum GitHubError: Error {
    case invalidURL
    case unauthorized
    case noData
    case decodingError
    case apiError(String)
}
