//
//  HomeState.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

struct ErrorState: Codable {
    let errorDescription: String
}

extension ErrorState {
    init() {
        errorDescription = ""
    }
}
