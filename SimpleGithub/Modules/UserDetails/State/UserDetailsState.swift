//
//  UserDetailsState.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

struct UserDetailsState: Codable {
    let userId: UUID
    let details: User?
    let isLoading: Bool
}

extension UserDetailsState {
    init(id: UUID) {
        userId = id
        details = nil
        isLoading = true
    }
}
