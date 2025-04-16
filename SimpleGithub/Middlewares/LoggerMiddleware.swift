//
//  LoggerMiddleware.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Combine

extension Middlewares {
    static let logger: Middleware<AppState> = { state, action, _ in
        let stateDescription = "\(state)".replacingOccurrences(of: "SimpleGithub.", with: "")
        print("➡️ \(action)\n✅ \(stateDescription)\n")

        return Empty().eraseToAnyPublisher()
    }
}
