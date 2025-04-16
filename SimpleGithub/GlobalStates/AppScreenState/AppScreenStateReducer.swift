//
//  AppScreenStateReducer.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

extension AppScreenState {
    static let reducer: Reducer<Self> = { state, action in
        switch state {
        case .login: return state
        case .home(let state): return .home(HomeState.reducer(state, action))
        case .userProfile(let state): return .userProfile(UserDetailsState.reducer(state, action))
        case .error(let state): return .error(ErrorState.reducer(state, action))
        }
    }
}
