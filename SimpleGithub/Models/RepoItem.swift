//
//  RepoItem.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

struct RepoItem: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
}

extension RepoItem {
    static let repoItem = RepoItem(id: UUID(), name: "Walter W.", description: "Albuquerque, USA")
    static let repoItem2 = RepoItem(id: UUID(), name: "Walter W.", description: "Albuquerque, USA")
}
