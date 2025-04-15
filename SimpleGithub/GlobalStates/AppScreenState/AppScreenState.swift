//
//  AppScreenState.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

enum AppScreenState: Codable {
    case login(LoginState)
    case home(HomeState)
    case userProfile(UserDetailsState)
    case error(ErrorState)
}

extension AppScreenState: CustomStringConvertible {
    var description: String {
        switch self {
        case .login(let state): return "login(isLoading=\(state.isLoading))"
        case .home(let state): return "home(isLoading=\(state.isLoading))"
        case .userProfile(let state): return "userProfile(\(state.details?.name ?? "-"), isLoading=\(state.isLoading))"
        case .error(let state): return "error\(state.errorDescription)"
        }
    }
}

extension AppScreenState {
    static func == (lhs: AppScreenState, rhs: AppScreen) -> Bool {
        switch (lhs, rhs) {
        case (.login, .login): return true
        case (.home, .home): return true
        case (.error, .error): return true
        case (.userProfile(let state), .userProfile(let id)): return state.userId == id
        case (.home, _), (.userProfile, _), (.login, _), (.error, _): return false
        }
    }
    
    static func == (lhs: AppScreen, rhs: AppScreenState) -> Bool {
        rhs == lhs
    }
    
    static func != (lhs: AppScreen, rhs: AppScreenState) -> Bool {
        !(lhs == rhs)
    }
    
    static func != (lhs: AppScreenState, rhs: AppScreen) -> Bool {
        !(lhs == rhs)
    }
    
}
