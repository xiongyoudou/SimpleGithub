//
//  User.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

struct User: Codable {
    let id: UUID
    let avatar: String
    let name: String
    let signUpDate: Date
    let location: String
}

extension User {
    static let mock = User(id: UUID(), avatar: "avatar", name: "Walter W.", signUpDate: Date().addingTimeInterval(-400 * 24 * 3600), location: "Albuquerque, USA")
    static let mock2 = User(id: UUID(), avatar: "avatar2", name: "Anaïs Augustin", signUpDate: Date().addingTimeInterval(-700 * 24 * 3600), location: "Paris, France")
}
